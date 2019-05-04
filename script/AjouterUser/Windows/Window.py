import os
import time
import npyscreen


class DefaultTheme(npyscreen.ThemeManager):
    default_colors = {
        'DEFAULT': 'WHITE_BLACK',
        'FORMDEFAULT': 'WHITE_BLACK',
        'NO_EDIT': 'BLUE_BLACK',
        'STANDOUT': 'CYAN_BLACK',
        'CURSOR': 'WHITE_BLACK',
        'CURSOR_INVERSE': 'BLACK_WHITE',
        'LABEL': 'GREEN_BLACK',
        'LABELBOLD': 'WHITE_BLACK',
        'CONTROL': 'YELLOW_BLACK',
        'IMPORTANT': 'GREEN_BLACK',
        'SAFE': 'GREEN_BLACK',
        'WARNING': 'YELLOW_BLACK',
        'DANGER': 'RED_BLACK',
        'CRITICAL': 'BLACK_RED',
        'GOOD': 'GREEN_BLACK',
        'GOODHL': 'GREEN_BLACK',
        'VERYGOOD': 'BLACK_GREEN',
        'CAUTION': 'YELLOW_BLACK',
        'CAUTIONHL': 'BLACK_YELLOW',
    }


class Window(npyscreen.NPSApp):
    def __init__(self):
        self.infos = []

    def main(self):
        while True:
            os.system("clear")
            self.infos.clear()

            # These lines create the form and populate it with widgets.
            # A fairly complex screen in only 8 or so lines of code - a line for each control.
            npyscreen.setTheme(npyscreen.Themes.DefaultTheme)
            form = npyscreen.Form(name="Création d'un utilisateur Linux", )

            username = form.add(npyscreen.TitleText, name="username:")
            usergroup = form.add(npyscreen.TitleText, name="usergroup:")
            usermail = form.add(npyscreen.TitleText, name="mail:")
            password = form.add(npyscreen.TitlePassword, name="password:")
            dbname = form.add(npyscreen.TitleText, name="dbname:")
            domain = form.add(npyscreen.TitleText, name="domain:")

            # Interact with User
            form.edit()
            self.infos.append(username.value)
            self.infos.append(password.value)
            self.infos.append(usermail.value)
            self.infos.append(usergroup.value)
            self.infos.append(dbname.value)
            self.infos.append(domain.value)

            if self.checkuser():
                check = self.infosrecap()
                if check:
                    return True

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
            # These lines create the form and populate it with widgets.
            # A fairly complex screen in only 8 or so lines of code - a line for each control.
            npyscreen.setTheme(npyscreen.Themes.DefaultTheme)
            form = npyscreen.Form(name="Création d'un utilisateur Linux", )

            form.add(npyscreen.TitleFixedText, name="*---------------------------------*", value="")
            form.add(npyscreen.TitleFixedText, name="|   Récapitulatif des données     |", value="")
            form.add(npyscreen.TitleFixedText, name="*---------------------------------*", value="")
            form.add(npyscreen.TitleFixedText, name="| Username :", value=self.infos[0])
            form.add(npyscreen.TitleFixedText, name="| Password :", value=self.infos[1])
            form.add(npyscreen.TitleFixedText, name="| Mail :", value=self.infos[2])
            form.add(npyscreen.TitleFixedText, name="| usergroup :", value=self.infos[3])
            form.add(npyscreen.TitleFixedText, name="| database :", value=self.infos[4])
            form.add(npyscreen.TitleFixedText, name="| domaine :", value=self.infos[5])
            form.add(npyscreen.TitleFixedText, name="*----------------------------------*", value="")

            check = form.add(npyscreen.TitleText, name="Confirm Y/N :")

            # Interact with User
            form.edit()

            if check.value == 'Y' or check.value == 'y':
                return True
            elif check.value == 'N' or check.value == 'n':
                return False


if __name__ == "__main__":
    window = Window()
    window.run()
