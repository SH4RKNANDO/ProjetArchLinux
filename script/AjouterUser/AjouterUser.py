#!/usr/bin/env python

from Ssh.SSH import SSH
from DataBase.DataBase import DataBase
from Windows.Window import Window
from Http.VHOST import Vhost
from Dns.DNS import DNS
from Windows.ConsoleInteract import ConsoleInteract

import argparse
import os
import sys


class AjouterUser:
    def __init__(self):
        self.window = Window()

    def getinfos(self):
        self.window.run()

    def adduserSystem(self, username, password):
        # Create User
        print("\ncréation de l'utilsateur")
        cmd = "useradd -m -g users -G sshusers --home /home/jail/home/" + username + " -s /bin/bash " + username
        print(os.system(cmd))
        print(os.system("yes " + '"' + password + '"' + " | passwd " + username))

        # Modify the directory
        print("\nModification du répertoire")
        print(os.system("usermod --home /home/" + username + " " + username))

        # Create Passwd File
        print("\ncréation du fichier de mots de passe")
        print(os.system("cat /etc/passwd | grep '^" + username + ":' >> /home/jail/etc/passwd"))

    def createUser(self, username, password, mail, group, dbname, domain):
        ssh = SSH(password, username, mail, group)
        db = DataBase(username, password, dbname)
        vhost = Vhost(username, mail, domain)
        dns = DNS(mail, domain)

        ssh.generatekey()
        db.createdb()
        vhost.createvhost()
        dns.createzone()

    def restartservice(self):
        print("\nRestart Service Dns")
        print(os.system("systemctl restart named"))

        print("\nRestart Service Httpd")
        print(os.system("systemctl restart httpd"))

    def gestiondroits(self, username):
        print("\nGestions des droits du répertoire")
        directory = [
            "/home/jail/home/" + username,
            "/home/jail/home/" + username + "/public_html",
            "/home/jail/home/" + username + "/public_html/index.html",
        ]

        for x in directory:
            print("\nCurrent Directory : " + x)
            print(os.system("chmod -v 1770 " + x))
            print(os.system("chown -v " + username + ":http " + x))
            print("\n")


if __name__ == "__main__":
    euid = os.geteuid()
    if euid != 0:
        print("You need to be the Superuser to make changes to these files...")
        args = ['sudo', sys.executable] + sys.argv + [os.environ]
        os.execlpe('sudo', *args)
    try:
        user = AjouterUser()
        user.getinfos()
        user.adduserSystem(user.window.infos[0], user.window.infos[1])
        user.createUser(user.window.infos[0],
                        user.window.infos[3],
                        user.window.infos[2],
                        user.window.infos[1],
                        user.window.infos[4],
                        user.window.infos[5])
        user.restartservice()
        user.gestiondroits(user.window.infos[0])

    except KeyboardInterrupt:
        print("Exit Now ...")
        sys.exit()

