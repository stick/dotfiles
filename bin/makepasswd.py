#!/usr/bin/python

import subprocess
import datetime

today = datetime.date.today()
apgcmd = ['apg','-M','SNCL','-m','14','-t','-n','10']
passwdcmd = ['openssl','passwd','-1','-stdin','-noverify']

apg = subprocess.Popen(apgcmd,stdout=subprocess.PIPE)
#p = apg.communicate()[0]
passwords = [ password.split(' ') for password in apg.communicate()[0].split('\n')]
passwords.pop()
#print passwords
for password in passwords:
    passwd = subprocess.Popen(passwdcmd,stdout=subprocess.PIPE,stdin=subprocess.PIPE)
    stdout,stderr = passwd.communicate(password[0])
    print "%s : %s : %s : %s"%(stdout.strip(), password[0],password[1], today)
