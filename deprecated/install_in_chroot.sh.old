#!/bin/sh

SRC_DIR=/usr/local/src
GIT_SRC=https://github.com/I-LeCorbeau

upd_repo() {
	printf '%s\n' "Updating apt repository" && sleep 1
	apt update
}

inst_kern_init() {
	INITSYS=
	echo
	printf "Installing kernel and init system."

	if [ "$INITSYS" = systemd ]; then
		apt install linux-image-amd64 systemd systemd-sysv libpam-systemd libsystemd0 -y
	elif [ "$INITSYS" = OpenRC ]; then
		apt install linux-image-amd64 sysvinit-core openrc elogind libpam-elogind \
			orphan-sysvinit-scripts systemctl procps -y
	fi
	
}

set_tz() {
	echo
	printf '%s\n' "Setting locale" && sleep 1
	ln -sf /usr/share/zoneinfo/TIMEZONE /etc/localtime
	dpkg-reconfigure -f noninteractive tzdata
}

set_net() {
	echo
	printf '%s\n' "Setting up network interface" && sleep 1
	INTERFACE=$(find /sys/class/net | grep -i "en" | cut -f5 -d '/')
	apt install ifupdown wpasupplicant crda -y && \
	printf '%s\n' "source /etc/network/interfaces.d/*
# The loopback network interface
auto lo
iface lo inet loopback

# The primary network insterface
allow-hotplug $INTERFACE
iface $INTERFACE inet dhcp" > /etc/network/interfaces
}

mkhosts() {
	echo
	printf '%s\n' "Creating hostname and hosts file" && sleep 1
	printf '%s\n' HOSTNAME > /etc/hostname
	printf '%s\n' "127.0.0.1	localhost
127.0.1.1	HOSTNAME" > /etc/hosts
}

gen_locales() {
	echo
	printf '%s\n' "Setting up locales" && sleep 1
	apt install locales -y
	sed -i '/LOCALE/s/# //g' /etc/locale.gen
	locale-gen LOCALE
	printf '%s\n' "LANG=\"LOCALE\"" > /etc/default/locale
	update-locale \"LOCALE\"
	dpkg-reconfigure -f noninteractive locales
}

set_cons() {
	echo
	printf '%s\n' "Setting up console" && sleep 1
	DEBIAN_FRONTEND=noninteractive apt install console-setup keyboard-configuration -y
	printf '%s\n' 'XKBMODEL="pc105"
XKBLAYOUT="KEYMAP"
XKBVARIANT=""
XKBOPTIONS=""

BACKSPACE="guess"' > /etc/default/keyboard
	dpkg-reconfigure -f noninteractive keyboard-configuration
}

set_pass() {
	echo
	printf '%s\n' "Enter a root password (will not echo): "
	passwd
}

set_wheel() {
	printf '%s\n' "Setting up wheel group" && sleep 1
	sed -i '15 s/^# //' /etc/pam.d/su
	addgroup --system wheel
}

set_user() {
	echo
	printf "Setting up USERNAME" && sleep 1
	useradd -m USERNAME
	usermod -aG wheel,cdrom,floppy,audio,dip,video,plugdev,netdev USERNAME
	usermod -s /bin/bash USERNAME
	echo
	printf '%s\n' "Password for USERNAME (will not echo): "
	passwd USERNAME
	echo
	touch /etc/doas.conf
	printf '%s\n' "permit :wheel" > /etc/doas.conf
}

install_base() {
	echo
	printf '%s\n' "Installing packages" && sleep 1
	apt install alsa-utils apt-utils build-essential calcurse dunst ffmpeg firefox-esr \
		git libx11-dev libxft-dev libxinerama-dev libnotify-bin lxpolkit mandoc mpv \
		scrot sxiv sxhkd udisks2 ufw vim xcompmgr x11-xserver-utils xclip xdg-user-dirs \
		xdg-utils xinit xserver-xorg-core xwallpaper zathura vifm youtube-dl doas -y
}

enable_firewall() {
	echo
	printf '%s\n' "Enabling firewall" && sleep 1
	ufw enable
}

get_sl_tools() {
	echo
	printf '%s\n' "Getting custom Suckless tools repositories" && sleep 1
	cd "$SRC_DIR" || exit
	git clone https://github.com/I-LeCorbeau/dwm.git
	git clone https://github.com/I-LeCorbeau/dmenu.git
	git clone https://github.com/I-LeCorbeau/st.git
}

install_dwm() {
	echo
	printf '%s\n' "Building and installing custom Suckless tools" && sleep 1
	cd "$SRC_DIR"/dwm || exit
	make
	make clean install
}

install_dmenu() {
	cd "$SRC_DIR"/dmenu || exit
	make
	make clean install
}

install_st() {
	cd "$SRC_DIR"/st || exit
	make
	make clean install
}

setup_grub() {
	MODE=
	echo
	printf '%s\n' "setting up grub" && sleep 1
	if [ "$MODE" = bios ]; then
		apt install grub-pc -y
		grub-install /dev/DEVICE
		update-grub
	else	
		mkdir -p /boot/efi
		mount /dev/DEVICE1 /boot/efi
		apt install grub-efi-amd64 -y
		grub-install --target=x86_64-efi --efi-directory=/boot/efi
		update-grub
	fi
}

final() {
	echo
	printf '%s\n' "Installation finished. You might want to remove the 'install_in_chroot.sh' file from the root directory before rebooting"
	exit
}

main() {
	upd_repo
	inst_kern_init
	set_tz
	set_net
	mkhosts
	gen_locales
	set_cons
	set_pass
	set_wheel
	set_user
	install_base
	enable_firewall
	get_sl_tools
	install_dwm
	install_dmenu
	install_st
	setup_grub
	final
}

main
