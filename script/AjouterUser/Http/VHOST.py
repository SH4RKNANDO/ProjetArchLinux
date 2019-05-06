import os


class Vhost:

    def __init__(self, username, usermail, domainname):
        self._username = username
        self._vhostspath = "/etc/httpd/conf/extra/httpd-vhosts.conf"
        self._webdirectory = "/home/jail/home/" + username + "/public_html"
        self._homedir = "/home/jail/home/" + username
        self._mail = usermail
        self._domainname = domainname
        self._vhostspathback = "/etc/httpd/conf/extra/httpd-vhosts.back"

    def _templatevhost(self):
        vhost = "<VirtualHost *:80>" + "\n"
        vhost += "    ServerAdmin " + self._mail + "\n"
        vhost += "    DocumentRoot " + '"' + self._webdirectory + '"' + "\n"
        vhost += "    ServerName " + self._domainname + "\n"
        vhost += "    ServerAlias " + self._domainname + "\n"
        vhost += "    ErrorLog " + '"' + "/var/log/httpd/" + self._domainname + "-error_log" + '"' + "\n"
        vhost += "    CustomLog " + '"' + "/var/log/httpd/" + self._domainname + "-access_log" + '"' + " common" + "\n"
        vhost += "    <Directory " + '"' + self._webdirectory + '"' + " >\n"
        vhost += "         Require all granted\n"
        vhost += "     </Directory>\n"
        vhost += "</VirtualHost>\n"
        return vhost

    def _resumevhost(self):
        template = self._templatevhost()
        print("\nCréation des hôtes virtuel (VHOST)\n")
        print("*------------------------------------------------------*\n")
        print(template)
        print("*-------------------------------------------------------*")

    def _gestiondroit(self):
        print("\nGestions des Droits sur le répertoire Web")
        print(os.system("mkdir -pv " + self._webdirectory))

        directory = [
            "/home"
            "/home/jail",
            "/home/jail/home",
            "/home/jail/home/" + self._username,
            "/home/jail/home/" + self._username + "/public_html"
        ]

        for x in directory:
            print(os.system("chmod -v 770 " + x))
            print(os.system("chown -v " + self._username + ":http " + x))

        site = "<html><body><h1>Site en Construction</h1></body></html>"
        cmd = "echo " + site + " > /home/jail/home/" + self._username + "/public_html/index.html"
        print(os.system(cmd))

        cmd = "chown -v " + self._username + ":http /home/jail/home/" + self._username + "public_html/index.html"
        print(os.system(cmd))
        print(os.system("chmod -v 1770 /home/jail/home/" + self._username + "/public_html/index.html"))

    def _sendbymail(self):
        cmd = "mutt -s " + '"' + "Modification de vhost" + '"' + " " + self._mail + " -a "
        cmd += self._vhostspath + " " + self._vhostspathback
        # print(cmd + "\n")
        print(os.system(cmd))

    def _savevhost(self):
        template = self._templatevhost()
        print("\nBackup du fichier de configuration !")
        os.system("cp -avr " + self._vhostspath + " " + self._vhostspathback)
        file = open(self._vhostspath, "a")
        file.write(template)
        file.close()
        self._sendbymail()

    def createvhost(self):
        self._resumevhost()
        self._savevhost()
