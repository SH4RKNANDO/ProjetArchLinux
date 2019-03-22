# ProjetArchLinux
Configuration de base d'un server Arch-Linux Sécurisé

## Pré-requis du déploiement 

Obtenir un accès ssh

useradd -m -s /bin/bash user
yes "user" | passwd user
yes "root" | passwd
systemctl start sshd
ifconfig

## Cloner le dépot :

yes "n" | pacman -Sy
yes "y" | pacman -S git 
git clone https://github.com/SH4RKNANDO/ProjetArchLinux.git

## Lancement du déploiement partie 1:

cd ProjetArchLinux/script/deploiement/
bash install_part1.sh

notes : La partie2 est appelée par la partie1
