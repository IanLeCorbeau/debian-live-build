#!/bin/sh

## debinstall.sh by Ian LeCorbeau: a simple Debian installer written in POSIX shell
## to install a custom iso with dwm. Does a debootstrap install and deploys dotfiles.

get_deps() {
	printf '%s\n' "Getting installer dependencies" &&
	apt update && apt install debootstrap arch-install-scripts -y
}

makepart() {
	echo
	printf "Before we begin making the partition, will you boot in bios mode or UEFI mode?: "
	read -r mode
	sed -i "s/MODE=/MODE=$mode/" install_in_chroot.sh
	echo
	printf '%s\n' "Available disks:"
	echo
	lsblk
	echo
	printf "Which disk should the system be installed on? (Eg: sdX): "
	read -r disk
	sed -i "s/DEVICE/$disk/g" install_in_chroot.sh
	echo
	printf "The system will be installed on /dev/$disk. Proceed? (Y/n): "
	read -r answer
	if [ "$answer" = n ]; then
		printf '%s\n' "Exiting script. Start again"
		exit
	else
		echo
		printf '%s\n' "Partitioning /dev/$disk."
		sfdisk --delete /dev/"$disk"
		partprobe /dev/"$disk" && sleep 1
		if [ "$mode" = "bios" ]; then
			(echo o) | fdisk /dev/"$disk"
			printf "How much space (in GBs) should be allocated to the swap partition?: "
			read -r swapspace
			(echo n; echo p; echo 1; echo ; echo +"$swapspace"G; echo w) | fdisk /dev/"$disk"
			sfdisk --part-type /dev/"$disk" 1 82
			echo
			printf "How much space (in GBs) should be allocated to the root partition?: "
			read -r rootspace
			(echo n; echo p; echo 2; echo ; echo +"$rootspace"G; echo w) | fdisk /dev/"$disk"
			echo
			printf  "How much space should be allocated to the home partition? (leave blank to use all remaining space): "
			read -r homespace
			if [ -z "$homespace" ]; then
				(echo n; echo p; echo 3; echo ; echo ; echo w) | fdisk /dev/"$disk"
			else
				(echo n; echo p; echo 3; echo ; echo +"$homespace"G; echo w) | fdisk /dev/"$disk"
			fi

			partprobe /dev/"$disk" && sleep 1
			printf '%s\n' "Creating Partitions" && sleep 1
			mkswap /dev/"$disk"1
			swapon /dev/"$disk"1
			mkfs.ext4 /dev/"$disk"2
			mkfs.ext4 /dev/"$disk"3

			printf '%s\n' "Mounting Partitions" && sleep 1
			mount /dev/"$disk"2 /mnt
			mkdir -p /mnt/home
			mount /dev/"$disk"3 /mnt/home	
		else
			echo
			printf '%s\n' "Partitioning /dev/$disk."
			sfdisk --delete /dev/"$disk"
			partprobe /dev/"$disk" && sleep 1
			(echo g) | fdisk /dev/"$disk"
			(echo n; echo p; echo 1; echo 2048; echo +600M; echo w) | fdisk /dev/"$disk"
			fdisk --part-type /dev/"$disk" 1 EF
			printf "How much swap to use (in GB)?: "
			read -r swapspace
			(echo n; echo p; echo 2; echo ; echo +"$swapspace"G; echo w) | fdisk /dev/"$disk"
			sfdisk --part-type /dev/"$disk" 2 82
			echo
			printf "How much space should the root partition use (in GB)?: "
			read -r rootspace
			(echo n; echo p; echo 3; echo ; echo +"$rootspace"G; echo w) | fdisk /dev/"$disk"
			echo
			printf "How much space should the home partition use (in GB)? (Hint: press enter to use all the remaining space): "
			read -r homespace
			if [ -z "$homespace" ]; then
				(echo n; echo p; echo 4; echo ; echo ; echo w) | fdisk /dev/"$disk"
			else
				(echo n; echo p; echo 4; echo ; echo +"$homespace"G; echo w) | fdisk /dev/"$disk"
			fi
	
			partprobe /dev/"$disk" && sleep 1
			printf '%s\n' "Creating Partitions" && sleep 1
			mkfs.fat -F 32 /dev/"$disk"1
			mkswap /dev/"$disk"2
			swapon /dev/"$disk"2
			mkfs.ext4 /dev/"$disk"3
			mkfs.ext4 /dev/"$disk"4
	
			printf '%s\n' "Mounting Partitions" && sleep 1
			mount /dev/"$disk"3 /mnt
			mkdir -p /mnt/home
			mkdir -p /mnt/boot
			mount /dev/"$disk"4 /mnt/home
	
		fi
	fi
}

