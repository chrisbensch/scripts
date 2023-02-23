#!/bin/bash
#-Metadata----------------------------------------------------#
#  Filename: setup.sh             (Update: 16-FEB-2020)       #
#-Info--------------------------------------------------------#
#  Personal post-install script for Kali Linux Rolling        #
#-Author(s)---------------------------------------------------#
#  chrisbensch ~ https://github.com/chrisbensch/scripts       #
#  g0tmi1k ~ https://github.com/g0tmi1k/os-scripts original   #
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

#--- Only used for stats at the end
start_time=$(date +%s)

#--- Get current Dir
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
#echo $SCRIPT_DIR;

##### Configure User Settings

#--- Autorun Metasploit commands each startup
mkdir -p /home/analyst/.msf4/
touch ~/.msf4/msf_autorunscript.rc
file=~/.msf4/msf_autorunscript.rc; [ -e "${file}" ] && cp -n $file{,.bkup}
cat <<EOF > "${file}"
#run post/windows/escalate/getsystem

#run migrate -f -k
#run migrate -n "explorer.exe" -k    # Can trigger AV alerts by touching explorer.exe...

#run post/windows/manage/smart_migrate
#run post/windows/gather/smart_hashdump

load auto_add_route

load alias
alias del rm
alias handler use exploit/multi/handler

load sounds

setg TimestampOutput true
setg VERBOSE true

setg ExitOnSession false
setg EnableStageEncoding true
setg LHOST 0.0.0.0
setg LPORT 5000
use exploit/multi/handler
#setg AutoRunScript 'multi_console_command -rc "~/.msf4/msf_autorunscript.rc"'
set PAYLOAD windows/meterpreter/reverse_https
EOF


##### Install VMware Helpers
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}VMware Tools Helper${RESET} ~ mount shared folders"
file=~/Desktop/Mount\ Shared\ Folders.desktop
#--- Configure shortcut
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
[Desktop Entry]
Version=1.0
Type=Application
Name=Mount Shared Folders
Comment=
Exec=pkexec /usr/local/sbin/mount-shared-folders
Icon=vmware-workstation
Path=
Terminal=false
StartupNotify=false
EOF
chmod +x "${file}"


(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}VMware Tools Helper${RESET} ~ restart vmtoolsd"
file=~/Desktop/Restart\ VMware\ Tools.desktop
#--- Configure shortcut
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
[Desktop Entry]
Version=1.0
Type=Application
Name=Restart VMware Tools
Comment=
Exec=pkexec /usr/local/sbin/restart-vm-tools
Icon=vmware-workstation
Path=
Terminal=false
StartupNotify=false
EOF
chmod +x "${file}"

###### Setup firefox
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}firefox${RESET} ~ GUI web browser"
timeout 15 firefox >/dev/null 2>&1                # Start and kill. Files needed for first time run
timeout 5 killall -9 -q -w firefox-esr >/dev/null
#--- Wipe session (due to force close)
find ~/.mozilla/firefox/*.default*/ -maxdepth 1 -type f -name 'sessionstore.*' -delete >/dev/null
#
file=$(find ~/.mozilla/firefox/*.default*/ -maxdepth 1 -type f -name 'prefs.js' -print -quit)
[ -e "${file}" ]
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"

sed -i 's/^.network.proxy.socks_remote_dns.*/user_pref("network.proxy.socks_remote_dns", true);' "${file}" 2>/dev/null \
  || echo 'user_pref("network.proxy.socks_remote_dns", true);' >> "${file}"
sed -i 's/^.browser.safebrowsing.enabled.*/user_pref("browser.safebrowsing.enabled", false);' "${file}" 2>/dev/null \
  || echo 'user_pref("browser.safebrowsing.enabled", false);' >> "${file}"
sed -i 's/^.browser.safebrowsing.malware.enabled.*/user_pref("browser.safebrowsing.malware.enabled", false);' "${file}" 2>/dev/null \
  || echo 'user_pref("browser.safebrowsing.malware.enabled", false);' >> "${file}"
sed -i 's/^.browser.safebrowsing.remoteLookups.enabled.*/user_pref("browser.safebrowsing.remoteLookups.enabled", false);' "${file}" 2>/dev/null \
  || echo 'user_pref("browser.safebrowsing.remoteLookups.enabled", false);' >> "${file}"
