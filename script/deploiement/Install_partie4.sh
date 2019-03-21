#!/bin/bash


#///////////////////////////////// 
#//         SERVICE SSH         //
#/////////////////////////////////

function InstallSSH {
	pacman -S openssh xorg-xauth x11-ssh-askpass
	# Activer le service au démarrage
	systemctl enable sshd
	
	# Copy Banner
	cp -avr file_config/motd_ssh /etc/motd_ssh
	
	# Backup File SSH
	cp -avr /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
	cp -avr file_config/sshd_config /etc/sshd_config	
}

#//////////////////////////////// 
#//  JAIL SSH CONFIG           //
#////////////////////////////////

# create Jail Directory
function CreateDirectory {

	echo -e "\nCreation des répertoire\n"
	mkdir -pv /home/jail/{home,etc/skel}

	echo -e "\nModification des droits\n"
	chown -v root:root /home/jail
	chmod -v go-w /home/jail
	
	# cp -avr /etc/skel/ /home/jail/etc/skel/
	cp -ar /etc/skel/ /home/jail/etc/skel/
	
	echo -e "\nCreation du groupe sshusers\n"
	groupadd sshusers
}

function InstallDir {
	pacman -S arch-install-scripts
	echo -e "\nCreation de la prison ssh jail\n"
	pacstrap /home/jail bash nano which tar less grep zsh coreutils \
			        zsh-autosuggestions zsh-completions zshdb       \
		            zsh-history-substring-search zsh-lovers         \
		            zsh-syntax-highlighting zsh-theme-powerlevel9k  \
			        powerline-fonts awesome-terminal-fonts mariadb-clients
			        
	pacman -Rns arch-install-scripts
}

function ServiceMountJail {
	
	echo -e "\nCreation su service jail_mount.service\n"
	cp -avr file_config/jail_mount /usr/bin/jail_mount
	chmod -v 755 /usr/bin/jail_mount
	
	cp -avr file_config/jail_mount.service /etc/systemd/system/jail_mount.service
	chmod -v 777 /etc/systemd/system/jail_mount.service
		
	systemctl daemon-reload
	systemctl enable jail_mount.service 
}

function SshJailPerm {

	chroot $JAIL_DIR /bin/bash <<"EOT"

chown -v root:sshusers /home
chmod -v 770 /home/

chmod -v 0600 /tmp
chmod -v 0600 /boot
chmod -v 700 /var/tmp 
chmod -v 700 /var/games

chmod 550 -v /proc	
EOT

}

function ConfigSSH {
	InstallSSH
	CreateDirectory
	InstallDir
	ServiceMountJail
	SshJailPerm
}	


#///////////////////////////////////////////////////////////////////////////////////////////////////////////#///////////////////////////////////////////////////////////////////////////////////////////////////////////


#///////////////////////////////// 
#//       SERVICE SAMBA         //
#/////////////////////////////////

function InstallSamba {
	pacman -S samba
	cp -avr file_config/jail_mount.service /etc/samba/smb.conf
	
	systemctl enable nmb smb
	
	yes $USER_PASSWORD | smbpasswd -a admin
}

#///////////////////////////////////////////////////////////////////////////////////////////////////////////#///////////////////////////////////////////////////////////////////////////////////////////////////////////

#///////////////////////////////// 
#//       SERVICE NFS           //
#/////////////////////////////////

function InstallNFS {
	pacman -S nfs-utils python mkinitcpio-nfs-utils
	systemctl enable nfs-server
}

#///////////////////////////////////////////////////////////////////////////////////////////////////////////#///////////////////////////////////////////////////////////////////////////////////////////////////////////


#///////////////////////////////// 
#//       SERVICE MYSQL         //
#/////////////////////////////////

function InstallMysql {
	echo -e "\nInstallation de Mysql\n"
	pacman -S mariadb perl-dbd-mysql galera rsync
	
	echo -e "\nActivation de Mysql\n"
	systemctl enable nfs-server
}

#///////////////////////////////////////////////////////////////////////////////////////////////////////////#///////////////////////////////////////////////////////////////////////////////////////////////////////////


function main {
	ConfigServer
	ConfigSSH
	ConfigSamba
	InstallSamba
	InstallNFS
}









