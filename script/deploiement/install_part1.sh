#!/bin/bash

# /////////////////////////////////////////////////
#            Developpé par Jordan B.
#        Script de déploiement Arch-linux
# /////////////////////////////////////////////////

# ///////////////////// Variables de configuration ////////////////////////////

# Reset Bash Count 
SECONDS=0

# Module CONFIG
MODULE_LIST="raid1 raid0 dm-mod"

# DISK CONFIG
DISK_LIST="$(ls /dev/sd* | awk '{ print $1 }')"
LABEL_LIST="PART_MBR PART_HOME PART_ROOT PART_SRV PART_PARTAGE PART_TMP PART_SWAP"

if [ "$EUID" -ne 0 ]
  then echo -e "Veuillez démarrer le script en root !"
  exit
fi

# //////////////////////////////////////////////////////////////////

function LoadModules {
	echo -e "\nChargement des Modules : $MODULE_LIST\n"
	for module in $MODULE_LIST; do
		# echo -e "$module"
		modprobe $module
	done
}

function CreatePartition {
	for DISK in $DISK_LIST; do 
		(
		echo o # Create a new empty DOS partition table
		echo n # Add a new partition
		echo p # Primary partition
		echo 1 # Partition number
		echo   # First sector (Accept default: 1)
		echo   # Last sector (Accept default: varies)
		echo w # Write changes
		) | fdisk $DISK
	done
}


# Notes Utilisation du RAID 10
function CreateRaid {
	echo -e "\nCréation des Raids : $RAID_LIST\n"
	yes | mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sda1 /dev/sdb1
	yes | mdadm --create /dev/md1 --level=1 --raid-devices=2 /dev/sdc1 /dev/sdd1
	yes | mdadm --create /dev/md3 --level=0 --raid-devices=2 /dev/md0  /dev/md1 
}

function CreateLVM {
	echo -e "\nCréation du Volume Physique\n"
	pvcreate /dev/md3
	echo -e "\nCréation du Volume Physique\n"	
	vgcreate raid10 /dev/md3
	echo -e "\nCréation du Volume Physique\n"
	lvcreate -L 10GB --name lv_home raid10 #/home
	lvcreate -L 4GB --name lv_srv raid10 #/srv
	lvcreate -L 4GB --name lv_tmp raid10 #/tmp
	lvcreate -L 4GB --name lv_partage raid10 #/partage
	lvcreate -L 4GB --name lv_swap raid10 #SWAP
	lvcreate -l 100%FREE --name lv_root raid10 #/
}

function FormatPartition {
	echo -e "\nFormatage des Partitions\n"
	mkfs.ext4 /dev/sde1 -L PART_MBR
	mkfs.ext4 /dev/mapper/raid10-lv_home -L PART_HOME
	mkfs.ext4 /dev/mapper/raid10-lv_root -L PART_ROOT
	mkfs.ext4 /dev/mapper/raid10-lv_srv  -L PART_SRV
	mkfs.ext4 /dev/mapper/raid10-lv_partage -L PART_PARTAGE
	mkfs.ext4 /dev/mapper/raid10-lv_tmp -L PART_TMP
	mkswap /dev/mapper/raid10-lv_swap -L PART_SWAP
}

function MountPartition {
	echo -e "\nMontage des Partitions\n"
	mount -v /dev/mapper/raid10-lv_root /mnt #/
	mkdir -pv /mnt/{boot,srv,home,partage,tmp,hostlvm}
	mount -v /dev/sde1 /mnt/boot #/boot
	mount -v /dev/mapper/raid10-lv_srv /mnt/srv
	mount -v /dev/mapper/raid10-lv_home /mnt/home
	mount -v /dev/mapper/raid10-lv_partage /mnt/partage
	mount -v /dev/mapper/raid10-lv_tmp /mnt/tmp
	swapon /dev/mapper/raid10-lv_swap 
	echo -e "\n\n"
}

function InstallSystem {
	
	# Maj des dépots        
	yes 'n' | pacman -Suy reflector 
	reflector --verbose -l 5 --sort rate --save /etc/pacman.d/mirrorlist

	echo -e "\nInstallation du système\n"
	pacstrap /mnt base net-tools zsh git htop zshdb zsh-completions zsh-autosuggestions \
	              zsh-history-substring-search zsh-lovers zsh-syntax-highlighting zssh  \
	              zsh-theme-powerlevel9k powerline-fonts awesome-terminal-fonts acpi    \
	              grub freetype2 fuse2 libisoburn mtools dosfstools openssh xorg-xauth  \
	              x11-ssh-askpass samba nfs-utils python mkinitcpio-nfs-utils mariadb   \
	              perl-dbd-mysql galera rsync ntp apache curl bind geoip-database-extra \
	              arch-install-scripts vsftpd python-pip 
	
	echo -e "\nGeneration du fichier FSTAB\n"
	genfstab -U -p /mnt > /mnt/etc/fstab
	mount -v --bind /run/lvm /mnt/hostlvm
}

function CheckServer {

	echo -e "\nVerification du raid\n"
	cat /proc/mdstat
	echo -e "\n---------------------------\n"

	echo -e "\nVérification du paritionnement\n"
	lsblk
	echo -e "\n---------------------------\n"

	echo -e "\nVerification de l'espace disponible\n"
	df -h
	echo -e "\n---------------------------\n"

	echo -e "\nVérification des PV\n"
	pvs
	echo -e "\n---------------------------\n"

	echo -e "\nVérification des VG\n"
	vgs
	echo -e "\n---------------------------\n"

	echo -e "\nVérification des LV\n"
	lvs
	echo -e "\n---------------------------\n"
	
	echo -e "\nVerification de la RAM\n"
	free -h
	echo -e "\n---------------------------\n"
}

function LaunchScript {
	echo -e "\nLancement de l'installation Partie 2\n"
	arch-chroot /mnt /bin/bash <<EOF

	cd /mnt
	git clone https://github.com/SH4RKNANDO/ProjetArchLinux.git
	cd ProjetArchLinux/script/deploiement/
	groupadd sshusers
	chmod +x -v install_part2.sh
	chmod +x -v install_part3.sh
	
	bash install_part2.sh
EOF
}

function main {
	LoadModules
	CreatePartition
	CreateRaid
	CreateLVM
	FormatPartition
	MountPartition
	InstallSystem
	CheckServer
	LaunchScript
	
	# Cleanning
	umount -Rv /mnt/hostlvm
	rm -rfv  /mnt/hostlvm

	ELAPSED="Elapsed: $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"
	echo $ELAPSED
}

main
