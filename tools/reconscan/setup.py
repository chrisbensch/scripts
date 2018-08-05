#!/usr/bin/env python

# This just sets up the necessary dirs for this to all work
import subprocess

if __name__ == '__main__':
    subprocess.check_output("mkdir -p /root/oscp/exam/", shell=True)
    subprocess.check_output("mkdir -p /root/oscp/reports", shell=True)
    subprocess.check_output("cp windows-template.md /root/oscp/reports/windows-template.md", shell=True)
    subprocess.check_output("cp linux-template.md /root/oscp/reports/linux-template.md", shell=True)
