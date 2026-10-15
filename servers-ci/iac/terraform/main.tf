terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# --- Variables ---

variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "cluster_name" {
  type    = string
  default = "k3s-cluster"
}

# t3.medium = 4 GB RAM. k3s server + ArgoCD does not fit comfortably in 1 GB.
variable "server_instance_type" {
  type    = string
  default = "t3.micro"
}

# Start with no workers. Add them once the control plane boots cleanly, e.g.
# workers = { "worker-1" = { instance_type = "t3.small" } }
variable "workers" {
  type = map(object({
    instance_type = string
  }))
  default = {}
}

variable "argocd_version" {
  type    = string
  default = "v2.13.3"
}

variable "gitops_repo_url" {
  type    = string
  default = "https://github.com/snjy5/monorepo.git"
}

variable "gitops_path" {
  type    = string
  default = "servers-ci/iac/k8s-manifests"
}

# Temporary break-glass: set both to get plain SSH from your own IP.
# Example: debug_ssh_cidr = "203.0.113.7/32"
variable "debug_ssh_cidr" {
  type    = string
  default = ""
}

variable "debug_ssh_public_key" {
  type    = string
  default = ""
}

locals {
  debug_ssh_enabled = var.debug_ssh_cidr != "" && var.debug_ssh_public_key != ""

  # Shared header: every script logs to a file AND the serial console, so
  # `aws ec2 get-console-output` shows progress even with no shell access.
  script_header = <<-EOT
    #!/bin/bash
    set -euxo pipefail
    exec > >(tee -a /var/log/bootstrap.log /dev/console) 2>&1
    trap 'echo "BOOTSTRAP FAILED at line $LINENO"' ERR
    echo "BOOTSTRAP START $(date -u)"
    IMDS_TOKEN=$(curl -fsS -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
    PRIVATE_IP=$(curl -fsS -H "X-aws-ec2-metadata-token: $IMDS_TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)
  EOT
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Cluster   = var.cluster_name
      ManagedBy = "terraform"
    }
  }
}

# --- VPC & Networking ---

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${var.cluster_name}-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.cluster_name}-public" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.cluster_name}-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = { Name = "${var.cluster_name}-public-rt" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# --- EC2 Instance Connect Endpoint (SSH without public port 22) ---

resource "aws_ec2_instance_connect_endpoint" "eice" {
  subnet_id          = aws_subnet.public.id
  security_group_ids = [aws_security_group.eice.id]
  preserve_client_ip = false
}

resource "aws_security_group" "eice" {
  name        = "${var.cluster_name}-eice-sg"
  description = "EICE endpoint: egress to the VPC on SSH only"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
}

# --- Node Security Group ---

resource "aws_security_group" "cluster" {
  name        = "${var.cluster_name}-sg"
  description = "Intra-cluster traffic; SSH only from inside the VPC"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "All traffic between cluster nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description     = "SSH from the EICE endpoint"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.eice.id]
  }

  ingress {
    description = "Direct SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP Web Traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS Web Traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "debug" {
  count      = local.debug_ssh_enabled ? 1 : 0
  key_name   = "${var.cluster_name}-debug"
  public_key = var.debug_ssh_public_key
}

# --- IAM (SSM access) ---

resource "aws_iam_role" "node" {
  name_prefix = "${var.cluster_name}-node-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "node" {
  name_prefix = "${var.cluster_name}-profile-"
  role        = aws_iam_role.node.name
}

# --- AMI: built by packer/k3s.pkr.hcl (Amazon Linux 2023 + k3s) ---

data "aws_ami" "k3s" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["k3s-al2023-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "tag:ManagedBy"
    values = ["packer"]
  }
}

resource "random_password" "k3s_token" {
  length  = 32
  special = false
}

# --- Control plane Keys ---

resource "tls_private_key" "master" {
  algorithm = "ED25519"
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.master.private_key_openssh
  filename        = "${path.module}/secrets/ssh/id_rsa"
  file_permission = "0600"
}

resource "local_file" "public_key" {
  content         = tls_private_key.master.public_key_openssh
  filename        = "${path.module}/secrets/ssh/id_rsa.pub"
  file_permission = "0644"
}

resource "aws_key_pair" "master" {
  key_name   = "${var.cluster_name}-master-key"
  public_key = tls_private_key.master.public_key_openssh
}

# --- Control plane Instance ---

