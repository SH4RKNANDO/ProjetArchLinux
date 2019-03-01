#!/bin/bash


clear


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


echo
echo "Verification de la langue"
echo
locale
echo
echo "---------------------------"

