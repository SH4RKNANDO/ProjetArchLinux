#!/bin/bash

#//////////////////////////////////////////////
#//        DEVELOPPE PAR JORDAN B.           //
#//      Script d'installation des Service   //
#//////////////////////////////////////////////

# DEBUG =1 => ON | DEBUG =0 => OFF
DEBUG=0

JAIL_DIR="/home/jail"
IPSERVER=$(hostname --ip-addresses)
MYSQL_ROOT_PASSWORD="arch-server"


# Vérification des droits
if [ "$EUID" -ne 0 ]
  then echo -e "Veuillez démarrer le script en root !"
  exit
fi

function top {
clear
echo -e "
		#//////////////////////////////////////////////
		#//        DEVELOPPE PAR JORDAN B.           //
		#//      Script d'installation des Service   //
		#//////////////////////////////////////////////\n\n"
}

#///////////////////////////////// 
#//         SERVICE SSH         //
#/////////////////////////////////

function InstallSSH {
	echo -e "\nCréation de la bannière ssh\n"
	# Copy Banner
	cp -avr file_config/motd_ssh /etc/motd_ssh
	
	# Backup File SSH
	echo -e "\nBackup du fichier de configuration de sshd\n"
	cp -avr /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
	
	echo -e "\nConfiguration du deamon ssh\n"
	cp -avr file_config/sshd_config /etc/sshd_config	
	
	systemctl restart sshd
	
	if [ $DEBUG -eq 1 ]; then 
		systemctl status sshd
	fi
	
	echo -e "\n\n"
}

#//////////////////////////////// 
#//  JAIL SSH CONFIG           //
#////////////////////////////////

# create Jail Directory
function CreateDirectory {
	echo -e "\nCréation des répertoires\n"
	mkdir -pv $JAIL_DIR/{home,etc/skel}

	echo -e "\nModification des droits\n"
	chown -v root:root $JAIL_DIR
	chmod -v go-w $JAIL_DIR
	
	# cp -avr /etc/skel/ /home/jail/etc/skel/
	cp -ar /etc/skel/ $JAIL_DIR/etc/skel/
	
	echo -e "\nCreation du groupe sshusers"
	groupadd sshusers
	echo -e "\n\n"
}

function InstallDir {
	echo -e "\n\nCreation de la prison ssh jail\n"
	pacstrap $JAIL_DIR base bash nano which tar less grep zsh coreutils \
			        zsh-autosuggestions zsh-completions zshdb       \
		            zsh-history-substring-search zsh-lovers         \
		            zsh-syntax-highlighting zsh-theme-powerlevel9k  \
			        powerline-fonts awesome-terminal-fonts mariadb-clients
			        
	yes 'o' | pacman -Rns arch-install-scripts
	
	echo -e "\nAjout  du groupe sshusers dans /etc/group\n"
	cat /etc/group | egrep "sshusers" >> $JAIL_DIR/etc/group
}

function ServiceMountJail {
	echo -e "\n\nCreation su service jail_mount.service\n"
	cp -avr file_config/jail_mount /usr/bin/jail_mount
	chmod -v 755 /usr/bin/jail_mount
	cp -avr file_config/jail_mount.service /etc/systemd/system/jail_mount.service
	chmod -v 644 /etc/systemd/system/jail_mount.service
	
	echo -e "\nActivation du Service jail_mount\n"
	systemctl daemon-reload
	systemctl enable jail_mount.service
	systemctl start jail_mount.service 
	
	if [ $DEBUG -eq 1 ]; then 
		systemctl status jail_mount 
	fi
}

function SshJailPerm {
	echo -e "\n\nModification des Permissions ssh jail\n"
	chroot $JAIL_DIR /usr/bin/bash <<"EOT"

chown -Rv root:sshusers /home
chmod -v 770 /home/

chmod -v 0600 /tmp
chmod -v 0600 /boot
chmod -v 700 /var/tmp 
chmod -v 700 /var/games

chmod 550 -v /proc	

EOT

}

function ConfigSSH {
	top
	InstallSSH
	CreateDirectory
	InstallDir
	ServiceMountJail
	SshJailPerm
	# Deprecated Config SSH
	sed -i '/KeyRegenerationInterval/d' /etc/ssh/sshd_config
	sed -i '/ServerKeyBits/d' /etc/ssh/sshd_config
	sed -i '/RSAAuthentication/d' /etc/ssh/sshd_config
	sed -i '/RhostsRSAAuthentication/d' /etc/ssh/sshd_config
	sed -i '/UsePrivilegeSeparation/d' /etc/ssh/sshd_config
}


#///////////////////////////////////////////////////////////////////////////////////////////////////////////#///////////////////////////////////////////////////////////////////////////////////////////////////////////


