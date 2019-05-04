import mysql.connector


class DataBase:
    def __init__(self, username, password, dbname):
        self._username = username
        self._password = password
        self._dbname = dbname
        self._mydb = mysql.connector.connect(host="localhost", user="root", passwd="zerocool")

    def _sendcmd(self, cmd):
        print(self._mydb.cursor().execute(cmd))

    def _createdb(self):
        self._sendcmd("CREATE DATABASE " + self._username + ';')

    def _createuser(self):
        cmd = "CREATE USER '" + self._username + "'@'localhost' IDENTIFIED BY " + "'" + self._password + "';"
        self._sendcmd(cmd)
        cmd = "GRANT ALL PRIVILEGES ON " + self._dbname + ".* TO '" + self._username + "'@'localhost';"
        self._sendcmd(cmd)
        cmd = "FLUSH PRIVILEGES;"
        self._sendcmd(cmd)

    def createdb(self):
        self._createdb()
        self._createuser()
