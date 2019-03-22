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

<span>yes "n" | pacman -Sy <br></span>
<span>yes "y" | pacman -S git <br></span>
<span>git clone https://github.com/SH4RKNANDO/ProjetArchLinux.git <br></span>

## Lancement du déploiement partie 1:

<span>cd ProjetArchLinux/script/deploiement/ <br></span>
<span>bash install_part1.sh <br></span>

notes : La partie2 est appelée par la partie1
