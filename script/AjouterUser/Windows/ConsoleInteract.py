import os


class ConsoleInteract:
    def __init__(self):
        self.infos = []

    def userinfosinteract(self):
        while True:
            self.infos.clear()
            os.system("clear")
            self.infos.append(input("Veuillez entrer le nom de l'utilisateur :"))
            self.infos.append(input("Veuillez entrer le mot de passe de l'utilisateur :"))
            self.infos.append(input("Veuillez entrer l'addresse mail de l'utilisateur : "))
            self.infos.append(input("Veuillez entrer le groupe de l'utilisateur :"))
            self.infos.append(input("Veuillez entrer le nom de la base de donnée :"))

            if self.checkuser():
                check = self.infosrecap()
                if check:
                    return True

    def userinfosparam(self, username, mail, group, password, dbname):
        self.infos.clear()
        os.system("clear")
        self.infos.append(username)
        self.infos.append(mail)
        self.infos.append(group)
        self.infos.append(password)
        self.infos.append(dbname)

    def checkuser(self):
        check = False
        for x in self.infos:
            if x == "":
                return False
            else:
                check = True
        return check

    def infosrecap(self):
        while True:
            os.system("clear")
            print("*---------------------------*")
            print("| Récapitulatif des données |")
            print("*---------------------------*")
            print("Username :" + self.infos[0])
            print("password :" + self.infos[1])
            print("mail :" + self.infos[2])
            print("user group :" + self.infos[3])
            print("*---------------------------*")
            check = input("Les infos sont correcte ? Y/N")

            if check == 'Y' or check == 'y':
                return True
            elif check == 'N' or check == 'n':
                return False


if __name__ == "__main__":
    newuser = ConsoleInteract()
    newuser.userinfosinteract()
