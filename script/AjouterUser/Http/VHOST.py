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

    def _savevhost(self):
        template = self._templatevhost()
        print("\nBackup du fichier de configuration !")
        os.system("cp -avr " + self._vhostspath + " " + self._vhostspathback)
        file = open(self._vhostspath, "a")
        file.write(template)
        file.close()

    def createvhost(self):
        self._resumevhost()
        self._savevhost()
