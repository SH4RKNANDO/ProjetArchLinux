# ProjetArchLinux
Configuration de base d'un server Arch-Linux Sécurisé

## Pré-requis du déploiement 

Obtenir un accès ssh

<span>useradd -m -s /bin/bash user<br></span>
<span>yes "user" | passwd user <br></span>
<span>yes "root" | passwd <br></span>
<span>systemctl start sshd <br></span>
<span>ifconfig<br></span>

## Cloner le dépot :

yes "n" | pacman -Sy
yes "y" | pacman -S git 
git clone https://github.com/SH4RKNANDO/ProjetArchLinux.git

## Lancement du déploiement partie 1:

cd ProjetArchLinux/script/deploiement/
bash install_part1.sh

notes : La partie2 est appelée par la partie1
