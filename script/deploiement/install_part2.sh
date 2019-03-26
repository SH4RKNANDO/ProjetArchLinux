#!/bin/bash

#///////////////////////////////////////////
#//        DEVELOPPE PAR JORDAN B.       //
#//      Script de configuration de base //
#//////////////////////////////////////////

ROOT_PASSWORD="arch-server"
USER_PASSWORD="arch-server"
USER_NAME="admin"
GRUB_DISK="/dev/sde"
IPSTATIC="10.0.0.39/24"
IPROUTER="10.0.0.1"
CHECKIP='y'
HOSTNAME="arch-server"

#////////////////////////////////// 
#//    CONFIG BASIC SERVER       //
#/////////////////////////////////

function ConfigBasic {
	echo -e "\nConfiguration Basique du Server\n"
	ln -sv /hostlvm /run/lvm
	echo KEYMAP=be-latin1 >> /etc/vconsole.conf
	echo FONT=lat9u-16 >> /etc/vconsole.conf
	
	echo -e "\nBackup du fichier de configuration des langues\n"
	cp -avr /etc/locale.gen /etc/locale.gen.bak
	
	echo "\nConfiguration des locales\n"
	sed -i '/en_US.UTF-8/s/^#//g' /etc/locale.gen
	sed -i '/fr_BE.UTF-8/s/^#//g' /etc/locale.gen
	sed -i '/fr_BE ISO-8859-1/s/^#//g' /etc/locale.gen
	sed -i '/fr_BE@euro/s/^#//g' /etc/locale.gen
	locale-gen
	echo "LANG=fr_BE.UTF-8" >> /etc/locale.conf
	echo "LC_COLLAPSE=C" >> /etc/locale.conf
	export LANG=fr_BE.UTF-8
	locale
	
	echo "\nModification du Hostname\n"
	echo $HOSTNAME > /etc/hostname
	
	echo "\nAjout du Sticky Bit sur le répertoire /partage\n"
	chmod -v 1660 /partage
	
	echo -e "\nSynchronisation de l'heure et du fuseaux Europe/Brussels\n"
	ln -sfv /usr/share/zoneinfo/Europe/Brussels /etc/localtime
	hwclock --systohc --utc
}

function SetIpStatic {

	NETWORK_INTERFACE=$(ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}' | egrep "en")
	NETWORK_INTERFACE=$(echo "$NETWORK_INTERFACE" | awk '{ print $1 }')
	
	echo -e "\nVoici un Résumé de votre interface Réseaux\n"
	echo -e "Network Interface : $NETWORK_INTERFACE"
	echo -e "IP : $IPSTATIC"
	echo -e "Gateway : $IPROUTER\n"
	
	FILE="/etc/netctl/$NETWORK_INTERFACE"
	
	echo "Description='IP Static NetworkInterface'
Interface=$NETWORK_INTERFACE
Connection=ethernet
IP=static
Address=('"$IPSTATIC"')
Gateway='"$IPROUTER"'
DNS=('1.1.1.1' '"$IPSTATIC"')" > $FILE

	echo -e "\nActivation de l'addresse IP Static\n"
	netctl enable $NETWORK_INTERFACE
}


function PacmanConfig {
	echo -e "\nBackup File pacman.conf\n"
	cp -avr /etc/pacman.conf /etc/pacman.conf.bak
	echo -e "\nConfiguration de pacman\n"
	cp -avr file_config/pacman.conf /etc/pacman.conf
	yes 'y' | pacman -Syy
}

function ConfigUser {
	echo -e "\nCreate New User admin and change root password\n"
	groupadd sambashare 
	groupadd sshusers
	
	# change root password
	yes $ROOT_PASSWORD | passwd
	useradd -m -g users -G wheel,storage,power,sambashare -s /bin/bash $USER_NAME
	yes $USER_PASSWORD | passwd $USER_NAME
}

function GenerateRamdisk {
	echo -e "\nBackup du fichier /etc/mkinitcpio.conf\n"
	cp -avr /etc/mkinitcpio.conf /etc/mkinitcpio.conf.bak
	cp -avr file_config/mkinitcpio.conf /etc/mkinitcpio.conf
	mkinitcpio -p linux
}

function InstallGrub {
	echo -e "\nConfiguration de Grub2\n"
	grub-mkconfig -o /boot/grub/grub.cfg
	grub-install $GRUB_DISK --recheck
	cp -avr file_config/install_grub /usr/bin/install_grub
	chmod 755 -v /usr/bin/install_grub
	
	echo -e "\nInstallation de Grub2 dans le MBR\n"
	grub-mkconfig -o /boot/grub/grub.cfg
	grub-install $GRUB_DISK --recheck
}

function SecuFstab {

	cp -avr /etc/fstab /etc/fstab.bak
	
	echo "Sécurisation des partitions"
	
	# Root Parition
	cat /etc/fstab |  egrep root | awk '{ print }' > /etc/fstab2
	
	# Boot Partition Read only
	cat /etc/fstab |  egrep /boot | awk '$4="nodev,ro,relatime" { print }' >> /etc/fstab2

	# SRV Partition
	cat /etc/fstab |  egrep /srv | awk '$4="nodev,nosuid,rw,relatime,stripe=256" { print }' >> /etc/fstab2
	
	# Home Partition
	cat /etc/fstab |  egrep /home | awk '$4="nodev,nosuid,rw,relatime,stripe=256" { print }' >> /etc/fstab2

	# Partition Partage
	cat /etc/fstab |  egrep /partage | awk '$4="nodev,nosuid,noexec,rw,relatime,stripe=256" { print }' >> /etc/fstab2	

	# Parition TMP
	cat /etc/fstab |  egrep /tmp | awk '$4="nodev,nosuid,noexec,rw,relatime,stripe=256" { print }' >> /etc/fstab2
	
	# SWAP Partition
	cat /etc/fstab |  egrep swap | awk '$4="defaults,nodev,nosuid,noexec,pri=-2" { print }' >> /etc/fstab2
	
	cat /etc/fstab2 > /etc/fstab
	rm -rfv /etc/fstab2
	
	mount -a
}


function InstallZsh {
	echo -e "\nInstallation de zssh\n"
	sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

	cp -avr file_config/.zshrc ~/
	cp -avr file_config/.zshrc /home/$USER_NAME/
	chown -Rv $USER_NAME:users /home/$USER_NAME/.zshrc
	
	# copies du fichier dans le skel
	cp -avr file_config/.zshrc /etc/skel
	cp -ar ~/.oh-my-zsh /etc/skel	
}

function ConfigServer {
	ConfigBasic
	SetIpStatic
	PacmanConfig
	ConfigUser
	GenerateRamdisk
	InstallGrub
	SecuFstab
	InstallZsh
	echo -e "\nActivation du Service SSH au demarrage\n"
	systemctl enable sshd
}

ConfigServer

#///////////////////////////////////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////////////////////////////////
