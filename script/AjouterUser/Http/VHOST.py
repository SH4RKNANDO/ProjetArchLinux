import os


class Vhost:

    def __init__(self, username, usermail, domainname):
        self._vhostspath = "/etc/httpd/conf/extra/httpd-vhosts.conf"
        self._webdirectory = "/home/jail/home/" + username + "/public_html"
        self._homedir = "/home/jail/home/" + username
        self._mail = usermail
        self._domainname = domainname
        self._vhostspathback = "/etc/httpd/conf/extra/httpd-vhosts.back"

    def _templatevhost(self):
        vhost = "<VirtualHost *:80"
        vhost += "    ServerAdmin " + self._mail
        vhost += "    DocumentRoot " + self._webdirectory
        vhost += "    ServerName " + self._domainname
        vhost += "    ServerAlias " + self._domainname
        vhost += "    ErrorLog /var/log/httpd/" + self._domainname + "-error_log"
        vhost += "    CustomLog /var/log/httpd/" + self._domainname + "-access_log common"
        vhost += "    <Directory " + self._webdirectory
        vhost += "         Require all granted"
        vhost += "     </Directory>"
        vhost += "</VirtualHost>"
        return vhost

    def _resumevhost(self):
        template = self._templatevhost()
        print("*------------------------------------------------------*")
        print(template)
        print("*-------------------------------------------------------*")

    def _gestiondroit(self):
        os.system("chmod +x " + self._homedir)
        os.system("chmod o+x " + self._webdirectory)
        os.system("chmod -R o+r " + self._webdirectory)

    def _sendbymail(self):
        cmd = "mutt -s " + '"' + "Modification de vhost" + '"' + " " + self._mail + " -a "
        cmd += self._vhostspath + " " + self._vhostspathback + " < /tmp/ServerKey_Gen"
        print("Backup du fichier Fichier Vhost")
        # print(cmd + "\n")
        print(os.system(cmd))

    def _savevhost(self):
        template = self._templatevhost()
        os.system("cp -avr " + self._vhostspath + " " + self._vhostspathback)
        file = open(self._vhostspath, "w")
        file.write(template)
        file.close()
        self._sendbymail()

    def createvhost(self):
        self._resumevhost()
        self._savevhost()