resource "aws_instance" "server" {
  ami                         = data.aws_ami.k3s.id
  instance_type               = var.server_instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.cluster.id]
  iam_instance_profile        = aws_iam_instance_profile.node.name
  key_name                    = aws_key_pair.master.key_name
  user_data_replace_on_change = true

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = <<-EOF
    ${local.script_header}

    # --- Enable zswap & Swapfile (Survival mode for 1 GB RAM) ---
    echo 1 > /sys/module/zswap/parameters/enabled || true
    echo zstd > /sys/module/zswap/parameters/compressor || true
    echo z3fold > /sys/module/zswap/parameters/zpool || true

    fallocate -l 5G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab


    # Cap root daemons (k3s, containerd) to 650 MB RAM
    # Above means swap them
    sudo mkdir -p /etc/systemd/system/system.slice.d/
    cat << ROOT_MEM | sudo tee /etc/systemd/system/system.slice.d/override.conf
    [Slice]
    MemoryHigh=650M
    ROOT_MEM

    # Cap ec2-user sessions to 150 MB RAM
    # Above means swap them
    sudo mkdir -p /etc/systemd/system/user-1000.slice.d/
    cat << USER_MEM | sudo tee /etc/systemd/system/user-1000.slice.d/override.conf
    [Slice]
    MemoryHigh=150M
    USER_MEM

    # Reload for new slice memory limits
    sudo systemctl daemon-reload

    # 3. Install k3s server
    INSTALL_K3S_SKIP_DOWNLOAD=true INSTALL_K3S_SKIP_SELINUX_RPM=true \
    K3S_TOKEN="${random_password.k3s_token.result}" \
      /usr/local/share/k3s-install.sh server \
      --node-ip="$PRIVATE_IP" \
      --advertise-address="$PRIVATE_IP" \
      --flannel-backend=vxlan

    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
    KUBECTL=/usr/local/bin/kubectl

    echo "waiting for node Ready"
    until $KUBECTL get nodes 2>/dev/null | grep -q " Ready"; do sleep 5; done

    # ArgoCD installation
    $KUBECTL create namespace argocd --dry-run=client -o yaml | $KUBECTL apply -f -
    $KUBECTL apply -n argocd --server-side --force-conflicts \
      -f "https://raw.githubusercontent.com/argoproj/argo-cd/${var.argocd_version}/manifests/install.yaml"

    $KUBECTL wait --for=condition=established --timeout=120s crd/applications.argoproj.io

    # Root app
    cat <<YAML | $KUBECTL apply -f -
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: root-apps
      namespace: argocd
    spec:
      project: default
      source:
        repoURL: '${var.gitops_repo_url}'
        targetRevision: HEAD
        path: ${var.gitops_path}
      destination:
        server: 'https://kubernetes.default.svc'
        namespace: default
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
    YAML

    touch /var/lib/bootstrap-done
    echo "BOOTSTRAP DONE $(date -u)"
  EOF

  tags = {
    Name = "${var.cluster_name}-master-1"
    Role = "control-plane"
  }
}

# --- Workers (empty by default) ---

resource "aws_instance" "worker" {
  for_each                    = var.workers
  ami                         = data.aws_ami.k3s.id
  instance_type               = each.value.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.cluster.id]
  iam_instance_profile        = aws_iam_instance_profile.node.name
  key_name                    = local.debug_ssh_enabled ? aws_key_pair.debug[0].key_name : null
  user_data_replace_on_change = true
  depends_on                  = [aws_instance.server]

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = <<-EOF
    ${local.script_header}

    INSTALL_K3S_SKIP_DOWNLOAD=true INSTALL_K3S_SKIP_SELINUX_RPM=true \
    K3S_URL="https://${aws_instance.server.private_ip}:6443" \
    K3S_TOKEN="${random_password.k3s_token.result}" \
      /usr/local/share/k3s-install.sh agent \
      --node-ip="$PRIVATE_IP"

    touch /var/lib/bootstrap-done
    echo "BOOTSTRAP DONE $(date -u)"
  EOF

  tags = {
    Name = "${var.cluster_name}-${each.key}"
    Role = "worker"
  }
}

# --- Outputs ---

output "server_instance_id" {
  value = aws_instance.server.id
}

output "ssm_connect_command" {
  value = "aws ssm start-session --target ${aws_instance.server.id} --region${var.aws_region}"
}

output "eice_ssh_command" {
  value = "aws ec2-instance-connect ssh --instance-id ${aws_instance.server.id} --connection-type eice --os-user ec2-user --region${var.aws_region}"
}

output "direct_ssh_command" {
  value = "ssh -i secrets/ssh/id_rsa ec2-user@${aws_instance.server.public_ip}"
}

output "console_log_command" {
  value = "aws ec2 get-console-output --instance-id ${aws_instance.server.id} --region${var.aws_region} --latest --output text"
}

output "server_public_ip" {
  value = aws_instance.server.public_ip
}