#///////////////////////////////// 
#//       SERVICE SAMBA         //
#/////////////////////////////////

function InstallSamba {
	top
	echo -e "\n\nConfiguration de Samba\n"
	cp -avr file_config/smb.conf /etc/samba/smb.conf
	
	echo -e "\nActivation de Samba\n"
	systemctl enable nmb smb
	systemctl start nmb smb
	
	if [ $DEBUG -eq 1 ]; then 
		systemctl status nmb smb
	fi
	
	echo -e "\nAjout de l'utilisateur admin a samba\n"
	yes $USER_PASSWORD | smbpasswd -a admin
}



#///////////////////////////////////////////////////////////////////////////////////////////////////////////#///////////////////////////////////////////////////////////////////////////////////////////////////////////

#///////////////////////////////// 
#//       SERVICE NFS           //
#/////////////////////////////////

function InstallNFS {
	top
	echo -e "\nDémarrage du Service de NFS\n"
	systemctl start nfs-server
	
	echo -e "\nConfiguration des entrées NFS dans le fichier /etc/exports\n"
	SAMBAGUID=$(cat /etc/group | egrep "sambashare" | awk 'BEGIN { FS=":" } /1/ { print $3 }')
	IPNFS=$(echo $IPSERVER | awk 'BEGIN { FS="." } /1/ { $4 ="*"} { print $1 "." $2 "." $3 "." $4}')
	echo "/partage $IPNFS(rw,anongid=$SAMBAGUID,all_squash,subtree_check)" >> /etc/exports
	exportfs -av
	
	echo -e "\nActivation du Service NFS\n"
	systemctl enable nfs-server
	systemctl restart nfs-server
	
	
	if [ $DEBUG -eq 1 ]; then 
		systemctl status nfs-server
	fi
}



#///////////////////////////////////////////////////////////////////////////////////////////////////////////#///////////////////////////////////////////////////////////////////////////////////////////////////////////


#///////////////////////////////// 
#//       SERVICE MYSQL         //
#/////////////////////////////////

function InstallMysql {
	top
	echo -e "\n\nConfiguration du moteur Mysql\n"
	mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
	
	echo "[client]
default-character-set = latin1

[mysqld]
collation_server = latin1_swedish_ci
character_set_server = latin1
 
[mysql]
default-character-set = latin1" >> /etc/mysql/my.cnf
	 
	echo -e "\nActivation du Service MySQL\n"
	systemctl enable mysqld # Démarrer le service au démarrage
	systemctl start mysqld  # Redémarrer le service
	
	if [ $DEBUG -eq 1 ]; then 
		systemctl status mysqld # Vérification
	fi

	echo -e "\nSécurisation de base de MySQL\n"
	mysql_secure_installation <<EOF

y
arch-server
arch-server
y
y
y
y
EOF
}



#///////////////////////////////////////////////////////////////////////////////////////////////////////////#///////////////////////////////////////////////////////////////////////////////////////////////////////////


#///////////////////////////////// 
#//       SERVICE NTPD         //
#/////////////////////////////////

function InstallNtpd {
	top
	echo -e "\nBackup du Fichier d'installation\n"
	cp -avr /etc/ntp.conf /etc/ntp.conf.bak
	
	echo "# Please consider joining the pool:
#
#     http://www.pool.ntp.org/join.html
#
# For additional information see:
# - https://wiki.archlinux.org/index.php/Network_Time_Protocol_daemon
# - http://support.ntp.org/bin/view/Support/GettingStarted
# - the ntp.conf man page

# Associate to Arch's NTP pool
server 0.be.pool.ntp.org
server 1.be.pool.ntp.org
server 2.be.pool.ntp.org
server 3.be.pool.ntp.org


# By default, the server allows:
# - all queries from the local host
# - only time queries from remote hosts, protected by rate limiting and kod
restrict default kod limited nomodify nopeer noquery notrap
restrict 127.0.0.1
restrict ::1

interface ignore wildcard
interface listen 127.0.0.1

# Location of drift file
driftfile /var/lib/ntp/ntp.drift
# Configuration du Pool NTP" > /etc/ntp.conf
	
	echo -e "\nActivation du Service NTPD\n"
	systemctl start ntpd
	systemctl enable ntpd
	
	echo -e "\nSynchronisation du temps\n"
	hwclock --systohc --utc
	ntpdate -qu 0.be.pool.ntp.org > /dev/null
	timedatectl set-timezone Europe/Brussels
	timedatectl set-ntp true
	
	systemctl restart ntpd
	
	
	if [ $DEBUG -eq 1 ]; then 
		systemctl status ntpd
	fi
	
	hwclock --systohc --utc
	ntpdate -qu 0.be.pool.ntp.org
	timedatectl set-timezone Europe/Brussels
	timedatectl set-ntp true
	sleep 1
	
	echo ""
	ntptime
	echo ""
	timedatectl
	echo ""

       # Copy SYNC CLOCK
       cp -avr file_config/clock_kernel /usr/bin/
       cp -avr file_config/clock_kernel.service /etc/systemd/system
       chmod 755 /usr/bin/clock_kernel
       chmod 777 /etc/systemd/system/clock_kernel.service
       systemctl deamon-reload
       systemctl enable clock_kernel.service
}



