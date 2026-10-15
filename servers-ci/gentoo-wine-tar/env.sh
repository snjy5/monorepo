#!/bin/dash

# For detecting errors properly
set -ex

# Downloads Stage 3 Gentoo Targall and unpacks it (SYSTEMD)
mkdir -p /gentoo

LINK="$(curl -Lsq https://gentoo.osuosl.org/releases/amd64/autobuilds/current-stage3-amd64-systemd/ |
	grep -Ei "stage3-amd64-desktop-systemd-.*.tar.xz" |
	head -1 | grep -Eo "stage3.*xz" | sed 's/">/\n/g' | uniq)"

curl -Lsq "https://gentoo.osuosl.org//releases/amd64/autobuilds/current-stage3-amd64-desktop-systemd/$LINK" -o gentoo.tar.xz
tar xpf gentoo.tar.xz --xattrs-include='*.*' --numeric-owner -C /gentoo
rm -rf ./*.xz /gentoo/etc/portage

# Misc
mkdir -p /gentoo/etc/portage
mv package-list package.license \
    profile binrepos.conf make.conf \
    package.accept_keywords package.use repos.conf /gentoo/etc/portage/

mv /gentoo/etc/portage/repos.conf/gentoo.conf /gentoo/root/

# Chroot env
cp -L /etc/resolv.conf /gentoo/etc/resolv.conf
for i in dev sys run tmp proc; do mount -R /$i /gentoo/$i; done
