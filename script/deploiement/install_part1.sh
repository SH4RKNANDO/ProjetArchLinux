#!/bin/bash

# /////////////////////////////////////////////////
#            Developpé par Jordan B.
#        Script de déploiement Arch-linux
# /////////////////////////////////////////////////

# ///////////////////// Variables de configuration ////////////////////////////

# Module CONFIG
MODULE_LIST="raid1 raid0 dm-mod"

# DISK CONFIG
DISK_LIST="/dev/sda /dev/sdb /dev/sdc /dev/sdd /dev/sde"

if [ "$EUID" -ne 0 ]
  then echo -e "Please run as root"
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
	lvcreate -L 1GB --name lv_home raid10 #/home
	lvcreate -L 4GB --name lv_srv raid10 #/srv
	lvcreate -L 4GB --name lv_tmp raid10 #/tmp
	lvcreate -L 4GB --name lv_partage raid10 #/partage
	lvcreate -L 4GB --name lv_swap raid10 #SWAP
	lvcreate -l 100%FREE --name lv_root raid10 #/
}

function FormatPartition {
	mkfs.ext4 /dev/sde1 -L PART_MBR
	mkfs.ext4 /dev/mapper/raid10-lv_home -L PART_HOME
	mkfs.ext4 /dev/mapper/raid10-lv_root -L PART_ROOT
	mkfs.ext4 /dev/mapper/raid10-lv_srv  -L PART_SRV
	mkfs.ext4 /dev/mapper/raid10-lv_partage -L PART_PARTAGE
	mkfs.ext4 /dev/mapper/raid10-lv_tmp -L PART_TMP
	mkswap /dev/mapper/raid10-lv_swap -L PART_SWAP
}

function MountPartition {
	mount -v /dev/mapper/raid10-lv_root /mnt #/
	mkdir -pv /mnt/{boot,srv,home,partage,tmp,hostlvm}
	mount -v /dev/sde1 /mnt/boot #/boot
	mount -v /dev/mapper/raid10-lv_srv /mnt/srv
	mount -v /dev/mapper/raid10-lv_home /mnt/home
	mount -v /dev/mapper/raid10-lv_partage /mnt/partage
	mount -v /dev/mapper/raid10-lv_tmp /mnt/tmp
	swapon /dev/mapper/raid10-lv_swap 
}

function InstallSystem {
	pacman -Suy
	pacstrap /mnt base net-tools zsh git htop zsh-autosuggestions zsh-completions zshdb \
	              zsh-history-substring-search zsh-lovers zsh-syntax-highlighting zssh  \
	              zsh-theme-powerlevel9k powerline-fonts awesome-terminal-fonts acpi 
	              
	genfstab -U -p /mnt > /mnt/etc/fstab
	mount -v --bind /run/lvm /mnt/hostlvm
}


function CheckServer {
	echo
	
	echo "Verification du raid"
	echo
	cat /proc/mdstat
	echo
	echo "---------------------------"


	echo
	echo "Vérification du paritionnement"
	echo
	lsblk
	echo
	echo "---------------------------"

	echo
	echo "Verification de l'espace disponible"
	echo
	df -h
	echo
	echo "---------------------------"


	echo
	echo "Vérification des PV"
	echo
	pvs
	echo
	echo "---------------------------"


	echo
	echo "Vérification des VG"
	echo
	vgs
	echo
	echo "---------------------------"


	echo
	echo "Vérification des LV"
	echo
	lvs
	echo
	echo "---------------------------"


	echo
	echo "Verification de la RAM"
	echo
	free -h
	echo
	echo "---------------------------"
}

function ChrootConfig {
	cp -avr install_part2.sh /mnt/install_part2.sh
	chroot /home/mayank/chroot/codebase /bin/bash <<"EOT"

chmod -v 755 install_part2.sh
bash install_part2.sh

EOT

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
	reboot
}

main

















