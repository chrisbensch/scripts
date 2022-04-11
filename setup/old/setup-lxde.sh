#!/bin/bash
#-Metadata----------------------------------------------------#
#  Filename: setup-common.sh             (Update: 2017-07-02) #
#-Info--------------------------------------------------------#
#  Personal post-install script for Kali Linux Rolling        #
#  This installs the common tools                             #
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


(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Adding${GREEN} Kali PGP Keys${RESET}"
apt-key adv --keyserver hkp://keys.gnupg.net --recv-keys 7D8D0BF6


echo -e '\n'${BLUE}'[*]'${RESET}' '${BOLD}'Done!'${RESET}'\n\a'
exit 0
