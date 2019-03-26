#!/bin/bash

clear

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
echo "\n---------------------------\n"
