#!/bin/bash

#//////////////////////////////////////////////
#//        DEVELOPPE PAR JORDAN B.           //
#//      Script d'installation des Service   //
#//////////////////////////////////////////////

JAIL_DIR="/home/jail"

#///////////////////////////////// 
#//         SERVICE SSH         //
#/////////////////////////////////

function InstallSSH {
	# Copy Banner
	cp -avr file_config/motd_ssh /etc/motd_ssh
	
	# Backup File SSH
	cp -avr /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
	cp -avr file_config/sshd_config /etc/sshd_config	
	
	systemctl restart sshd
	systemctl status sshd
}

#//////////////////////////////// 
#//  JAIL SSH CONFIG           //
#////////////////////////////////

# create Jail Directory
function CreateDirectory {

	echo -e "\nCreation des répertoire\n"
	mkdir -pv $JAIL_DIR/{home,etc/skel}

	echo -e "\nModification des droits\n"
	chown -v root:root $JAIL_DIR
	chmod -v go-w $JAIL_DIR
	
	# cp -avr /etc/skel/ /home/jail/etc/skel/
	cp -ar /etc/skel/ $JAIL_DIR/etc/skel/
	
	echo -e "\nCreation du groupe sshusers\n"
	groupadd sshusers
}

function InstallDir {
	yes 'y' | pacman -S arch-install-scripts
	echo -e "\nCreation de la prison ssh jail\n"
	pacstrap $JAIL_DIR bash nano which tar less grep zsh coreutils \
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
		
	systemctl daemeon-reload
	systemctl enable jail_mount.service
	systemctl start jail_mount.service 
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
	echo -e "\nInstallation de Samba\n"
	yes 'y' | pacman -S samba
	cp -avr file_config/smb.conf /etc/samba/smb.conf
	
	echo -e "\nActivation de Samba\n"
	systemctl enable nmb smb
	systemctl start nmb smb
	systemctl status nmb smb
	
	yes $USER_PASSWORD | smbpasswd -a admin
}

#///////////////////////////////////////////////////////////////////////////////////////////////////////////#///////////////////////////////////////////////////////////////////////////////////////////////////////////

#///////////////////////////////// 
#//       SERVICE NFS           //
#/////////////////////////////////

function InstallNFS {
	echo -e "\nInstallation de NFS\n"
	yes 'y' | pacman -S nfs-utils python mkinitcpio-nfs-utils
	
	echo -e "\nActivation du Service de NFS\n"
	systemctl enable nfs-server
	systemctl start nfs-server
	systemctl status nfs-server
	
	# TODO 
	# exportfs -av
	# systemctl restart nfs-server
	# systemctl status nfs-server
}

#///////////////////////////////////////////////////////////////////////////////////////////////////////////#///////////////////////////////////////////////////////////////////////////////////////////////////////////


#///////////////////////////////// 
#//       SERVICE MYSQL         //
#/////////////////////////////////

function InstallMysql {
	echo -e "\nInstallation de Mysql\n"
	yes 'y' | pacman -S mariadb perl-dbd-mysql galera rsync
	
	mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
	
	echo "[client]
default-character-set = latin1

[mysqld]
collation_server = latin1_swedish_ci
character_set_server = latin1
 
[mysql]
default-character-set = latin1" >> /etc/mysql/my.cnf
	 
	systemctl enable mysqld # Démarrer le service au démarrage
	systemctl start mysqld  # Redémarrer le service
	systemctl status mysqld # Vérification
	
	mysql_secure_installation
}



#///////////////////////////////////////////////////////////////////////////////////////////////////////////#///////////////////////////////////////////////////////////////////////////////////////////////////////////


#///////////////////////////////// 
#//       SERVICE NTPD         //
#/////////////////////////////////

function InstallNtpd {
	echo -e "\nInstallation de Ntpd\n"
	yes 'y' | pacman -S ntp
	
	echo -e "\nBackup du Fichier d'installation\n"
	cp -avr /etc/ntp.conf /etc/ntp.conf.bak
	
	echo "# Configuration du Pool NTP
server 0.be.pool.ntp.org
server 1.be.pool.ntp.org
server 2.be.pool.ntp.org
server 3.be.pool.ntp.org" >> /etc/ntp.conf
		 
	echo "\nVeuillez entrer l'heure et la date du système (2019-03-20 14:45:30) :"
	read DATE
	timedatectl set-time "$DATE"
	timedatectl set-timezone Europe/Brussels
	
	systemctl start ntpd
	systemctl enable ntpd
	systemctl status ntpd
	
	ntptime
}



#///////////////////////////////////////////////////////////////////////////////////////////////////////////#///////////////////////////////////////////////////////////////////////////////////////////////////////////


#///////////////////////////////// 
#//       SERVICE HTTPD         //
#/////////////////////////////////

function InstallHTTPD {
	echo -e "\nInstallation de HTTPD\n"
	yes 'y' | pacman -S apache curl
	
	echo -e "\nBackup du fichier de configuration de HTTPD\n"
	cp -avr /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak
	cp -avr file_config/httpd.conf /etc/httpd/conf/httpd.conf
	echo -e "\nTODO CHANGE IP TO FILE CONFIG\n"
	
	echo -e "\nBackup du fichier de configuration par defaut de HTTPD\n"
	cp -avr /etc/httpd/conf/extra/httpd-default.conf /etc/httpd/conf/extra/httpd-default.conf.bak
	cp -avr file_config/httpd-default.conf /etc/httpd/conf/extra/httpd-default.conf
	
	echo -e "\nBackup du fichier de configuration des vhosts de HTTPD\n"
	cp -avr /etc/httpd/conf/extra/httpd-vhosts.conf /etc/httpd/conf/extra/httpd-vhosts.conf.bak
	cp -avr file_config/httpd-vhosts.conf /etc/httpd/conf/extra/httpd-vhosts.conf


	apachectl configtest
	
	systemctl enable httpd
	systemctl start httpd
	systemctl status httpd
}





#///////////////////////////////////////////////////////////////////////////////////////////////////////////#///////////////////////////////////////////////////////////////////////////////////////////////////////////


#///////////////////////////////// 
#//       SERVICE DNS           //
#/////////////////////////////////

function InstallDNS {
	echo -e "\nInstallation de DNS (BIND9) \n"
	yes 'y' | pacman -S bind geoip-database-extra
	
	echo -e "\nBackup du fichier de configuration de BIND9\n"
	cp -avr /etc/named.conf  /etc/named.conf.back
	cp -avr file_config/named.conf /etc/named.conf

	systemctl start named.service
	systemctl enable named.service
	systemctl status named.service
	
	echo -e "\nVerification du DNS\n"
	named-checkconf /etc/named.conf
	named -g -p 53
}



#///////////////////////////////////////////////////////////////////////////////////////////////////////////#///////////////////////////////////////////////////////////////////////////////////////////////////////////

function RemountBoot {
	umount -Rv /boot
	mount -v /dev/sde1 /boot
}


function main {
	RemountBoot
	ConfigSSH
	InstallSamba
	InstallNFS
	InstallMysql
	InstallNtpd
	InstallHTTPD
	InstallDNS
}









