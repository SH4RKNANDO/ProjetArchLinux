import os


class SSH:
    def __init__(self, password, username, mail, group):
        self._Password = password
        self._Username = username
        self._Mail = mail
        self._Group = group

    def _generatekey(self):
        cmd = "ssh-keygen -t rsa -b 4096 -C " + '"' + "ClientKey" + '"' + " -P " + self._Password
        cmd += " -f /tmp/ServerKey > /tmp/ServerKey_Gen"
        print("Génération de la clés ssh RSA 4096")
        # print(cmd + "\n")
        print(os.system(cmd))

    def _sendkeybymail(self):
        cmd = "mutt -s " + '"' + "SSH Server Key" + '"' + " " + self._Mail + " -a /tmp/ServerKey /tmp/ServerKey.pub"
        cmd += " < /tmp/ServerKey_Gen"
        print("\n\nEnvoi des clés ssh par mail")
        # print(cmd + "\n")
        print(os.system(cmd))

    def _gestiondroitssh(self):
        path = "/home/jail/home/" + self._Username + "/.ssh"

        print("\nCréation du Répertoire")
        print(os.system("mkdir -pv " + path))

        print("\nMoving the PubKey to autorized_keys")
        print(os.system("cp -avr /tmp/ServerKey.pub  " + path + "/authorized_keys"))

        print("\nDelete Temp Key")
        print(os.system("rm -rfv /tmp/ServerKey*"))

        print("\nGestion des droits")
        print(os.system("chmod -Rv 700 /home/jail/home/" + self._Username))
        print(os.system("chmod -v 600 " + path))
        print(os.system("chown -Rv " + self._Username + ":" + "sshusers" + " " + path))
        print(os.system("chmod -v 400 " + path + "/authorized_keys"))
        print("\n")

    def generatekey(self):
        self._generatekey()
        self._sendkeybymail()
        self._gestiondroitssh()