sed -i 's/^.*browser.startup.page.*/user_pref("browser.startup.page", 0);' "${file}" 2>/dev/null \
  || echo 'user_pref("browser.startup.page", 0);' >> "${file}"
sed -i 's/^.*privacy.donottrackheader.enabled.*/user_pref("privacy.donottrackheader.enabled", true);' "${file}" 2>/dev/null \
  || echo 'user_pref("privacy.donottrackheader.enabled", true);' >> "${file}"
sed -i 's/^.*browser.showQuitWarning.*/user_pref("browser.showQuitWarning", true);' "${file}" 2>/dev/null \
  || echo 'user_pref("browser.showQuitWarning", true);' >> "${file}"
sed -i 's/^.*extensions.https_everywhere._observatory.popup_shown.*/user_pref("extensions.https_everywhere._observatory.popup_shown", true);' "${file}" 2>/dev/null \
  || echo 'user_pref("extensions.https_everywhere._observatory.popup_shown", true);' >> "${file}"
sed -i 's/^.network.security.ports.banned.override/user_pref("network.security.ports.banned.override", "1-65455");' "${file}" 2>/dev/null \
  || echo 'user_pref("network.security.ports.banned.override", "1-65455");' >> "${file}"

# Show Bookmamrks Toolbar
timeout 10 firefox >/dev/null 2>&1
filedir=$(find ~/.mozilla/firefox/*.default*/ -maxdepth 1 -print -quit)
#echo $filedir
touch "${filedir}/xulstore.json"
file=$(find ~/.mozilla/firefox/*.default*/ -maxdepth 1 -type f -name 'xulstore.json' -print -quit)
#echo $file
cat <<EOF > "${file}" \
 || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
{"chrome://browser/content/browser.xul":{"PersonalToolbar":{"collapsed":"false"},"navigator-toolbox":{"iconsize":"small"},"main-window":{"screenX":"638","screenY":"102","width":"1280","height":"914","sizemode":"normal"},"sidebar-title":{"value":""}}}
EOF

#--- Clear bookmark cache
find ~/.mozilla/firefox/*.default*/bookmarkbackups/ -type f -delete
#--- Set firefox for XFCE's default
mkdir -p ~/.config/xfce4/
file=~/.config/xfce4/helpers.rc; [ -e "${file}" ] && cp -n $file{,.bkup}    #exo-preferred-applications   #xdg-mime default
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
sed -i 's#^WebBrowser=.*#WebBrowser=firefox#' "${file}" 2>/dev/null \
  || echo -e 'WebBrowser=firefox' >> "${file}"

#--- Restore Bookmarks
file=$(find ~/.mozilla/firefox/*.default*/ -maxdepth 1 -type f -name 'places.sqlite' -print -quit)
cp ../misc/places.sqlite.backup /tmp
sqlite3 "${file}" ".restore /tmp/places.sqlite.backup"


##### Setup SSH
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}SSH${RESET} ~ CLI access"
find ~/.ssh/ -type f ! -name authorized_keys -delete 2>/dev/null
#--- Generate new keys
#ssh-keygen -b 4096 -t rsa1 -f /etc/ssh/ssh_host_key -P "" >/dev/null
ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -P "" >/dev/null


##### Setup panels & launchers
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}XFCE${RESET} ~ panels and launchers"
xfce4-panel-profiles load ./res/pentest-panel-config.tar.bz2



##### Clean the system
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) ${GREEN}Cleaning Up${RESET} "
#--- Reset folder location
cd ~/ &>/dev/null
#--- Remove any history files (as they could contain sensitive info)
history -c 2>/dev/null
find ~/ -type f -name '.*_history' -delete


##### Time taken
finish_time=$(date +%s)
echo -e "\n\n ${YELLOW}[i]${RESET} Time (roughly) taken: ${YELLOW}$(( $(( finish_time - start_time )) / 60 )) minutes${RESET}"


#-Done-----------------------------------------------------------------#


echo -e '\n'${BLUE}'[*]'${RESET}' '${BOLD}'Done!'${RESET}'\n\a'
exit 0