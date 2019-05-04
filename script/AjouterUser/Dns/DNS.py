import os
import socket


class DNS:

    def __init__(self, usermail, domainname):
        self._domainname = domainname
        self._internalzone = "/var/named/" + domainname
        self._dnsconfig = "/etc/named.conf"
        self._mail = usermail
        self._IP = socket.gethostbyname(socket.gethostname())
        self._reverseip = self._getreverseip()
        self._Hostname = socket.gethostname()
        self._reversezone = "/var/named/" + self._reverseip + "in-addr.arpa"

    def _templateinternal(self):
        dns2 = "$ttl 1H\n"
        dns2 += self._domainname + ".          IN      SOA     " + self._Hostname + ". " + self._mail + ". (\n"
        dns2 += "                                        20192103; Serial\n"
        dns2 += "                                        1H ; Refresh\n"
        dns2 += "                                        15M ; Retry\n"
        dns2 += "                                        2W ; Expire\n"
        dns2 += "                                        3M ; Minimum TTL\n"
        dns2 += "                                        )\n"
        dns2 += self._domainname + ".   IN    NS        " + self._Hostname + ".         ; NAMESERVER\n"
        dns2 += self._domainname + ".   IN    MX        10 mail." + self._domainname + ". ; MX RECCORD\n"
        dns2 += self._domainname + ".   IN     A        " + self._IP + "                ; AAA RECCORD\n"
        dns2 += "mail              IN     A        " + self._IP + "                ; AAA RECCORD\n"
        dns2 += "www               IN     A        " + self._IP + "                ; AAA RECCORD\n"
        return dns2

    def _templatereverselookup(self):
        dns2 = "$ttl 1H\n"
        dns2 += "@          IN      SOA     " + self._Hostname + ". " + self._mail + ". (\n"
        dns2 += "                                        20192103; Serial\n"
        dns2 += "                                        1H ; Refresh\n"
        dns2 += "                                        15M ; Retry\n"
        dns2 += "                                        2W ; Expire\n"
        dns2 += "                                        3M ; Minimum TTL\n"
        dns2 += "                                        )\n"
        dns2 += "@               IN      NS        " + self._Hostname + ".         ; NAMESERVER\n"
        dns2 += self._IP + "        IN     PTR        " + "                ; AAA RECCORD\n"
        return dns2

    def _templateresolution(self):
        dns3 = "// *------------------------------------------------*\n"
        dns3 += "// | ZONE DE RESOLUTION DU DOMAINE " + self._domainname+"      |\n"
        dns3 += "// *________________________________________________*\n"
        dns3 += "zone " + '"' + self._domainname + '"' + " {\n"
        dns3 += "  type master;\n"
        dns3 += "  file " + '"' + self._internalzone + '"' + ';' + "\n"
        dns3 += "  allow-transfer { 127.0.0.1; };    // autorise le transfert\n"
        dns3 += "  notify yes;                       // slave notification quand une zone est mise a jour\n"
        dns3 += "};\n\n"
        dns3 += "// *----------------------------*\n"
        dns3 += "// | ZONE DE RESOLUTION INVERSE |\n"
        dns3 += "// *----------------------------*\n"
        dns3 += "zone " + '"' + self._reverseip + "in-addr.arpa" + '"' + " { \n"
        dns3 += "  type master;\n"
        dns3 += "  file " + '"' + self._reversezone + '"' + ";\n"
        dns3 += "  allow-transfer { 127.0.0.1; };    // autorise le transfert\n"
        dns3 += "  notify no;\n"
        dns3 += "};\n"
        return dns3

    def _getreverseip(self):
        ip = socket.gethostbyname(socket.gethostname())
        x = ip.split('.')
        reverse_tab = []
        reverse_ip = ""
        nbelement = len(x) - 1

        for cpt in range(nbelement, -1, -1):
            reverse_tab.append(x[cpt])

        cpt = 0

        for a in reverse_tab:
            reverse_ip += a
            if cpt < 4:
                reverse_ip += "."
            cpt = cpt + 1

        return reverse_ip

    def _resumedns(self):
        tpl = self._templateinternal()
        tpl2 = self._templateresolution()
        print("\n*--------------------------------------*")
        print(tpl)
        print("\n*--------------------------------------*")
        print(tpl2)
        print("\n*--------------------------------------*")

    def _check_dns(self):
        print("\nVerification du fichier de configuration DNS\n")
        os.system("named-checkconf /etc/named.conf > /tmp/dnscheck")
        os.system("named-checkzone " + self._domainname + " " + self._internalzone + " >> /tmp/dnscheck")
        os.system("named-checkzone " + self._domainname + " " + self._reversezone + " >> /tmp/dnscheck")
        os.system("nslookup " + self._domainname + " >> /tmp/dnscheck")
        os.system("nslookup www." + self._domainname + " >> /tmp/dnscheck")
        os.system("ping zerocool.lan.be >> /tmp/dnscheck")
        os.system("ping www" + self._domainname + " >> /tmp/dnscheck")
        os.system("nslookup " + self._IP + " >> /tmp/dnscheck")

    def _sendbymail(self):
        cmd = "mutt -s " + '"' + "Modification zone dns" + '"' + " " + self._mail + " -a "
        cmd += self._internalzone + " " + self._dnsconfig + " " + " < /tmp/dnscheck"
        # print(cmd + "\n")
        print(os.system(cmd))

    def _savevdns(self):
        # Backup
        print("\nBackup des fichiers de configuration du dns")
        print(os.system("cp -avr " + self._internalzone + " " + self._internalzone + ".bck"))

        tpl = self._templateinternal()
        tpl2 = self._templateresolution()
        tpl3 = self._templatereverselookup()

        print("\n*--------------------------------------*")
        print(tpl)
        print("\n*--------------------------------------*")
        print(tpl2)
        print("\n*--------------------------------------*")
        print(tpl3)
        print("\n*--------------------------------------*")

        print("\nSauvegarde du fichier de zone interne")
        file1 = open(self._internalzone, "w")
        file1.write(tpl)
        file1.close()

        print("\nSauvegarde du fichier de configuration DNS")
        file2 = open(self._dnsconfig, "a")
        file2.write(tpl2)
        file2.close()

        print("\nSauvegarde du fichier de zone reverse DNS")
        file3 = open(self._reversezone, "a")
        file3.write(tpl2)
        file3.close()

    def createzone(self):
        self._savevdns()
        self._check_dns()
        self._sendbymail()