bootstrap() {
	echo
	printf '%s\n' "Deboostraping base system" && sleep 1
	/usr/sbin/debootstrap --variant=minbase bullseye /mnt http://deb.debian.org/debian/
}

gen_fstab() {
	echo
	printf '%s\n' "Generating fstab..." && sleep 1
	genfstab -U /mnt >> /mnt/etc/fstab
}

apt_src_list() {
	echo
	printf '%s\n' "Generating apt sources.list" && sleep 1
	printf '%s\n' "deb http://deb.debian.org/debian/ bullseye main contrib non-free
deb-src http://deb.debian.org/debian/ bullseye main contrib non-free

deb http://security.debian.org/debian-security bullseye-security main contrib non-free
deb-src http://security.debian.org/debian-security bullseye-security main contrib non-free

deb http://deb.debian.org/debian/ bullseye-updates main contrib non-free
deb-src http://deb.debian.org/debian/ bullseye-updates main contrib non-free" > /mnt/etc/apt/sources.list
}

cp_files() {
	cp /etc/adjtime /mnt/etc/adjtime
	mkdir -p /mnt/etc/network/
	cp /etc/network/interfaces /mnt/etc/network/interfaces
	cp install_in_chroot.sh /mnt/install_in_chroot.sh
	chmod +x /mnt/install_in_chroot.sh
}

cp_dotfiles() {
	cp -r /etc/skel /mnt/etc/
	rm /mnt/etc/skel/install.sh
	rm /mnt/etc/skel/install_in_chroot.sh
}

set_permissions() {
	cd /mnt/etc/skel/.local/bin || exit
	for file in chwall-dmenu mpvload netcon poweroffreboot statusbar.sh usbmount usbunmount usbpoweroff ; do chmod +x "$file" ; done
}

initsys() {
	echo
	printf "Which init system to use? (choice: systemd or OpenRC): "
	read -r initsys
	sed -i "s/INITSYS=/INITSYS=$initsys/g" install_in_chroot.sh
}

timezone() {
	echo
	printf "Enter your time zone (eg: America/New_York): "
	read -r tz
	sed -i "s:TIMEZONE:$tz:g" install_in_chroot.sh
}

set_hostname() {
	echo
	sleep 1
	printf "Hostname for this machine: "
	read -r hn
	sed -i "s/HOSTNAME/$hn/" install_in_chroot.sh
}

locales() {
	sleep 1 && echo
	printf "Enter locale (eg: en_US.UTF-8): "
	read -r loc
	sed -i "s/LOCALE/$loc/g" install_in_chroot.sh
}

xkb_cons() {
	sleep 1 && echo
	printf "Keymap for the console ('?' to list available keymaps): "
	read -r km
	sed -i "s/KEYMAP/$km/g" install_in_chroot.sh
}

username() {
	echo
	printf "Name of the default user: "
	read -r name
	sed -i "s/USERNAME/$name/g" install_in_chroot.sh
}

get_in_chroot() {
	arch-chroot /mnt ./install_in_chroot.sh
}

main() {
	get_deps
	makepart
	initsys
	timezone
	set_hostname
	locales
	xkb_cons
	username
	bootstrap
	gen_fstab
	apt_src_list
	cp_files
	cp_dotfiles
	set_permissions
	get_in_chroot
}

main
