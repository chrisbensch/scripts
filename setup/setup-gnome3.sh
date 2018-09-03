#!/bin/bash
#-Metadata----------------------------------------------------#
#  Filename: setup-gnome3.sh             (Update: 2017-07-18) #
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


##### Are we using GNOME?
#--- Installing  Gconf2
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Gconf2${RESET} Gnome Configurator"
apt -y -qq install gconf2

#--- Installing  Gconf2
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}gc${RESET} tool"
apt -y -qq install bc
  
 ##### Disable its auto notification package updater
 (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Disabling ${GREEN}notification package updater${RESET} service ~ in case it runs during thisscript"
 export DISPLAY=:1
 timeout 5 killall -w /usr/lib/apt/methods/http >/dev/null 2>&1
 ##### Disable screensaver
 (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Disabling ${GREEN}screensaver${RESET}"
 xset s 0 0
 xset s off
 gsettings set org.gnome.desktop.session idle-delay 0
 #-- Gnome Extension - Dash Dock (the toolbar with all the icons)
 gsettings set org.gnome.shell.extensions.dash-to-dock intellihide 'false'
 gsettings set org.gnome.shell.extensions.dash-to-dock extend-height 'true'
 gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'LEFT'
 gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed 'true'
 gsettings set org.gnome.shell.extensions.dash-to-dock show-running 'true'
 gsettings set org.gnome.shell favorite-apps "['terminator.desktop', 'firefox-esr.desktop', 'kali-zaproxy.desktop', 'kali-burpsuite.desktop', 'kali-msfconsole.desktop', 'sublime_text.desktop', 'org.gnome.Nautilus.desktop']"
 
 #--- Workspaces
 gsettings set org.gnome.shell.overrides dynamic-workspaces false                         # Static
 gsettings set org.gnome.desktop.wm.preferences num-workspaces 4                          # Increase workspaces count to 4
 #--- Top bar
 gsettings set org.gnome.desktop.interface clock-show-date true                           # Show date next to time in the top tool bar
 #--- Hide desktop icon
 dconf write /org/gnome/nautilus/desktop/computer-icon-visible false
#else
#  echo -e "\n\n ${YELLOW}[i]${RESET} ${YELLOW}Skipping GNOME${RESET}..." 1>&2
#fi

#-- Gnome Global Dark Theme
mkdir -p ~/.config/gtk-3.0/
file=~/.config/gtk-3.0/settings.ini; [ -e "${file}" ] && cp -n $file{,.bkup}
cat <<EOF > "${file}"
[Settings]
gtk-application-prefer-dark-theme=1
EOF

#-- Gnome Dark Aurora GTK Theme
#mkdir -p ~/.themes
#cd ~/.themes
#tar zxvf /opt/scripts/misc/Dark-Aurora.tar.gz
#gsettings set org.gnome.desktop.interface gtk-theme "Dark-Aurora"

#-- Gnome Flat-Plat & GDM
apt-get install -y -qq tidy libglib2.0-dev

cd /tmp && wget -qO - https://github.com/nana-4/materia-theme/archive/master.tar.gz | tar xz
cd materia-theme-master
./install.sh -c dark -s standard
gsettings set org.gnome.desktop.interface gtk-theme "Materia-dark"


##### Configure GNOME terminal   Note: need to restart xserver for effect
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring GNOME ${GREEN}terminal${RESET} ~ CLI interface"
gconftool-2 -t bool -s /apps/gnome-terminal/profiles/Default/scrollback_unlimited true
gconftool-2 -t string -s /apps/gnome-terminal/profiles/Default/background_type transparent
gconftool-2 -t string -s /apps/gnome-terminal/profiles/Default/background_darkness 0.85611499999999996

    #-- Gnome Extensions
gsettings set org.gnome.shell enabled-extensions "['apps-menu@gnome-shell-extensions.gcampax.github.com', 'places-menu@gnome-shell-extensions.gcampax.github.com', 'workspace-indicator@gnome-shell-extensions.gcampax.github.com', 'dash-to-dock@micxgx.gmail.com', 'ProxySwitcher@flannaghan.com', 'EasyScreenCast@iacopodeenosee.gmail.com', 'refresh-wifi@kgshank.net', 'user-theme@gnome-shell-extensions.gcampax.github.com', 'systemMonitor@gnome-shell-extensions.gcampax.github.com', 'alternate-tab@gnome-shell-extensions.gcampax.github.com', 'launch-new-instance@gnome-shell-extensions.gcampax.github.com', 'drive-menu@gnome-shell-extensions.gcampax.github.com', 'window-list@gnome-shell-extensions.gcampax.github.com']"



echo -e '\n'${BLUE}'[*]'${RESET}' '${BOLD}'Done!'${RESET}'\n\a'
exit 0
