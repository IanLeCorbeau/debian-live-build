#!/bin/sh

repodir=.local/src/debian-live-build/config
workdir=.build/deb-live

cp -r "$repodir"/archives "$workdir"/config/
cp "$repodir"/hooks/normal/0001-instenv.hook.chroot "$workdir"/config/hooks/normal/
cp -r "$repodir"/includes.chroot_after_packages/etc "$workdir"/config/includes.chroot_after_packages/
cp "$repodir"/package-lists/pkgs.list.chroot "$workdir"/config/package-lists/
