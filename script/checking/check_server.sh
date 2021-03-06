#!/bin/bash

function Check_System {
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
	
   echo -e "\nVerification de la RAM"
   free -h
   echo -e "\n---------------------------\n"

   echo -e "\nVerification de la langue\n"
   locale
   echo -e "\n---------------------------"
   echo -e "---------------------------\n\n"

}
#////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////

function Check_Service {

   echo -e "\nVerification du service NTPD\n"
   systemctl status ntpd
   echo
   timedatectl
   echo
   ntptime
   echo -e "\n\n---------------------------\n"


   echo -e "\nVerification du service SSHD\n"
   systemctl status sshd
   echo -e "\n\n---------------------------\n"


   echo -e "\nVerification du service HTTPD\n"
   systemctl status httpd
   echo -e "\nVérification de la configuration du Service HTTPD\n"
   apachectl configtest
   echo -e "\n\n---------------------------\n"

   echo -e "\nVerification du Service DNS\n"
   systemctl status named
   echo
   named -g -p 53
   echo -e "\n\nVerification des zone DNS\n"
   named-checkconf /etc/named.conf
   echo -e "\n---------------------------\n"


   echo -e "\nVerification du Service NFS\n" 
   systemctl status nfs-server
   echo 
   cat /etc/exports
   echo
   echo -e "\n---------------------------\n"


   echo -e "\nVerification du Service SAMBA\n"
   systemctl status nmb smb
   echo
   cat /etc/samba/smb.conf
   echo
   echo -e "\n---------------------------\n"

   echo -e "\nVerification du Service MYSQL\n"
   systemctl status mysqld
   echo -e "\n---------------------------\n"

   echo -e "\nVerification du Service VSFTPD\n"
   systemctl status vsftpd
   echo -e "\n---------------------------\n"


   echo -e "\nMise a jour de l'AV\n"
   freshclam
   echo -e "\n---------------------------\n"
}



function main {
   clear
   # Check_System
   Check_Service
   
}

main

# iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 21 -j ACCEPT
# echo net.netfilter.nf_conntrack_helper=1 > /etc/sysctl.d/70-conntrack.conf
# iptables -A PREROUTING -t raw -p tcp --dport 21 -j CT --helper ftp
