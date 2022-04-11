#!/bin/bash
#-Metadata----------------------------------------------------#
#  Filename: setup-cinnamon.sh           (Update: 2018-02-20) #
#-Info--------------------------------------------------------#
#  Personal post-install script for Kali Linux Rolling        #
#  This installs the Cinnamon Desktop Environment             #
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


###### Install Cinnamon
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Cinnamon ${RESET}${RESET} ~ desktop environment"
apt -y -qq install kali-defaults kali-root-login desktop-base cinnamon \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2

##--- Configuring Cinnamon
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}Cinnamon ${RESET}${RESET} ~ desktop environment"
file=/tmp/cinnamon.backup.dconf; [ -e "${file}" ] && cp -n $file{,.bkup}
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
[/]
panels-resizable=['1:true']
alttab-switcher-delay=100
enabled-applets=['panel1:right:0:systray@cinnamon.org:0', 'panel1:left:0:menu@cinnamon.org:1', 'panel1:left:1:show-desktop@cinnamon.org:2', 'panel1:left:2:panel-launchers@cinnamon.org:3', 'panel1:left:3:window-list@cinnamon.org:4', 'panel1:right:1:keyboard@cinnamon.org:5', 'panel1:right:2:notifications@cinnamon.org:6', 'panel1:right:3:removable-drives@cinnamon.org:7', 'panel1:right:4:user@cinnamon.org:8', 'panel1:right:5:network@cinnamon.org:9', 'panel1:right:6:bluetooth@cinnamon.org:10', 'panel1:right:7:power@cinnamon.org:11', 'panel1:right:8:calendar@cinnamon.org:12', 'panel1:right:9:sound@cinnamon.org:13']
next-applet-id=14
panel-launchers=['DEPRECATED']
panels-height=['1:32']

[settings-daemon/plugins/xsettings]
buttons-have-icons=true
menus-have-icons=true

[muffin]
resize-threshold=24

[desktop/a11y/applications]
screen-keyboard-enabled=false
screen-reader-enabled=false

[desktop/a11y/mouse]
secondary-click-enabled=false
secondary-click-time=1.2
dwell-time=1.2
dwell-threshold=10
dwell-click-enabled=false

[desktop/media-handling]
autorun-never=false

[desktop/applications/terminal]
exec='terminator'

[desktop/background]
picture-uri='file:///usr/share/desktop-base/kali-theme/lockscreen/gnome-background.xml'
picture-options='zoom'

[desktop/background/slideshow]
image-source='xml:///usr/share/gnome-background-properties/debian-kali.xml'
delay=15

[desktop/interface]
toolkit-accessibility=false

[desktop/sound]
event-sounds=false

[desktop/wm/preferences]
min-window-opacity=30
theme='Albatross'

[theme]
name='Arc-Dark'

EOF

dconf load /org/cinnamon/ < /tmp/cinnamon.backup.dconf

mkdir -p ~/.cinnamon/configs/panel-launchers@cinnamon.org
file=~/.cinnamon/configs/panel-launchers@cinnamon.org/3.json; [ -e "${file}" ] && cp -n $file{,.bkup}
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
{
    "section1": {
        "type": "section",
        "description": "Behavior"
    },
    "launcherList": {
        "type": "generic",
        "default": [
            "firefox.desktop",
            "gnome-terminal.desktop",
            "nemo.desktop"
        ],
        "value": [
            "firefox.desktop",
            "gnome-terminal.desktop",
            "firefox-esr.desktop",
            "Burp Suite Professional-0.desktop",
            "cinnamon-custom-launcher-3.desktop",
            "sublime_text.desktop",
            "terminator.desktop",
            "pcmanfm.desktop"
        ]
    },
    "allow-dragging": {
        "type": "switch",
        "default": true,
        "description": "Allow dragging of launchers",
        "value": true
    },
    "__md5__": "11474ba983ca660d140dedf9e087884c"
}

EOF

mkdir -p ~/.cinnamon/panel-launchers
file=~/.cinnamon/panel-launchers/cinnamon-custom-launcher-1.desktop; [ -e "${file}" ] && cp -n $file{,.bkup}
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
[Desktop Entry]
Comment=
Terminal=false
Name=Terminator
Exec=terminator
Type=Application

EOF

file=~/.cinnamon/panel-launchers/cinnamon-custom-launcher-2.desktop; [ -e "${file}" ] && cp -n $file{,.bkup}
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
[Desktop Entry]
Comment=
Terminal=false
Name=BurpSuite Pro
Exec=/opt/BurpSuitePro/BurpSuitePro
Type=Application

EOF

file=~/.cinnamon/panel-launchers/cinnamon-custom-launcher-3.desktop; [ -e "${file}" ] && cp -n $file{,.bkup}
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
[Desktop Entry]
Name=metasploit framework
Encoding=UTF-8
Exec=terminator -e "service postgresql start && msfdb init && msfconsole;${SHELL:-bash}"
Icon=kali-metasploit
StartupNotify=false
Terminal=false
Type=Application
Categories=08-exploitation-tools;
X-Kali-Package=metasploit-framework
Comment=

EOF


echo -e '\n'${BLUE}'[*]'${RESET}' '${BOLD}'Done!'${RESET}'\n\a'
exit 0
