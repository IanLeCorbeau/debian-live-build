#!/bin/bash

# build.sh by Ian LeCorbeau.
# Builds custom Debian iso.
# IMPORTANT: this script should never be run as root.
# Only the lb clean and lb build commands require root privileges.
# By default, doas is called from the script. If sudo is installed instead,
# replace /usr/bin/doas with /usr/bin/sudo in the do_build() and do_rebuild() functions.

BUILDER=LeCorbeau
FLAVOUR=bullseye
REPODIR="$HOME"/.local/src/debian-live-build/config
WORKDIR="$HOME"/.build/deb-dwm-live

mk_dir() {
	mkdir -p "$WORKDIR"
}

conf() {
	cd "$WORKDIR" || exit
	lb config \
		-d "$FLAVOUR" \
		--debian-installer none \
		--iso-publisher "$BUILDER" \
		--checksums sha512 \
		--image-name deb-dwm-live-"$(date +"%Y%m%d")" \
		--archive-areas "main contrib non-free" \
		--debootstrap-options "--variant=minbase" \
		--bootappend-live "boot=live slab_nomerge init_on_alloc=1 init_on_free=1 page_alloc.shuffle=1 pti=on randomize_kstack_offset=on vsyscall=none debugfs=off lockdown=confidentiality"
}

copy_files() {
	cp -r "$REPODIR"/archives "$WORKDIR"/config/
	cp "$REPODIR"/hooks/normal/0001-instenv.hook.chroot "$WORKDIR"/config/hooks/normal/
	cp -r "$REPODIR"/includes.chroot_after_packages/ "$WORKDIR"/config/
	cp "$REPODIR"/package-lists/pkgs.list.chroot "$WORKDIR"/config/package-lists/
}

do_deploy() {
	mk_dir
	conf
	copy_files
}

do_build() {
	cd "$WORKDIR" || exit
	/usr/bin/doas lb build
	gen_sums_sig

}

do_rebuild() {
	cd "$WORKDIR" || exit
	/usr/bin/doas lb clean
	lb config
	/usr/bin/doas lb build
}

gen_sums_sig() {
	local _isoname=deb-dwm-live-"$(date +"%Y%m%d")"-amd64.hybrid.iso

	cd "$WORKDIR" || exit
	touch checksums-"$_isoname".txt
	sha256sum "$_isoname" > checksums-"$_isoname".txt
	sha512sum "$_isoname" >> checksums-"$_isoname".txt
	# Generate a key pair with gpg beforehand or comment out this part
	gpg --detach-sign "$_isoname"
}

# Accepted arguments:
# -c: only run do_deploy
# -r: rebuilds the iso without re-deploying (NOT TESTED YET)
# No arguments provided assumes we want to deploy and build the iso from scratch.
case "$1" in
	-c) do_deploy ;;
	-r) do_rebuild
		gen_sums_sig ;;
	*) do_deploy
		do_build
		gen_sums_sig ;;
esac
