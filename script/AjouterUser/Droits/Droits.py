import os


class Droits:
    def __init__(self, username):

        path = "/home/jail/home/" + username
        #
        # print("\nCréation du Répertoire Web")
        # print(os.system("mkdir -pv " + self._webdirectory))
        #
        # directory = [
        #     "/home",
        #     "/home/jail",
        #     "/home/jail/home",
        #     "/home/jail/home/" + self._username,
        #     "/home/jail/home/" + self._username + "/public_html"
        # ]
        #
        # print("\nCopies du site dans le répertoire web")
        # site = '"' + "<html><body><h1>Site en Construction</h1></body></html>" + '"'
        # cmd = "echo " + site + " > /home/jail/home/" + self._username + "/public_html/index.html"
        # print(os.system(cmd))
        #
        # print("\nGestions des Droits sur le répertoire Web\n")
        #
        # for x in directory:
        #     print("\nRépertoire en cours : " + x)
        #     print(os.system("chmod -v 770 " + x))
        #     print(os.system("chown -v " + self._username + ":http " + x))
        #
        # print("\nGestions des Droits sur le Fichier web")
        # cmd = "chown -v " + self._username + ":http /home/jail/home/" + self._username + "/public_html/index.html"
        # print(os.system(cmd))
        # print(os.system("chmod -v 1770 /home/jail/home/" + self._username + "/public_html/index.html"))
        # print(os.system("DroitSiteweb"))
