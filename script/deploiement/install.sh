#!/bin/bash

# /////////////////////////////////////////////////
#            Developpé par Jordan B.
#        Script de déploiement Arch-linux
# /////////////////////////////////////////////////


# ///////////////////// Variables de configuration ////////////////////////////
MODULE_LIST="raid1 raid0 dm-mod"
RAID_LIST="/dev/md0 /dev/md1 /dev/md3"
RAID_LEVEL1="1" # 0,1,2,3,4 pour le raid 0,1,2,3,4
RAID_DISK1=""
RAID_DISK2=""











# //////////////////////////////////////////////////////////////////
# //////////////////////////////////////////////////////////////////
function LoadModules {
	for module in $MODULE_LIST; do
		echo $module
		# modprobe $module
	done
}

function CreateRaid {
	for RAID in $RAID_LIST; do
		# yes | mdadm --create $RAID --level=$RAID_LEVEL --raid-devices=2 $RAID_DISK1 $RAID_DISK2
		echo $RAID
	done
}


function CreatePartition {
	(
	echo o # Create a new empty DOS partition table
	echo n # Add a new partition
	echo p # Primary partition
	echo 1 # Partition number
	echo   # First sector (Accept default: 1)
	echo   # Last sector (Accept default: varies)
	echo w # Write changes
	) | sudo fdisk $DISK
}

# mkfs.ext2 /dev/sdb -L label_volume


function main {
	loadModules
	CreateRaid
}
