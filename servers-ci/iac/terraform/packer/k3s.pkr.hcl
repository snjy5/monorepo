packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.3.0"
    }
  }
}

variable "region" {
  type    = string
  default = "eu-north-1"
}

# Build instance size only. The AMI works on any instance type.
variable "instance_type" {
  type    = string
  default = "t3.small"
}

# Pin version directly to bypass update.k3s.io channel lookup failures
variable "k3s_version" {
  type    = string
  default = "v1.31.4+k3s1"
}

# Subnet must have auto-assign public IP enabled and a default route to an IGW
variable "subnet_id" {
  type    = string
  default = ""
}

# (Optional) Provide an explicit VPC ID if not using default VPC
variable "vpc_id" {
  type    = string
  default = ""
}

# (Optional) Attach a security group with verified outbound 0.0.0.0/0 egress
variable "security_group_ids" {
  type    = list(string)
  default = []
}

locals {
  build_time = formatdate("YYYYMMDD-hhmm", timestamp())
}

source "amazon-ebs" "k3s" {
  region             = var.region
  instance_type      = var.instance_type
  vpc_id             = var.vpc_id != "" ? var.vpc_id : null
  subnet_id          = var.subnet_id != "" ? var.subnet_id : null
  security_group_ids = length(var.security_group_ids) > 0 ? var.security_group_ids : null
  ssh_username       = "ec2-user"

  associate_public_ip_address               = true
  temporary_security_group_source_public_ip = true

  source_ami_filter {
    filters = {
      name                = "al2023-ami-2023.*-kernel-*-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["amazon"]
    most_recent = true
  }

  ami_name     = "k3s-al2023-${local.build_time}"
  imds_support = "v2.0"
  encrypt_boot = true

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name      = "k3s-al2023-${local.build_time}"
    K3sPin    = var.k3s_version
    ManagedBy = "packer"
  }
}

build {
  sources = ["source.amazon-ebs.k3s"]

  provisioner "shell" {
    script           = "./install-k3s.sh"
    environment_vars = ["K3S_VERSION=${var.k3s_version}"]
    execute_command  = "sudo {{ .Vars }} bash '{{ .Path }}'"
  }
}
