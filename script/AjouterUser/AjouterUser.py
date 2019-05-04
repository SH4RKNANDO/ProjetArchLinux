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
        os.system("useradd -m -g users -G sshusers --home /home/jail/home/" + username + " -s /bin/bash " + username)
        os.system("yes " + password + " | passwd" + username)
        # Modify the directory
        os.system("usermod --home /home/" + username + " " + username)
        # Create Passwd File
        os.system("cat /etc/passwd | grep '^" + username + ":' > /home/jail/etc/passwd")

    def createUser(self, username, password, mail, group, dbname, domain):
        ssh = SSH(password, username, mail, group)
        db = DataBase(username, password, dbname)
        vhost = Vhost(username, mail, domain)
        dns = DNS(mail, domain)

        ssh.generatekey()
        db.createdb()
        vhost.createvhost()
        dns.createzone()


if __name__ == "__main__":
    euid = os.geteuid()
    if euid != 0:
        print("You need to be the Superuser to make changes to these files...")
        args = ['sudo', sys.executable] + sys.argv + [os.environ]
        os.execlpe('sudo', *args)

    user = AjouterUser()
    user.getinfos()
    user.createUser(user.window.infos[0],
                    user.window.infos[3],
                    user.window.infos[2],
                    user.window.infos[1],
                    user.window.infos[4],
                    user.window.infos[0])