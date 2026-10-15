#!/bin/bash
# Bakes k3s (binary + airgap images + installer)
# Runs as root inside the Packer build instance.
set -euxo pipefail

# Fallback default if K3S_VERSION is empty or not passed from Packer
DEFAULT_K3S_VERSION="v1.31.4+k3s1"
K3S_VERSION="${K3S_VERSION:-$DEFAULT_K3S_VERSION}"
INSTALLER=/usr/local/share/k3s-install.sh

# If still somehow set to "stable" or empty, force default
case "$K3S_VERSION" in
  v*+k3s*) ;;
  *) K3S_VERSION="$DEFAULT_K3S_VERSION" ;;
esac

echo "== Using k3s $K3S_VERSION =="

echo "== OS update =="
dnf -y update

echo "== k3s: install binary, do not start or enable =="
mkdir -p "$(dirname "$INSTALLER")"
curl -fsSL --retry 3 --retry-delay 5 https://get.k3s.io -o "$INSTALLER"
chmod 0755 "$INSTALLER"

INSTALL_K3S_VERSION="$K3S_VERSION" \
INSTALL_K3S_SKIP_START=true \
INSTALL_K3S_SKIP_ENABLE=true \
INSTALL_K3S_SKIP_SELINUX_RPM=true \
  sh "$INSTALLER"

RESOLVED=$(/usr/local/bin/k3s --version | awk 'NR==1 {print $3}')
echo "== k3s baked: $RESOLVED =="

echo "== k3s: pre-load airgap images (k3s imports them on first start) =="
IMG_DIR=/var/lib/rancher/k3s/agent/images
mkdir -p "$IMG_DIR"

# Encode '+' to '%2B' for GitHub release asset URLs
ENCODED_TAG="${RESOLVED//+/%2B}"
curl -fsSL --retry 3 --retry-delay 5 \
  "https://github.com/k3s-io/k3s/releases/download/${ENCODED_TAG}/k3s-airgap-images-amd64.tar.zst" \
  -o "$IMG_DIR/k3s-airgap-images-amd64.tar.zst"
test -s "$IMG_DIR/k3s-airgap-images-amd64.tar.zst"

echo "== Sanity checks =="
/usr/local/bin/k3s --version
/usr/local/bin/kubectl version --client
systemctl is-enabled amazon-ssm-agent

echo "== Cleanup so each instance boots as a fresh node =="
dnf -y clean all
rm -rf /var/cache/dnf
cloud-init clean --logs
truncate -s 0 /etc/machine-id
rm -f /home/ec2-user/.ssh/authorized_keys /root/.ssh/authorized_keys
sync
echo "== IMAGE BUILD DONE: k3s $RESOLVED =="
