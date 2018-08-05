#!/bin/bash

port knock sequence

for x in 1466 67 1469 1514 1981 1986; do nmap -Pn --host_timeout 201 --max-retries 0 -p $x 192.168.1.139; done