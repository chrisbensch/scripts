#!/bin/bash
#-Metadata----------------------------------------------------#
#  Filename: setup-common.sh             (Update: 2017-07-02) #
#-Info--------------------------------------------------------#
#  Personal install script for Kali Linux Rolling             #
#  This installs PowerShell for Linux                         #
#-Author(s)---------------------------------------------------#
#  chrisbensch ~ https://github.com/chrisbensch               #
#-------------------------------------------------------------#

#-Defaults-------------------------------------------------------------#


##### (Cosmetic) Colour output
RED="\033[01;31m"      # Issues/Errors
GREEN="\033[01;32m"    # Success
YELLOW="\033[01;33m"   # Warnings/Information
BLUE="\033[01;34m"     # Heading
BOLD="\033[01;01m"     # Highlight
RESET="\033[00m"       # Normal

STAGE=0                                                       # Where are we up to
TOTAL=$(grep '(${STAGE}/${TOTAL})' $0 | wc -l);(( TOTAL-- ))  # How many things have we got todo


##### Fix display output for GUI programs (when connecting via SSH)
export DISPLAY=:0.0
export TERM=xterm

(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Powershell${RESET}"
aria2c https://github.com/PowerShell/PowerShell/releases/download/v6.1.0-preview.3/powershell-preview_6.1.0-preview.3-1.debian.9_amd64.deb -d /tmp \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading powershell-preview_6.1.0-preview.3-1.debian.9_amd64.deb" 1>&2
gdebi /tmp/powershell-preview_6.1.0-preview.3-1.debian.9_amd64.deb