#///////////////////////////////////////////////////////////////////////////////////////////////////////////#///////////////////////////////////////////////////////////////////////////////////////////////////////////


#///////////////////////////////// 
#//       SERVICE HTTPD         //
#/////////////////////////////////

function InstallHTTPD {
	top
	echo -e "\nBackup du fichier de configuration de HTTPD\n"
	cp -avr /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak
	
	echo -e "\nModification de l'IP dans le fichier de configuration de HTTPD\n"
	cat  file_config/httpd.conf | sed -e "s/ServerName 10.0.0.36/ServerName $IPSERVER/" > /etc/httpd/conf/httpd.conf

	
	echo -e "\nBackup du fichier de configuration par defaut de HTTPD\n"
	cp -avr /etc/httpd/conf/extra/httpd-default.conf /etc/httpd/conf/extra/httpd-default.conf.bak
	cp -avr file_config/httpd-default.conf /etc/httpd/conf/extra/httpd-default.conf
	
	echo -e "\nBackup du fichier de configuration des vhosts de HTTPD\n"
	cp -avr /etc/httpd/conf/extra/httpd-vhosts.conf /etc/httpd/conf/extra/httpd-vhosts.conf.bak
	cp -avr file_config/httpd-vhosts.conf /etc/httpd/conf/extra/httpd-vhosts.conf

	echo -e "\nVérification de la configuration du Service HTTPD\n"
	apachectl configtest
	
	echo -e "\nActivation du Service HTTPD\n"
	systemctl enable httpd
	systemctl start httpd
	
	if [ $DEBUG -eq 1 ]; then 
		systemctl status httpd
	fi
}

#///////////////////////////////////////////////////////////////////////////////////////////////////////////#///////////////////////////////////////////////////////////////////////////////////////////////////////////


#///////////////////////////////// 
#//       SERVICE DNS           //
#/////////////////////////////////

function InstallDNS {
	top
	echo -e "\nBackup du fichier de configuration de BIND9\n"
	cp -avr /etc/named.conf  /etc/named.conf.back
	cp -avr file_config/named.conf /etc/named.conf

	echo -e "\nActivation du Service BIND9\n"
	systemctl start named
	systemctl enable named
	
	if [ $DEBUG -eq 1 ]; then 
		systemctl status named
	fi
	
	echo -e "\nVerification du DNS\n"
	named-checkconf /etc/named.conf
	named -g -p 53
}



#///////////////////////////////// 
#//       SERVICE VSFTPD        //
#/////////////////////////////////

function InstallVSFTPD {
	top
	echo -e "\nBackup du fichier de configuration de VSFTPD\n"
	cp -avr /etc/vsftpd.conf  /etc/vsftpd.conf.back
	cp -avr file_config/vsftpd.conf /etc/vsftpd.conf

	echo -e "\nActivation du Service VSFTPD\n"
	systemctl start vsftpd
	systemctl enable vsftpd
	
	if [ $DEBUG -eq 1 ]; then 
		systemctl status vsftpd
	fi
}

#///////////////////////////////// 
#//   INSTALL PYTHON PACKAGES   //
#/////////////////////////////////

function InstallPython {
	top
	echo -e "\nInstallation des librairies Python\n"
	pacman -S python-pip python-mysql-connector
        pip install npyscreen
}

#///////////////////////////////////////////////////////////////////////////////////////////////////////////#///////////////////////////////////////////////////////////////////////////////////////////////////////////

function RemountBoot {
	umount -Rv /boot
	mount -v /dev/sde1 /boot
}


function main {
	SECONDS=0 	# Reset Bash Count 
	top
	RemountBoot
	InstallNtpd
	ConfigSSH
	InstallSamba
	InstallNFS
	InstallMysql
	InstallHTTPD
	InstallDNS
	InstallVSFTPD
        InstallPython
	ELAPSED="Elapsed: $(($SECONDS/3600))hrs $((($SECONDS/60) % 60))min $(($SECONDS % 60))sec"
	echo $ELAPSED
}


main
