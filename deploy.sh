#!/bin/sh

repodir=.local/src/debian-live-build/config
workdir=.build/deb-live

cp "$repodir"/hooks/normal/0001-instenv.hook.chroot "$workdir"/config/hooks/normal/
cp -r "$repodir"/includes.chroot/etc "$workdir"/config/includes.chroot/
cp "$repodir"/package-lists/pkgs.list.chroot "$workdir"/config/package-lists/
