#!/bin/dash
tar cpzf gentoo.tar.gz --exclude=/gentoo/proc --exclude=/gentoo/tmp --exclude=/gentoo/mnt --exclude=/gentoo/dev --exclude=/gentoo/sys --exclude=/gentoo/run --exclude=/gentoo/media --exclude=/gentoo/var/log --exclude=/gentoo/var/cache --exclude=/gentoo/home/ --one-file-system /gentoo
