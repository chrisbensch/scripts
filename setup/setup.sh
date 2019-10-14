#!/bin/bash
#-Metadata----------------------------------------------------#
#  Filename: setup.sh             (Update: 2017-10-26)        #
#-Info--------------------------------------------------------#
#  Personal post-install script for Kali Linux Rolling        #
#  This installs the common tools                             #
#-Author(s)---------------------------------------------------#
#  chrisbensch ~ https://github.com/chrisbensch               #
#  g0tmi1k ~ https://github.com/g0tmi1k/os-scripts original   #
#-------------------------------------------------------------#

#-Defaults-------------------------------------------------------------#


##### Location information
keyboardApple=false         # Using a Apple/Macintosh keyboard (non VM)?                [ --osx ]
keyboardLayout="us"         # Set keyboard layout                                       [ --keyboard gb]
timezone="Asia/Tokyo"       # Set timezone location                                     [ --timezone Europe/London ]

##### Optional steps
burpFree=true              # Disable configuring Burp Suite (for Burp Pro users...)    [ --burp ]
hardenDNS=false            # Set static & lock DNS name server                         [ --dns ]
openVAS=false              # Install & configure OpenVAS (not everyone wants it...)    [ --openvas ]

##### (Optional) Enable debug mode?
#set -x

##### (Cosmetic) Colour output
RED="\033[01;31m"      # Issues/Errors
GREEN="\033[01;32m"    # Success
YELLOW="\033[01;33m"   # Warnings/Information
BLUE="\033[01;34m"     # Heading
BOLD="\033[01;01m"     # Highlight
RESET="\033[00m"       # Normal

STAGE=0                                                       # Where are we up to
TOTAL=$(grep '(${STAGE}/${TOTAL})' $0 | wc -l);(( TOTAL-- ))  # How many things have we got todo


#-Arguments------------------------------------------------------------#


##### Read command line arguments
while [[ "${#}" -gt 0 && ."${1}" == .-* ]]; do
  opt="${1}";
  shift;
  case "$(echo ${opt} | tr '[:upper:]' '[:lower:]')" in
    -|-- ) break 2;;

    -osx|--osx )
      keyboardApple=true;;
    -apple|--apple )
      keyboardApple=true;;

    -dns|--dns )
      hardenDNS=true;;

    -openvas|--openvas )
      openVAS=true;;

    -burp|--burp )
      burpFree=true;;

    -keyboard|--keyboard )
      keyboardLayout="${1}"; shift;;
    -keyboard=*|--keyboard=* )
      keyboardLayout="${opt#*=}";;

    -timezone|--timezone )
      timezone="${1}"; shift;;
    -timezone=*|--timezone=* )
      timezone="${opt#*=}";;

    *) echo -e ' '${RED}'[!]'${RESET}" Unknown option: ${RED}${x}${RESET}" 1>&2 \
      && exit 1;;
   esac
done


#-Start----------------------------------------------------------------#


###### Enable default network repositories ~ http://docs.kali.org/general-use/kali-linux-sources-list-repositories
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Enabling Berkeley Kali${GREEN} network repositories${RESET}"
##--- Add network repositories
file=/etc/apt/sources.list; [ -e "${file}" ] && cp -n $file{,.bkup}
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
##--- Main

echo -e "\n\n# Kali Rolling\ndeb https://kali.download/kali kali-rolling main contrib non-free" > "${file}"
##--- Source
#grep -q '^deb-src .* kali-rolling' "${file}" 2>/dev/null \
#  || echo -e "deb-src https://mirrors.ocf.berkeley.edu/kali kali-rolling main contrib non-free" >> "${file}"
echo -e "deb-src https://kali.download/kali kali-rolling main contrib non-free" >> "${file}"
##--- Disable CD repositories
sed -i '/kali/ s/^\( \|\t\|\)deb cdrom/#deb cdrom/g' "${file}"
#--- incase we were interrupted
dpkg --configure -a
#--- Update
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Updating Kali ${GREEN}network repositories${RESET}"
apt -qq update
if [[ "$?" -ne 0 ]]; then
  echo -e ' '${RED}'[!]'${RESET}" There was an ${RED}issue accessing network repositories${RESET}" 1>&2
  echo -e " ${YELLOW}[i]${RESET} Are the remote network repositories ${YELLOW}currently being sync'd${RESET}?"
  echo -e " ${YELLOW}[i]${RESET} Here is ${BOLD}YOUR${RESET} local network ${BOLD}repository${RESET} information (Geo-IP based):\n"
  curl -sI http://http.kali.org/README | grep X-MirrorBrain-Mirror | cut -d' ' -f 2
  exit 1
fi


##### Check to see if Kali is in a VM. If so, install "Virtual Machine Addons/Tools" for a "better" virtual experiment
if (dmidecode | grep -iq vmware); then
  ##### Install virtual machines tools ~ http://docs.kali.org/general-use/install-vmware-tools-kali-guest
  (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}VMware's (open) virtual machine tools${RESET}"
  apt -y -qq install open-vm-tools-desktop open-vm-tools \
    || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
  ## Shared folders support for Open-VM-Tools (some odd bug)
  file=/usr/local/sbin/mount-shared-folders; [ -e "${file}" ] && cp -n $file{,.bkup}
  cat <<EOF > "${file}" \
    || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

vmware-hgfsclient | while read folder; do
  echo "[i] Mounting \${folder}   (/mnt/hgfs/\${folder})"
  mkdir -p "/mnt/hgfs/\${folder}"
  umount -f "/mnt/hgfs/\${folder}" 2>/dev/null
  vmhgfs-fuse -o allow_other -o auto_unmount ".host:/\${folder}" "/mnt/hgfs/\${folder}"
done

sleep 2s
EOF
  chmod +x "${file}"
  ln -sf "${file}" /root/Desktop/mount-shared-folders.sh
  ## Restart Open-VM-Tools
file=/usr/local/sbin/restart-vm-tools; [ -e "${file}" ] && cp -n $file{,.bkup}
  cat <<EOF > "${file}" \
    || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash
killall -q -w vmtoolsd
vmware-user-suid-wrapper vmtoolsd -n vmusr 2>/dev/null
vmtoolsd -b /var/run/vmroot 2>/dev/null
EOF
  chmod +x "${file}"
  ln -sf "${file}" /root/Desktop/restart-vm-tools.sh
elif (dmidecode | grep -iq virtualbox); then
  ##### Installing VirtualBox Guest Additions.   Note: Need VirtualBox 4.2.xx+ for the host (http://docs.kali.org/general-use/kali-linux-virtual-box-guest)
  (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}VirtualBox's guest additions${RESET}"
  apt -y -qq install virtualbox-guest-x11 virtualbox-guest-utils virtualbox-guest-dkms \
    || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
fi


###### Check to see if there is a second Ethernet card (if so, set an static IP address)
ip addr show eth1 &>/dev/null
if [[ "$?" == 0 ]]; then
  ##### Set a static IP address (192.168.155.175/24) on eth1
  (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${S TAGE}/${TOTAL}) Setting a ${GREEN}static IP ddress${RESET}# (${BOLD}192.168.155.175/24${RESET}) on ${BOLD}eth1${RESET}"
  ip addr add 192.168.155.175/24 dev eth1 2>/dev/null
  route delete default gw 192.168.155.1 2>/dev/null
  file=/etc/network/interfaces.d/eth1.cfg; [ -e "${file}" ] && cp -n $file{,.bkup}
  grep -q '^iface eth1 inet static' "${file}" 2>/dev/null \
    || cat <<EOF > "${file}"
auto eth1
iface eth1 inet static
    address 192.168.155.175
    netmask 255.255.255.0
    gateway 192.168.155.1
    post-up route delete default gw 192.168.155.1
EOF
else
  echo -e "\n\n ${YELLOW}[i]${RESET} ${YELLOW}Skipping eth1${RESET} (missing nic)..." 1>&2
fi


#--- Changing time zone
if [[ -n "${timezone}" ]]; then
  (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Updating ${GREEN}location information${RESET} ~ time zone (${BOLD}${timezone}${RESET})"
  echo "${timezone}" > /etc/timezone
  ln -sf "/usr/share/zoneinfo/$(cat /etc/timezone)" /etc/localtime
  dpkg-reconfigure -f noninteractive tzdata
else
  echo -e "\n\n ${YELLOW}[i]${RESET} ${YELLOW}Skipping time zone${RESET} (missing: '$0 ${BOLD}--timezone <value>${RESET}')..." 1>&2
fi
#--- Installing ntp tools
apt -y -qq install ntpdate \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Update time
ntpdate -b -s -u pool.ntp.org
#--- Start service
systemctl restart ntp
#--- Remove from start up
systemctl disable ntp 2>/dev/null
#--- Only used for stats at the end
start_time=$(date +%s)


##### Update OS from network repositories
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) ${GREEN}Updating OS${RESET} from network repositories"
echo -e " ${YELLOW}[i]${RESET}  ...this ${BOLD}may take a while${RESET} depending on your Internet connection & Kali version/age"

for FILE in clean autoremove; do apt -y -qq "${FILE}"; done         # Clean up      clean remove autoremove autoclean
export DEBIAN_FRONTEND=noninteractive
APT_LISTCHANGES_FRONTEND=none apt-get -o Dpkg::Options::="--force-confnew" -y dist-upgrade --fix-missing 2>&1 \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Cleaning up temp stuff
for FILE in clean autoremove; do apt -y -qq "${FILE}"; done         # Clean up - clean remove autoremove autoclean
#--- Check kernel stuff
_TMP=$(dpkg -l | grep linux-image- | grep -vc meta)
if [[ "${_TMP}" -gt 1 ]]; then
  echo -e "\n ${YELLOW}[i]${RESET} Detected ${YELLOW}multiple kernels${RESET}"
  TMP=$(dpkg -l | grep linux-image | grep -v meta | sort -t '.' -k 2 -g | tail -n 1 | grep "$(uname -r)")
  if [[ -z "${TMP}" ]]; then
    echo -e '\n '${RED}'[!]'${RESET}' You are '${RED}'not using the latest kernel'${RESET} 1>&2
    echo -e " ${YELLOW}[i]${RESET} You have it ${YELLOW}downloaded${RESET} & installed, just ${YELLOW}not USING IT${RESET}"
    #echo -e "\n ${YELLOW}[i]${RESET} You ${YELLOW}NEED to REBOOT${RESET}, before re-running this script"
    #exit 1
    sleep 30s
  else
    echo -e " ${YELLOW}[i]${RESET} ${YELLOW}You're using the latest kernel${RESET} (Good to continue)"
  fi
fi


##### Install build essential tools
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}build-essential${RESET}"
apt -y -qq install build-essential \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2

##### Install kernel headers
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}kernel headers${RESET}"
apt -y -qq install "linux-headers-$(uname -r)" \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
if [[ $? -ne 0 ]]; then
  echo -e ' '${RED}'[!]'${RESET}" There was an ${RED}issue installing kernel headers${RESET}" 1>&2
  echo -e " ${YELLOW}[i]${RESET} Are you ${YELLOW}USING${RESET} the ${YELLOW}latest kernel${RESET}?"
  echo -e " ${YELLOW}[i]${RESET} ${YELLOW}Reboot${RESET} your machine"
  #exit 1
  sleep 30s
fi


##### Install "kali full" meta packages (default tool selection)
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}kali-linux-full${RESET} meta-package"
echo -e " ${YELLOW}[i]${RESET}  ...this ${BOLD}may take a while${RESET} depending on your Kali version (e.g. ARM, light, mini or docker...)"
#--- Kali's default tools ~ https://www.kali.org/news/kali-linux-metapackages/
apt -y -qq install kali-linux-full \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Set audio level
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Setting ${GREEN}audio${RESET} levels"
systemctl --user enable pulseaudio
systemctl --user start pulseaudio
pactl set-sink-mute 0 0
pactl set-sink-volume 0 25%


##### Configure GRUB
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}GRUB${RESET} ~ boot manager"
grubTimeout=5
(dmidecode | grep -iq virtual) && grubTimeout=1   # Much less if we are in a VM
file=/etc/default/grub; [ -e "${file}" ] && cp -n $file{,.bkup}
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT='${grubTimeout}'/' "${file}"                           # Time out (lower if in a virtual machine, else possible dual booting)
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="vga=0x0318"/' "${file}"   # TTY resolution
update-grub


#### Install Sublime Text
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Sublime Text${RESET} ~ Awesome Editor"
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
apt -y -qq install apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
apt -y -qq update
apt -y -qq install sublime-text

# Run once to do basic setup
subl >/dev/null 2>&1                # Start and kill. Files/folders needed for first time run
sleep 5
killall -9 -q -w sublime_text >/dev/null

# Install Package Control
mkdir -p "/root/.config/sublime-text-3/Installed Packages/"
cd "/root/.config/sublime-text-3/Installed Packages/"
curl --progress -k -L -f "https://packagecontrol.io/Package%20Control.sublime-package" -o "Package Control.sublime-package" 2>/dev/null

# Configure Install Packages
mkdir -p /root/.config/sublime-text-3/Packages/User/
file="/root/.config/sublime-text-3/Packages/User/Package Control.sublime-settings"
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
{
  "installed_packages":
  [
    "GitGutter",
    "Package Control",
    "PowerShell",
    "SideBarEnhancements",
    "Theme - Cobalt2",
    "WordCount"
  ]
}
EOF

# Run ST3 once to get Package Control set up
subl >/dev/null 2>&1
sleep 10
killall -9 -q -w sublime_text >/dev/null

# Run ST3 once again to get packages installed
subl >/dev/null 2>&1
sleep 60
killall -9 -q -w sublime_text >/dev/null

# Configure special settings
mkdir -p /root/.config/sublime-text-3/Packages/User/
file=/root/.config/sublime-text-3/Packages/User/Preferences.sublime-settings; [ -e "${file}" ] && cp -n $file{,.bkup}
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
{
  "auto_complete": false,
  "bold_folder_labels": true,
  "caret_extra_bottom": 2,
  "caret_extra_top": 2,
  "caret_extra_width": 8,
  "caret_style": "phase",
  "color_scheme": "Packages/Theme - Cobalt2/cobalt2.tmTheme",
  "font_size": 12,
  "highlight_line": true,
  "highlight_modified_tabs": true,
  "hot_exit": false,
  "ignored_packages":
  [
    "Vintage"
  ],
  "indent_guide_options":
  [
    "draw_normal",
    "draw_active"
  ],
  "line_padding_bottom": 1,
  "line_padding_top": 1,
  "remember_open_files": false,
  "sidebar_font_big": true,
  "theme": "Cobalt2.sublime-theme",
  "theme_bar": true,
  "theme_sidebar_disclosure": true,
  "theme_sidebar_indent_sm": true,
  "theme_statusbar_colored": true,
  "theme_tab_highlight_text_only": true,
  "wide_caret": true,
  "word_wrap": true
}
EOF


##### Configure bash - all users
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}bash${RESET} ~ CLI shell"
file=/etc/bash.bashrc; [ -e "${file}" ] && cp -n $file{,.bkup}   #~/.bashrc
#grep -q "cdspell" "${file}" \
#  || echo "shopt -sq cdspell" >> "${file}"             # Spell check 'cd' commands
#grep -q "autocd" "${file}" \
# || echo "shopt -s autocd" >> "${file}"                # So you don't have to 'cd' before a folder
##grep -q "CDPATH" "${file}" \
## || echo "CDPATH=/etc:/usr/share/:/opt" >> "${file}"  # Always CD into these folders
grep -q "checkwinsize" "${file}" \
 || echo "shopt -sq checkwinsize" >> "${file}"         # Wrap lines correctly after resizing
#grep -q "nocaseglob" "${file}" \
# || echo "shopt -sq nocaseglob" >> "${file}"           # Case insensitive pathname expansion
grep -q "HISTSIZE" "${file}" \
 || echo "HISTSIZE=10000" >> "${file}"                 # Bash history (memory scroll back)
grep -q "HISTFILESIZE" "${file}" \
 || echo "HISTFILESIZE=10000" >> "${file}"             # Bash history (file .bash_history)
#--- Apply new configs
source "${file}" || source ~/.zshrc

##### Install bash colour - all users
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}bash colour${RESET} ~ colours shell output"
file=/etc/bash.bashrc; [ -e "${file}" ] && cp -n $file{,.bkup}   #~/.bashrc
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
sed -i 's/.*force_color_prompt=.*/force_color_prompt=yes/' "${file}"
grep -q '^force_color_prompt' "${file}" 2>/dev/null \
  || echo 'force_color_prompt=yes' >> "${file}"
sed -i 's#PS1='"'"'.*'"'"'#PS1='"'"'${debian_chroot:+($debian_chroot)}\\[\\033\[01;31m\\]\\u@\\h\\\[\\033\[00m\\]:\\[\\033\[01;34m\\]\\w\\[\\033\[00m\\]\\$ '"'"'#' "${file}"
grep -q "^export LS_OPTIONS='--color=auto'" "${file}" 2>/dev/null \
  || echo "export LS_OPTIONS='--color=auto'" >> "${file}"
grep -q '^eval "$(dircolors)"' "${file}" 2>/dev/null \
  || echo 'eval "$(dircolors)"' >> "${file}"
grep -q "^alias ls='ls $LS_OPTIONS'" "${file}" 2>/dev/null \
  || echo "alias ls='ls $LS_OPTIONS'" >> "${file}"
grep -q "^alias ll='ls $LS_OPTIONS -l'" "${file}" 2>/dev/null \
  || echo "alias ll='ls $LS_OPTIONS -l'" >> "${file}"
grep -q "^alias l='ls $LS_OPTIONS -lA'" "${file}" 2>/dev/null \
  || echo "alias l='ls $LS_OPTIONS -lA'" >> "${file}"
#--- All other users that are made afterwards
file=/etc/skel/.bashrc   #; [ -e "${file}" ] && cp -n $file{,.bkup}
sed -i 's/.*force_color_prompt=.*/force_color_prompt=yes/' "${file}"
#--- Apply new configs
source "${file}" || source ~/.zshrc


###### Install grc
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}grc${RESET} ~ colours #shell output"
apt -y -qq install grc \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Setup aliases
file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
grep -q '^## grc diff alias' "${file}" 2>/dev/null \
  || echo -e "## grc diff alias\nalias diff='$(which grc) $(which diff)'\n" >> "${file}"
grep -q '^## grc dig alias' "${file}" 2>/dev/null \
  || echo -e "## grc dig alias\nalias dig='$(which grc) $(which dig)'\n" >> "${file}"
grep -q '^## grc gcc alias' "${file}" 2>/dev/null \
  || echo -e "## grc gcc alias\nalias gcc='$(which grc) $(which gcc)'\n" >> "${file}"
grep -q '^## grc ifconfig alias' "${file}" 2>/dev/null \
  || echo -e "## grc ifconfig alias\nalias ifconfig='$(which grc) $(which ifconfig)'\n" >> "${file}"
grep -q '^## grc mount alias' "${file}" 2>/dev/null \
  || echo -e "## grc mount alias\nalias mount='$(which grc) $(which mount)'\n" >> "${file}"
grep -q '^## grc netstat alias' "${file}" 2>/dev/null \
  || echo -e "## grc netstat alias\nalias netstat='$(which grc) $(which netstat)'\n" >> "${file}"
grep -q '^## grc ping alias' "${file}" 2>/dev/null \
  || echo -e "## grc ping alias\nalias ping='$(which grc) $(which ping)'\n" >> "${file}"
grep -q '^## grc ps alias' "${file}" 2>/dev/null \
  || echo -e "## grc ps alias\nalias ps='$(which grc) $(which ps)'\n" >> "${file}"
grep -q '^## grc tail alias' "${file}" 2>/dev/null \
  || echo -e "## grc tail alias\nalias tail='$(which grc) $(which tail)'\n" >> "${file}"
grep -q '^## grc traceroute alias' "${file}" 2>/dev/null \
  || echo -e "## grc traceroute alias\nalias traceroute='$(which grc) $(which traceroute)'\n" >> "${file}"
grep -q '^## grc wdiff alias' "${file}" 2>/dev/null \
  || echo -e "## grc wdiff alias\nalias wdiff='$(which grc) $(which wdiff)'\n" >> "${file}"
#configure  #esperanto  #ldap  #e  #cvs  #log  #mtr  #ls  #irclog  #mount2  #mount
#--- Apply new aliases
source "${file}" || source ~/.zshrc


##### Install bash completion - all users
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}bash completion${RESET} ~ tab complete CLI commands"
file=/etc/bash.bashrc; [ -e "${file}" ] && cp -n $file{,.bkup}   #~/.bashrc
sed -i '/# enable bash completion in/,+7{/enable bash completion/!s/^#//}' "${file}"
#--- Apply new configs
source "${file}" || source ~/.zshrc


##### Configure aliases - root user
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}aliases${RESET} ~ CLI shortcuts"
#--- Enable defaults - root user
for FILE in /etc/bash.bashrc ~/.bashrc ~/.bash_aliases; do    #/etc/profile /etc/bashrc /etc/bash_aliases /etc/bash.bash_aliases
  [[ ! -f "${FILE}" ]] \
    && continue
  cp -n $FILE{,.bkup}
  sed -i 's/#alias/alias/g' "${FILE}"
done
#--- General system ones
file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
grep -q '^## grep aliases' "${file}" 2>/dev/null \
  || echo -e '## grep aliases\nalias grep="grep --color=always"\nalias ngrep="grep -n"\n' >> "${file}"
grep -q '^alias egrep=' "${file}" 2>/dev/null \
  || echo -e 'alias egrep="egrep --color=auto"\n' >> "${file}"
grep -q '^alias fgrep=' "${file}" 2>/dev/null \
  || echo -e 'alias fgrep="fgrep --color=auto"\n' >> "${file}"
#--- Add in ours (OS programs)
grep -q '^alias tmux' "${file}" 2>/dev/null \
  || echo -e '## tmux\nalias tmux="tmux attach || tmux new"\n' >> "${file}"    #alias tmux="tmux attach -t $HOST || tmux new -s $HOST"
grep -q '^alias axel' "${file}" 2>/dev/null \
  || echo -e '## axel\nalias axel="axel -a"\n' >> "${file}"
grep -q '^alias screen' "${file}" 2>/dev/null \
  || echo -e '## screen\nalias screen="screen -xRR"\n' >> "${file}"
#--- Add in ours (shortcuts)
grep -q '^## Checksums' "${file}" 2>/dev/null \
  || echo -e '## Checksums\nalias sha1="openssl sha1"\nalias md5="openssl md5"\n' >> "${file}"
grep -q '^## Force create folders' "${file}" 2>/dev/null \
  || echo -e '## Force create folders\nalias mkdir="/bin/mkdir -pv"\n' >> "${file}"
#grep -q '^## Mount' "${file}" 2>/dev/null \
#  || echo -e '## Mount\nalias mount="mount | column -t"\n' >> "${file}"
grep -q '^## List open ports' "${file}" 2>/dev/null \
  || echo -e '## List open ports\nalias ports="netstat -tulanp"\n' >> "${file}"
grep -q '^## Get header' "${file}" 2>/dev/null \
  || echo -e '## Get header\nalias header="curl -I"\n' >> "${file}"
grep -q '^## Get external IP address' "${file}" 2>/dev/null \
  || echo -e '## Get external IP address\nalias ipx="curl -s http://ipinfo.io/ip"\n' >> "${file}"
grep -q '^## DNS - External IP #1' "${file}" 2>/dev/null \
  || echo -e '## DNS - External IP #1\nalias dns1="dig +short @resolver1.opendns.com myip.opendns.com"\n' >> "${file}"
grep -q '^## DNS - External IP #2' "${file}" 2>/dev/null \
  || echo -e '## DNS - External IP #2\nalias dns2="dig +short @208.67.222.222 myip.opendns.com"\n' >> "${file}"
grep -q '^## DNS - Check' "${file}" 2>/dev/null \
  || echo -e '### DNS - Check ("#.abc" is Okay)\nalias dns3="dig +short @208.67.220.220 which.opendns.com txt"\n' >> "${file}"
grep -q '^## Directory navigation aliases' "${file}" 2>/dev/null \
  || echo -e '## Directory navigation aliases\nalias ..="cd .."\nalias ...="cd ../.."\nalias ....="cd ../../.."\nalias .....="cd ../../../.."\n' >> "${file}"
grep -q '^## Extract file' "${file}" 2>/dev/null \
  || cat <<EOF >> "${file}" \
    || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2

## Extract file, example. "ex package.tar.bz2"
ex() {
  if [[ -f \$1 ]]; then
    case \$1 in
      *.tar.bz2) tar xjf \$1 ;;
      *.tar.gz)  tar xzf \$1 ;;
      *.bz2)     bunzip2 \$1 ;;
      *.rar)     rar x \$1 ;;
      *.gz)      gunzip \$1  ;;
      *.tar)     tar xf \$1  ;;
      *.tbz2)    tar xjf \$1 ;;
      *.tgz)     tar xzf \$1 ;;
      *.zip)     unzip \$1 ;;
      *.Z)       uncompress \$1 ;;
      *.7z)      7z x \$1 ;;
      *)         echo \$1 cannot be extracted ;;
    esac
  else
    echo \$1 is not a valid file
  fi
}
EOF
grep -q '^## strings' "${file}" 2>/dev/null \
  || echo -e '## strings\nalias strings="strings -a"\n' >> "${file}"
grep -q '^## history' "${file}" 2>/dev/null \
  || echo -e '## history\nalias hg="history | grep"\n' >> "${file}"
grep -q '^## Network Services' "${file}" 2>/dev/null \
  || echo -e '### Network Services\nalias listen="netstat -antp | grep LISTEN"\n' >> "${file}"
grep -q '^## HDD size' "${file}" 2>/dev/null \
  || echo -e '### HDD size\nalias hogs="for i in G M K; do du -ah | grep [0-9]$i | sort -nr -k 1; done | head -n 11"\n' >> "${file}"
grep -q '^## Listing' "${file}" 2>/dev/null \
  || echo -e '### Listing\nalias ll="ls -l --block-size=1 --color=auto"\n' >> "${file}"
#--- Add in tools
#grep -q '^## nmap' "${file}" 2>/dev/null \
#  || echo -e '## nmap\nalias nmap="nmap --reason --open --stats-every 3m --max-retries 1 --max-scan-delay 20 #--defeat-rst-ratelimit"\n' >> "${file}"
grep -q '^## aircrack-ng' "${file}" 2>/dev/null \
  || echo -e '## aircrack-ng\nalias aircrack-ng="aircrack-ng -z"\n' >> "${file}"
grep -q '^## airodump-ng' "${file}" 2>/dev/null \
  || echo -e '## airodump-ng \nalias airodump-ng="airodump-ng --manufacturer --wps --uptime"\n' >> "${file}"
grep -q '^## metasploit' "${file}" 2>/dev/null \
  || (echo -e '## metasploit\nalias msfc="systemctl start postgresql; msfdb start; msfconsole -q \"\$@\""' >> "${file}" \
    && echo -e 'alias msfconsole="systemctl start postgresql; msfdb start; msfconsole \"\$@\""\n' >> "${file}" )
[ "${openVAS}" != "false" ] \
  && (grep -q '^## openvas' "${file}" 2>/dev/null \
    || echo -e '## openvas\nalias openvas="openvas-stop; openvas-start; sleep 3s; xdg-open https://127.0.0.1:9392/ >/dev/null 2>&1"\n' >> "${file}")
grep -q '^## mana-toolkit' "${file}" 2>/dev/null \
  || (echo -e '## mana-toolkit\nalias mana-toolkit-start="a2ensite 000-mana-toolkit;a2dissite 000-default; systemctl restart apache2"' >> "${file}" \
    && echo -e 'alias mana-toolkit-stop="a2dissite 000-mana-toolkit; a2ensite 000-default; systemctl restart apache2"\n' >> "${file}" )
grep -q '^## ssh' "${file}" 2>/dev/null \
  || echo -e '## ssh\nalias ssh-start="systemctl restart ssh"\nalias ssh-stop="systemctl stop ssh"\n' >> "${file}"
grep -q '^## samba' "${file}" 2>/dev/null \
  || echo -e '## samba\nalias smb-start="systemctl restart smbd nmbd"\nalias smb-stop="systemctl stop smbd nmbd"\n' >> "${file}"
grep -q '^## rdesktop' "${file}" 2>/dev/null \
  || echo -e '## rdesktop\nalias rdesktop="rdesktop -z -P -g 90% -r disk:local=\"/tmp/\""\n' >> "${file}"
grep -q '^## python http' "${file}" 2>/dev/null \
  || echo -e '## python http\nalias http="python2 -m SimpleHTTPServer"\n' >> "${file}"
#--- Add in folders
grep -q '^## www' "${file}" 2>/dev/null \
  || echo -e '## www\nalias wwwroot="cd /var/www/html/"\n#alias www="cd /var/www/html/"\n' >> "${file}"
grep -q '^## ftp' "${file}" 2>/dev/null \
  || echo -e '## ftp\nalias ftproot="cd /var/ftp/"\n' >> "${file}"
grep -q '^## tftp' "${file}" 2>/dev/null \
  || echo -e '## tftp\nalias tftproot="cd /var/tftp/"\n' >> "${file}"
grep -q '^## smb' "${file}" 2>/dev/null \
  || echo -e '## smb\nalias smb="cd /var/samba/"\n#alias smbroot="cd /var/samba/"\n' >> "${file}"
(dmidecode | grep -iq vmware) \
  && (grep -q '^## vmware' "${file}" 2>/dev/null \
    || echo -e '## vmware\nalias vmroot="cd /mnt/hgfs/"\n' >> "${file}")
grep -q '^## edb' "${file}" 2>/dev/null \
  || echo -e '## edb\nalias edb="cd /usr/share/exploitdb/platforms/"\nalias edbroot="cd /usr/share/exploitdb/platforms/"\n' >> "${file}"
grep -q '^## wordlist' "${file}" 2>/dev/null \
  || echo -e '## wordlist\nalias wordlists="cd /usr/share/wordlists/"\n' >> "${file}"
#--- Apply new aliases
source "${file}" || source ~/.zshrc
#--- Check
#alias


##### Install (GNOME) Terminator
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing (GNOME) ${GREEN}Terminator${RESET} ~ multiple terminals in a single window"
apt -y -qq install terminator \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Configure terminator
mkdir -p ~/.config/terminator/
file=~/.config/terminator/config; [ -e "${file}" ] && cp -n $file{,.bkup}
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
[global_config]
  enabled_plugins = TerminalShot, LaunchpadCodeURLHandler, APTURLHandler, LaunchpadBugURLHandler
  geometry_hinting = True
[keybindings]
[layouts]
  [[default]]
    [[[child0]]]
      fullscreen = False
      last_active_term = a8ddd1c9-44db-44fe-9b76-7d95c8249ca2
      last_active_window = True
      maximised = False
      order = 0
      parent = ""
      size = 960, 667
      type = Window
    [[[terminal1]]]
      order = 0
      parent = child0
      profile = default
      type = Terminal
      uuid = a8ddd1c9-44db-44fe-9b76-7d95c8249ca2
[plugins]
[profiles]
  [[default]]
    background_darkness = 0.9
    copy_on_selection = True
    cursor_color = "#8ae234"
    cursor_color_fg = False
    scrollback_infinite = True
    show_titlebar = False

EOF


##### Install tmux - all users
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}tmux${RESET} ~ multiplex virtual consoles"
file=~/.tmux.conf; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/tmux.conf
#--- Configure tmux
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#-Settings---------------------------------------------------------------------
## Make it like screen (use CTRL+a)
unbind C-b
set -g prefix C-a

## Pane switching (SHIFT+ARROWS)
bind-key -n S-Left select-pane -L
bind-key -n S-Right select-pane -R
bind-key -n S-Up select-pane -U
bind-key -n S-Down select-pane -D

## Windows switching (ALT+ARROWS)
bind-key -n M-Left  previous-window
bind-key -n M-Right next-window

## Windows re-ording (SHIFT+ALT+ARROWS)
bind-key -n M-S-Left swap-window -t -1
bind-key -n M-S-Right swap-window -t +1

## Activity Monitoring
setw -g monitor-activity on
set -g visual-activity on

## Set defaults
set -g default-terminal screen-256color
set -g history-limit 5000

## Default windows titles
set -g set-titles on
set -g set-titles-string '#(whoami)@#H - #I:#W'

## Last window switch
bind-key C-a last-window

## Reload settings (CTRL+a -> r)
unbind r
bind r source-file /etc/tmux.conf

## Load custom sources
#source ~/.bashrc   #(issues if you use /bin/bash & Debian)

EOF
[ -e /bin/zsh ] \
  && echo -e '## Use ZSH as default shell\nset-option -g default-shell /bin/zsh\n' >> "${file}"
cat <<EOF >> "${file}"
## Show tmux messages for longer
set -g display-time 3000

## Status bar is redrawn every minute
set -g status-interval 60


#-Theme------------------------------------------------------------------------
## Default colours
set -g status-bg black
set -g status-fg white

## Left hand side
set -g status-left-length '34'
set -g status-left '#[fg=green,bold]#(whoami)#[default]@#[fg=yellow,dim]#H #[fg=green,dim][#[fg=yellow]#(cut -d " " -f 1-3 /proc/loadavg)#[fg=green,dim]]'

## Inactive windows in status bar
set-window-option -g window-status-format '#[fg=red,dim]#I#[fg=grey,dim]:#[default,dim]#W#[fg=grey,dim]'

## Current or active window in status bar
#set-window-option -g window-status-current-format '#[bg=white,fg=red]#I#[bg=white,fg=grey]:#[bg=white,fg=black]#W#[fg=dim]#F'
set-window-option -g window-status-current-format '#[fg=red,bold](#[fg=white,bold]#I#[fg=red,dim]:#[fg=white,bold]#W#[fg=red,bold])'

## Right hand side
set -g status-right '#[fg=green][#[fg=yellow]%Y-%m-%d #[fg=white]%H:%M#[fg=green]]'
EOF
#--- Setup alias
file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
grep -q '^alias tmux' "${file}" 2>/dev/null \
  || echo -e '## tmux\nalias tmux="tmux attach || tmux new"\n' >> "${file}"    #alias tmux="tmux attach -t $HOST || tmux new -s $HOST"
#--- Apply new alias
source "${file}" || source ~/.zshrc


##### Install vim - all users
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}vim${RESET} ~ CLI text editor"
#--- Configure vim
file=/etc/vim/vimrc; [ -e "${file}" ] && cp -n $file{,.bkup}   #~/.vimrc
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
sed -i 's/.*syntax on/syntax on/' "${file}"
sed -i 's/.*set background=dark/set background=dark/' "${file}"
sed -i 's/.*set showcmd/set showcmd/' "${file}"
sed -i 's/.*set showmatch/set showmatch/' "${file}"
#sed -i 's/.*set ignorecase/set ignorecase/' "${file}"
#sed -i 's/.*set smartcase/set smartcase/' "${file}"
#sed -i 's/.*set incsearch/set incsearch/' "${file}"
#sed -i 's/.*set autowrite/set autowrite/' "${file}"
#sed -i 's/.*set hidden/set hidden/' "${file}"
#sed -i 's/.*set mouse=.*/"set mouse=a/' "${file}"
grep -q '^set number' "${file}" 2>/dev/null \
  || echo 'set number' >> "${file}"                                                                      # Add line numbers
grep -q '^set expandtab' "${file}" 2>/dev/null \
  || echo -e 'set expandtab\nset smarttab' >> "${file}"                                                  # Set use spaces instead of tabs
grep -q '^set softtabstop' "${file}" 2>/dev/null \
  || echo -e 'set softtabstop=4\nset shiftwidth=4' >> "${file}"                                          # Set 4 spaces as a 'tab'
grep -q '^set foldmethod=marker' "${file}" 2>/dev/null \
  || echo 'set foldmethod=marker' >> "${file}"                                                           # Folding
grep -q '^nnoremap <space> za' "${file}" 2>/dev/null \
  || echo 'nnoremap <space> za' >> "${file}"                                                             # Space toggle folds
grep -q '^set hlsearch' "${file}" 2>/dev/null \
  || echo 'set hlsearch' >> "${file}"                                                                    # Highlight search results
grep -q '^set laststatus' "${file}" 2>/dev/null \
  || echo -e 'set laststatus=2\nset statusline=%F%m%r%h%w\ (%{&ff}){%Y}\ [%l,%v][%p%%]' >> "${file}"     # Status bar
grep -q '^filetype on' "${file}" 2>/dev/null \
  || echo -e 'filetype on\nfiletype plugin on\nsyntax enable\nset grepprg=grep\ -nH\ $*' >> "${file}"    # Syntax highlighting
grep -q '^set wildmenu' "${file}" 2>/dev/null \
  || echo -e 'set wildmenu\nset wildmode=list:longest,full' >> "${file}"                                 # Tab completion
grep -q '^set invnumber' "${file}" 2>/dev/null \
  || echo -e ':nmap <F8> :set invnumber<CR>' >> "${file}"                                                # Toggle line numbers
#grep -q '^set pastetoggle=<F9>' "${file}" 2>/dev/null \
#  || echo -e 'set pastetoggle=<F9>' >> "${file}"                                                         # Hotkey - turning off auto indent when pasting
#grep -q '^:command Q q' "${file}" 2>/dev/null \
#  || echo -e ':command Q q' >> "${file}"                                                                 # Fix stupid typo I always make
#--- Set as default editor
export EDITOR="vim"   #update-alternatives --config editor
file=/etc/bash.bashrc; [ -e "${file}" ] && cp -n $file{,.bkup}
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
grep -q '^EDITOR' "${file}" 2>/dev/null \
  || echo 'EDITOR="vim"' >> "${file}"
git config --global core.editor "vim"
#--- Set as default mergetool
git config --global merge.tool vimdiff
git config --global merge.conflictstyle diff3
git config --global mergetool.prompt false


###### Setup firefox
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}firefox${RESET} ~ GUI web browser"
timeout 15 firefox >/dev/null 2>&1                # Start and kill. Files needed for first time run
timeout 5 killall -9 -q -w firefox-esr >/dev/null
#--- Wipe session (due to force close)
find ~/.mozilla/firefox/*.default*/ -maxdepth 1 -type f -name 'sessionstore.*' -delete
#
file=$(find ~/.mozilla/firefox/*.default*/ -maxdepth 1 -type f -name 'prefs.js' -print -quit)
[ -e "${file}" ] \
  && cp -n $file{,.bkup}
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
sqlite3 "${file}" ".restore /opt/scripts/misc/places.sqlite.backup"


##### Install metasploit ~ http://docs.kali.org/general-use/starting-metasploit-framework-in-kali
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}metasploit${RESET} ~ exploit framework"
mkdir -p ~/.msf5/modules/{auxiliary,exploits,payloads,post}/
#--- Fix any port issues
file=$(find /etc/postgresql/*/main/ -maxdepth 1 -type f -name postgresql.conf -print -quit);
[ -e "${file}" ] && cp -n $file{,.bkup}
sed -i 's/port = .* #/port = 5432 /' "${file}"
#--- Fix permissions - 'could not translate host name "localhost", service "5432" to address: Name or service not known'
chmod 0644 /etc/hosts
#--- Start services
systemctl stop postgresql
systemctl start postgresql
msfdb reinit
sleep 5s
#--- Autorun Metasploit commands each startup
file=~/.msf5/msf_autorunscript.rc; [ -e "${file}" ] && cp -n $file{,.bkup}
if [[ -f "${file}" ]]; then
  echo -e ' '${RED}'[!]'${RESET}" ${file} detected. Skipping..." 1>&2
else
  cat <<EOF > "${file}"
#run post/windows/escalate/getsystem

#run migrate -f -k
#run migrate -n "explorer.exe" -k    # Can trigger AV alerts by touching explorer.exe...

#run post/windows/manage/smart_migrate
#run post/windows/gather/smart_hashdump
EOF
fi
file=~/.msf5/msfconsole.rc; [ -e "${file}" ] && cp -n $file{,.bkup}
if [[ -f "${file}" ]]; then
  echo -e ' '${RED}'[!]'${RESET}" ${file} detected. Skipping..." 1>&2
else
  cat <<EOF > "${file}"
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
setg LPORT 443
use exploit/multi/handler
#setg AutoRunScript 'multi_console_command -rc "~/.msf5/msf_autorunscript.rc"'
set PAYLOAD windows/meterpreter/reverse_https
EOF
fi
#--- Aliases time
file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
#--- Aliases for console
grep -q '^alias msfc=' "${file}" 2>/dev/null \
  || echo -e 'alias msfc="systemctl start postgresql; msfdb start; msfconsole -q \"\$@\""' >> "${file}"
grep -q '^alias msfconsole=' "${file}" 2>/dev/null \
  || echo -e 'alias msfconsole="systemctl start postgresql; msfdb start; msfconsole \"\$@\""\n' >> "${file}"
#--- Aliases to speed up msfvenom (create static output)
grep -q "^alias msfvenom-list-all" "${file}" 2>/dev/null \
  || echo "alias msfvenom-list-all='cat ~/.msf5/msfvenom/all'" >> "${file}"
grep -q "^alias msfvenom-list-nops" "${file}" 2>/dev/null \
  || echo "alias msfvenom-list-nops='cat ~/.msf5/msfvenom/nops'" >> "${file}"
grep -q "^alias msfvenom-list-payloads" "${file}" 2>/dev/null \
  || echo "alias msfvenom-list-payloads='cat ~/.msf5/msfvenom/payloads'" >> "${file}"
grep -q "^alias msfvenom-list-encoders" "${file}" 2>/dev/null \
  || echo "alias msfvenom-list-encoders='cat ~/.msf5/msfvenom/encoders'" >> "${file}"
grep -q "^alias msfvenom-list-formats" "${file}" 2>/dev/null \
  || echo "alias msfvenom-list-formats='cat ~/.msf5/msfvenom/formats'" >> "${file}"
grep -q "^alias msfvenom-list-generate" "${file}" 2>/dev/null \
  || echo "alias msfvenom-list-generate='_msfvenom-list-generate'" >> "${file}"
grep -q "^function _msfvenom-list-generate" "${file}" 2>/dev/null \
  || cat <<EOF >> "${file}" \
    || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
function _msfvenom-list-generate {
  mkdir -p ~/.msf5/msfvenom/
  msfvenom --list all > ~/.msf5/msfvenom/all
  msfvenom --list nops > ~/.msf5/msfvenom/nops
  msfvenom --list payloads > ~/.msf5/msfvenom/payloads
  msfvenom --list encoders > ~/.msf5/msfvenom/encoders
  msfvenom --help-formats 2> ~/.msf5/msfvenom/formats
}
EOF
#--- Apply new aliases
source "${file}" || source ~/.zshrc
#--- Generate (Can't call alias)
mkdir -p ~/.msf5/msfvenom/
msfvenom --list all > ~/.msf5/msfvenom/all
msfvenom --list nops > ~/.msf5/msfvenom/nops
msfvenom --list payloads > ~/.msf5/msfvenom/payloads
msfvenom --list encoders > ~/.msf5/msfvenom/encoders
msfvenom --help-formats 2> ~/.msf5/msfvenom/formats
#--- First time run with Metasploit
(( STAGE++ )); echo -e " ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) ${GREEN}Starting Metasploit for the first time${RESET} ~ this ${BOLD}will take a ~350 seconds${RESET} (~6 mintues)"
echo "Started at: $(date)"
systemctl start postgresql
msfdb start
msfconsole -q -x 'version;db_status;sleep 310;exit'


##### Configuring armitage
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}armitage${RESET} ~ GUI Metasploit UI"
export MSF_DATABASE_CONFIG=/usr/share/metasploit-framework/config/database.yml
for file in /etc/bash.bashrc ~/.zshrc; do     #~/.bashrc
  [ ! -e "${file}" ] && continue
  [ -e "${file}" ] && cp -n $file{,.bkup}
  ([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
  grep -q 'MSF_DATABASE_CONFIG' "${file}" 2>/dev/null \
    || echo -e 'MSF_DATABASE_CONFIG=/usr/share/metasploit-framework/config/database.yml\n' >> "${file}"
done
#--- Test
#msfrpcd -U msf -P test -f -S -a 127.0.0.1


##### Install OpenVAS
if [[ "${openVAS}" != "false" ]]; then
  (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}OpenVAS${RESET} ~ vulnerability scanner"
  apt -y -qq install openvas \
    || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
  openvas-setup
  #--- Bug fix (target credentials creation)
  mkdir -p /var/lib/openvas/gnupg/
  #--- Bug fix (keys)
  curl --progress -k -L -f "http://www.openvas.org/OpenVAS_TI.asc" | gpg --import - \
    || echo -e ' '${RED}'[!]'${RESET}" Issue downloading OpenVAS_TI.asc" 1>&2
  #--- Make sure all services are correct
  openvas-start
  #--- User control
  username="root"
  password="toor"
  (openvasmd --get-users | grep -q ^admin$) \
    && echo -n 'admin user: ' \
    && openvasmd --delete-user=admin
  (openvasmd --get-users | grep -q "^${username}$") \
    || (echo -n "${username} user: "; openvasmd --create-user="${username}"; openvasmd --user="${username}" --new-password="${password}" >/dev/null)
  echo -e " ${YELLOW}[i]${RESET} OpenVAS username: ${username}"
  echo -e " ${YELLOW}[i]${RESET} OpenVAS password: ${password}   ***${BOLD}CHANGE THIS ASAP${RESET}***"
  echo -e " ${YELLOW}[i]${RESET} Run: # openvasmd --user=root --new-password='<NEW_PASSWORD>'"
  sleep 3s
  openvas-check-setup
  #--- Remove from start up
  systemctl disable openvas-manager
  systemctl disable openvas-scanner
  systemctl disable greenbone-security-assistant
  #--- Setup alias
  file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
  grep -q '^## openvas' "${file}" 2>/dev/null \
    || echo -e '## openvas\nalias openvas="openvas-stop; openvas-start; sleep 3s; xdg-open https://127.0.0.1:9392/ >/dev/null 2>&1"\n' >> "${file}"
  source "${file}" || source ~/.zshrc
else
  echo -e "\n\n ${YELLOW}[i]${RESET} ${YELLOW}Skipping OpenVAS${RESET} (missing: '$0 ${BOLD}--openvas${RESET}')..." 1>&2
fi


##### Install vFeed
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}vFeed${RESET} ~ vulnerability database"
apt -y -qq install vfeed \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Configure python console - all users
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}python console${RESET} ~ tab complete & history support"
export PYTHONSTARTUP=$HOME/.pythonstartup
file=/etc/bash.bashrc; [ -e "${file}" ] && cp -n $file{,.bkup}   #~/.bashrc
grep -q PYTHONSTARTUP "${file}" \
  || echo 'export PYTHONSTARTUP=$HOME/.pythonstartup' >> "${file}"
#--- Python start up file
cat <<EOF > ~/.pythonstartup \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
import readline
import rlcompleter
import atexit
import os

## Tab completion
readline.parse_and_bind('tab: complete')

## History file
histfile = os.path.join(os.environ['HOME'], '.pythonhistory')
try:
    readline.read_history_file(histfile)
except IOError:
    pass

atexit.register(readline.write_history_file, histfile)

## Quit
del os, histfile, readline, rlcompleter
EOF
#--- Apply new configs
source "${file}" || source ~/.zshrc


##### Install wireshark
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}Wireshark${RESET} ~ GUI network protocol analyzer"
#--- Hide running as root warning
mkdir -p ~/.wireshark/
file=~/.wireshark/recent_common;   #[ -e "${file}" ] && cp -n $file{,.bkup}
[ -e "${file}" ] \
  || echo "privs.warn_if_elevated: FALSE" > "${file}"
#--- Disable lua warning
[ -e "/usr/share/wireshark/init.lua" ] \
  && mv -f /usr/share/wireshark/init.lua{,.disabled}


##### Install silver searcher
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}silver searcher${RESET} ~ code searching"
apt -y -qq install silversearcher-ag \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


###### Install rips
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}rips${RESET} ~ source code scanner"
#apt -y -qq install apache2 php git \
#  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#git clone -q -b master https://github.com/ripsscanner/rips.git /opt/rips-git/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/rips-git/ >/dev/null
#git pull -q
#popd >/dev/null
##--- Add to path
#file=/etc/apache2/conf-available/rips.conf
#[ -e "${file}" ] \
#  || cat <<EOF > "${file}"
#Alias /rips /opt/rips-git
#
#<Directory /opt/rips-git/ >
#  Options FollowSymLinks
#  AllowOverride None
#  Order deny,allow
#  Deny from all
#  Allow from 127.0.0.0/255.0.0.0 ::1/128
#  Require all granted
#</Directory>
#EOF
#ln -sf /etc/apache2/conf-available/rips.conf /etc/apache2/conf-enabled/rips.conf
#systemctl restart apache2


###### Install ipcalc & sipcalc
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}ipcalc${RESET} & ${GREEN}sipcalc${RESET} ~ CLI subnet #calculators"
#apt -y -qq install ipcalc sipcalc \
#  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#
#
###### Install asciinema
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}asciinema${RESET} ~ CLI terminal recorder"
#apt -y -qq install asciinema \
#  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install flameshot
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}flameshot${RESET} ~ Powerful yet simple to use screenshot software"
apt -y -qq install flameshot \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


###### Setup pipe viewer
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}pipe viewer${RESET} ~ CLI progress bar"
#apt -y -qq install pv \
#  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install htop
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}htop${RESET} ~ CLI process viewer"
apt -y -qq install htop \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install iotop
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}iotop${RESET} ~ CLI I/O usage"
apt -y -qq install iotop \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install testssl
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}testssl${RESET} ~ Testing TLS/SSL encryption"
apt -y -qq install testssl.sh \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


###### Install UACScript
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}UACScript${RESET} ~ UAC Bypass for Windows 7"
#git clone -q -b master https://github.com/Vozzie/uacscript.git /opt/uacscript-git/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/uacscript-git/ >/dev/null
#git pull -q
#popd >/dev/null
#ln -sf /usr/share/windows-binaries/uac-win7 /opt/uacscript-git/


###### Install MiniReverse_Shell_With_Parameters
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}MiniReverse_Shell_With_Parameters${RESET} ~ Generate #shellcode for a reverse shell"
#git clone -q -b master https://github.com/xillwillx/MiniReverse_Shell_With_Parameters.git /opt/minireverse-shell-with-parameters-git/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/minireverse-shell-with-parameters-git/ >/dev/null
#git pull -q
#popd >/dev/null
#ln -sf /usr/share/windows-binaries/MiniReverse /opt/minireverse-shell-with-parameters-git/


##### Install filezilla
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}FileZilla${RESET} ~ GUI file transfer"
apt -y -qq install filezilla \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install VPN support
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}VPN${RESET} support for Network-Manager"
for FILE in network-manager-openvpn network-manager-pptp network-manager-vpnc network-manager-iodine; do
  apt -y -qq install "${FILE}" \
    || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
done


###### Install httprint
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}httprint${RESET} ~ GUI web server fingerprint"
#apt -y -qq install httprint \
#  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install wafw00f
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}wafw00f${RESET} ~ WAF detector"
git clone https://github.com/EnableSecurity/wafw00f.git /opt/wafw00f-git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2

##### Install aria2c
#lightweight multi-protocol & multi-source command-line download utility
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}aria2${RESET} ~ lightweight multi-protocol & multi-source command-line download utility"
apt -y -qq install aria2 \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2

##### Install aircrack-ng
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Aircrack-ng${RESET} ~ Wi-Fi cracking suite"
apt -y -qq install aircrack-ng curl \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Setup hardware database
mkdir -p /etc/aircrack-ng/
#(timeout 600 airodump-ng-oui-update 2>/dev/null) \
#  || timeout 600 curl --progress -k -L -f "http://standards.ieee.org/develop/regauth/oui/oui.txt" > /etc/aircrack-ng/oui.txt
aria2c http://linuxnet.ca/ieee/oui.txt -d /etc/aircrack-ng
[ -e /etc/aircrack-ng/oui.txt ] \
  && (\grep "(hex)" /etc/aircrack-ng/oui.txt | sed 's/^[ \t]*//g;s/[ \t]*$//g' > /etc/aircrack-ng/airodump-ng-oui.txt)
[[ ! -f /etc/aircrack-ng/airodump-ng-oui.txt ]] \
  && echo -e ' '${RED}'[!]'${RESET}" Issue downloading oui.txt" 1>&2
#--- Setup alias
file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
grep -q '^## aircrack-ng' "${file}" 2>/dev/null \
  || echo -e '## aircrack-ng\nalias aircrack-ng="aircrack-ng -z"\n' >> "${file}"
grep -q '^## airodump-ng' "${file}" 2>/dev/null \
  || echo -e '## airodump-ng \nalias airodump-ng="airodump-ng --manufacturer --wps --uptime"\n' >> "${file}"    # aircrack-ng 1.2 rc2
#--- Apply new alias
source "${file}" || source ~/.zshrc

##### Install updated nmap-mac-prefixes based on above updated oui.txt
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}nmap-mac-prefixes${RESET} ~ updated from new oui.txt"
cp /opt/scripts/misc/nmap-mac-prefixes /usr/share/nmap/ \
  || echo -e ' '${RED}'[!] Issue downloading nmap-mac-prefixes'${RESET} 1>&2


##### Install vulscan script for nmap
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}vulscan script for nmap${RESET} ~ vulnerability scanner add-on"
apt -y -qq install nmap curl \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
mkdir -p /usr/share/nmap/scripts/vulscan/
git clone https://github.com/scipag/vulscan.git /opt/vulscan-git \
  || echo -e ' '${RED}'[!]'${RESET}" Issue cloning repo" 1>&2      #***!!! hardcoded version! Need to manually check for updates
cp /opt/vulscan-git/*.csv /usr/share/nmap/scripts/vulscan/
cp /opt/vulscan-git/vulscan.nse /usr/share/nmap/scripts/vulscan/
#--- Fix permissions (by default its 0777)
chmod -R 0755 /usr/share/nmap/scripts/; find /usr/share/nmap/scripts/ -type f -exec chmod 0644 {} \;


##### Install onetwopunch
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}onetwopunch${RESET} ~ unicornscan & nmap wrapper"
git clone -q -b master https://github.com/superkojiman/onetwopunch.git /opt/onetwopunch-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/onetwopunch-git/ >/dev/null
git pull -q
popd >/dev/null
#--- Add to path
mkdir -p /usr/local/bin/
file=/usr/local/bin/onetwopunch-git
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd /opt/onetwopunch-git/ && bash onetwopunch.sh "\$@"
EOF
chmod +x "${file}"


###### Install Gnmap-Parser (fork)
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Gnmap-Parser (fork)${RESET} ~ Parse Nmap exports into #various plain-text formats"
#git clone -q -b master https://github.com/nullmode/gnmap-parser.git /opt/gnmap-parser-git/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/gnmap-parser-git/ >/dev/null
#git pull -q
#popd >/dev/null
##--- Add to path
#chmod +x /opt/gnmap-parser-git/gnmap-parser.sh
#ln -sf /opt/gnmap-parser-git/gnmap-parser.sh /usr/local/bin/gnmap-parser-git


###### Install azazel
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}azazel${RESET} ~ Linux userland rootkit"
#git clone -q -b master https://github.com/chokepoint/azazel.git /opt/azazel-git/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/azazel-git/ >/dev/null
#git pull -q
#popd >/dev/null


##### Install Babadook
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Babadook${RESET} ~ connection-less powershell Backdoor#"
git clone -q -b master https://github.com/jseidl/Babadook.git /opt/babadook-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/babadook-git/ >/dev/null
git pull -q
popd >/dev/null


##### Install pupy
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}pupy${RESET} ~ Remote Administration Tool"
git clone -q -b master https://github.com/n1nj4sec/pupy.git /opt/pupy-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/pupy-git/ >/dev/null
git pull -q
popd >/dev/null


##### Install gobuster
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}gobuster${RESET} ~ Directory/File/DNS busting tool"
apt -y -qq install gobuster \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


###### Install reGeorg
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}reGeorg${RESET} ~ pivot via web shells"
#git clone -q -b master https://github.com/sensepost/reGeorg.git /opt/regeorg-git \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/regeorg-git/ >/dev/null
#git pull -q
#popd >/dev/null
##--- Link to others
#ln -sf /opt/reGeorg-git /usr/share/webshells/reGeorg


###### Install b374k (https://bugs.kali.org/view.php?id=1097)
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}b374k${RESET} ~ (PHP) web shell"
#apt -y -qq install php-cli \
#  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#git clone -q -b master https://github.com/b374k/b374k.git /opt/b374k-git/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/b374k-git/ >/dev/null
#git pull -q
#php index.php -o b374k.php -s
#popd >/dev/null
##--- Link to others
#apt -y -qq install webshells \
#  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#ln -sf /opt/b374k-git /usr/share/webshells/php/b374k


###### Install cmdsql
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}cmdsql${RESET} ~ (ASPX) web shell"
#git clone -q -b master https://github.com/NetSPI/cmdsql.git /opt/cmdsql-git/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/cmdsql-git/ >/dev/null
#git pull -q
#popd >/dev/null
##--- Link to others
#ln -sf /opt/cmdsql-git /usr/share/webshells/aspx/cmdsql


###### Install JSP file browser
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}JSP file browser${RESET} ~ (JSP) web shell"
#apt -y -qq install curl \
#  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#mkdir -p /opt/jsp-filebrowser/
#aria2c http://www.vonloesch.de/files/browser.zip -d /tmp \
#  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading browser.zip" 1>&2
#unzip -q -o -d /opt/jsp-filebrowser/ /tmp/browser.zip
##--- Link to others
#ln -sf /opt/jsp-filebrowser /usr/share/webshells/jsp/jsp-filebrowser


###### Install htshells
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}htShells${RESET} ~ (htdocs/apache) web shells"
#apt -y -qq install htshells \
#  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


###### Install python-pty-shells
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}python-pty-shells${RESET} ~ PTY shells"
#git clone -q -b master https://github.com/infodox/python-pty-shells.git /opt/python-pty-shells-git/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/python-pty-shells-git/ >/dev/null
#git pull -q
#popd >/dev/null


###### Install FruityWifi
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}FruityWifi${RESET} ~ Wireless network auditing tool"
#apt -y -qq install fruitywifi \
#  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
## URL: https://localhost:8443
#if [[ -e /var/www/html/index.nginx-debian.html ]]; then
#  grep -q '<title>Welcome to nginx on Debian!</title>' /var/www/html/index.nginx-debian.html \
#    && echo 'Permission denied.' > /var/www/html/index.nginx-debian.html
#fi


###### Install WPA2-HalfHandshake-Crack
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}WPA2-HalfHandshake-Crack${RESET} ~ Rogue AP for #handshakes without a AP"
#git clone -q -b master https://github.com/dxa4481/WPA2-HalfHandshake-Crack.git /opt/wpa2-halfhandshake-crack-git/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/wpa2-halfhandshake-crack-git/ >/dev/null
#git pull -q
#popd >/dev/null


###### Install HT-WPS-Breaker
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}HT-WPS-Breaker${RESET} ~ Auto WPS tool"
#git clone -q -b master https://github.com/SilentGhostX/HT-WPS-Breaker.git /opt/ht-wps-breaker-git/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/ht-wps-breaker-git/ >/dev/null
#git pull -q
#popd >/dev/null


###### Install dot11decrypt
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}dot11decrypt${RESET} ~ On-the-fly WEP/WPA2 decrypter"
#git clone -q -b master https://github.com/mfontanini/dot11decrypt.git /opt/dot11decrypt-git/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/dot11decrypt-git/ >/dev/null
#git pull -q
#popd >/dev/null


###### Install mana toolkit
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}MANA toolkit${RESET} ~ Rogue AP for MITM Wi-Fi"
##--- Disable profile
#a2dissite 000-mana-toolkit; a2ensite 000-default
##--- Setup alias
#file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
#([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
#grep -q '^## mana-toolkit' "${file}" 2>/dev/null \
#  || (echo -e '## mana-toolkit\nalias mana-toolkit-start="a2ensite 000-mana-toolkit;a2dissite 000-default; systemctl restart apache2"' >> "${#file}" \
#    && echo -e 'alias mana-toolkit-stop="a2dissite 000-mana-toolkit; a2ensite 000-default; systemctl restart apache2"\n' >> "${file}" )
##--- Apply new alias
#source "${file}" || source ~/.zshrc


###### Install wifiphisher
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}wifiphisher${RESET} ~ Automated Wi-Fi phishing"
#git clone -q -b master https://github.com/sophron/wifiphisher.git /opt/wifiphisher-git/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/wifiphisher-git/ >/dev/null
#git pull -q
#popd >/dev/null
##--- Add to path
#mkdir -p /usr/local/bin/
#file=/usr/local/bin/wifiphisher-git
#cat <<EOF > "${file}" \
#  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
##!/bin/bash
#
#cd /opt/wifiphisher-git/ && python wifiphisher.py "\$@"
#EOF
#chmod +x "${file}"


###### Install hostapd-wpe-extended
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}hostapd-wpe-extended${RESET} ~ Rogue AP for #WPA-Enterprise"
#git clone -q -b master https://github.com/NerdyProjects/hostapd-wpe-extended.git /opt/hostapd-wpe-extended-git/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/hostapd-wpe-extended-git/ >/dev/null
#git pull -q
#popd >/dev/null


##### Install proxychains-ng (https://bugs.kali.org/view.php?id=2037)
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}proxychains-ng${RESET} ~ Proxifier"
git clone -q -b master https://github.com/rofl0r/proxychains-ng.git /opt/proxychains-ng-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/proxychains-ng-git/ >/dev/null
git pull -q
make -s clean
./configure --prefix=/usr --sysconfdir=/etc >/dev/null
make -s 2>/dev/null && make -s install   # bad, but it gives errors which might be confusing (still builds)
popd >/dev/null
#--- Add to path (with a 'better' name)
mkdir -p /usr/local/bin/
ln -sf /usr/bin/proxychains4 /usr/local/bin/proxychains-ng


###### Install pfi
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}pfi${RESET} ~ Port Forwarding Interceptor"
#git clone -q -b master https://github.com/s7ephen/pfi.git /opt/pfi-git/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/pfi-git/ >/dev/null
#git pull -q
#popd >/dev/null


###### Install icmpsh
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}icmpsh${RESET} ~ Reverse ICMP shell"
#git clone -q -b master https://github.com/inquisb/icmpsh.git /opt/icmpsh-git/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/icmpsh-git/ >/dev/null
#git pull -q
#popd >/dev/null


###### Install dnsftp
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}dnsftp${RESET} ~ Transfer files over DNS"
#git clone -q -b master https://github.com/breenmachine/dnsftp.git /opt/dnsftp-git/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/dnsftp-git/ >/dev/null
#git pull -q
#popd >/dev/null


###### Install dns2tcp
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}dns2tcp${RESET} ~ DNS tunnelling (TCP over DNS)"
##--- Daemon
#file=/etc/dns2tcpd.conf; [ -e "${file}" ] && cp -n $file{,.bkup};
#cat <<EOF > "${file}" \
#  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#listen = 0.0.0.0
#port = 53
#user = nobody
#chroot = /tmp
#domain = dnstunnel.mydomain.com
#key = password1
#ressources = ssh:127.0.0.1:22
#EOF
##--- Client
#file=/etc/dns2tcpc.conf; [ -e "${file}" ] && cp -n $file{,.bkup};
#cat <<EOF > "${file}" \
#  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#domain = dnstunnel.mydomain.com
#key = password1
#resources = ssh
#local_port = 8000
#debug_level=1
#EOF
##--- Example
##dns2tcpd -F -d 1 -f /etc/dns2tcpd.conf
##dns2tcpc -f /etc/dns2tcpc.conf 178.62.206.227; ssh -C -D 8081 -p 8000 root@127.0.0.1


##### Install gcc & multilib
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}gcc${RESET} & ${GREEN}multilibc${RESET} ~ compiling libraries"
for FILE in cc gcc g++ gcc-multilib make automake libc6 libc6-dev libc6-dev-amd64 libc6-i386 libc6-dev-i386 libc6-i686 libc6-dev-i686 build-essential dpkg-dev; do
  apt -y -qq install "${FILE}" 2>/dev/null
done


##### Install MinGW ~ cross compiling suite
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}MinGW${RESET} ~ cross compiling suite"
for FILE in mingw-w64 binutils-mingw-w64 gcc-mingw-w64 cmake mingw-w64-x86-64-dev mingw-w64-tools gcc-mingw-w64-i686 gcc-mingw-w64-x86-64 mingw32; do
  apt -y -qq install "${FILE}" 2>/dev/null
done


##### Install WINE
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}WINE${RESET} ~ run Windows programs on *nix"
apt -y -qq install wine wine64 \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Using x64?
if [[ "$(uname -m)" == 'x86_64' ]]; then
  (( STAGE++ )); echo -e " ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}WINE (x64)${RESET}"
  export WINEARCH=win32
  rm -rf ~/.wine
  dpkg --add-architecture i386
  apt update
  apt -y -qq install wine32 \
    || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
fi

#--- Run WINE for the first time
export WINEARCH=win32
rm -rf ~/.wine
[ -e /usr/share/windows-binaries/whoami.exe ] && wine /usr/share/windows-binaries/whoami.exe &>/dev/null
#--- Setup default file association for .exe
file=~/.local/share/applications/mimeapps.list; [ -e "${file}" ] && cp -n $file{,.bkup}
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
echo -e 'application/x-ms-dos-executable=wine.desktop' >> "${file}"


##### Install MinGW (Windows) ~ cross compiling suite
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}MinGW (Windows)${RESET} ~ cross compiling suite"
aria2c https://jaist.dl.sourceforge.net/project/mingw/Installer/mingw-get/mingw-get-0.6.2-beta-20131004-1/mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip -d /tmp
mv /tmp/mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip /tmp/mingw-get.zip \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading mingw-get.zip" 1>&2       #***!!! hardcoded path!
mkdir -p ~/.wine/drive_c/MinGW/bin/
unzip -q -o -d ~/.wine/drive_c/MinGW/ /tmp/mingw-get.zip
pushd ~/.wine/drive_c/MinGW/ >/dev/null
for FILE in mingw32-base mingw32-gcc-g++ mingw32-gcc-objc; do   #msys-base
  wine ./bin/mingw-get.exe install "${FILE}" 2>&1 | grep -v 'If something goes wrong, please rerun with\|for more detailed debugging output'
done
popd >/dev/null
#--- Add to windows path
grep -q '^"PATH"=.*C:\\\\MinGW\\\\bin' ~/.wine/system.reg \
  || sed -i '/^"PATH"=/ s_"$_;C:\\\\MinGW\\\\bin"_' ~/.wine/system.reg


###### Downloading PsExec.exe
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Downloading ${GREEN}PsExec.exe${RESET} ~ Pass The Hash 'phun'"
#echo -n '[1/2]'; aria2c https://download.sysinternals.com/files/PSTools.zip -d /tmp \
#  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading pstools.zip" 1>&2
#unzip -q -o -d /usr/share/windows-binaries/pstools/ /tmp/PSTools.zip
##unrar x -y /opt/scripts/tools/pshtoolkit.rar /usr/share/windows-binaries/ >/dev/null


##### Install Python (Windows via WINE)
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Python (Windows)${RESET}"
echo -n '[1/2]'; aria2c https://www.python.org/ftp/python/2.7.9/python-2.7.9.msi -d /tmp \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading python.msi" 1>&2       #***!!! hardcoded path!
mv /tmp/python-2.7.9.msi /tmp/python.msi
echo -n '[2/2]'; aria2c http://sourceforge.net/projects/pywin32/files/pywin32/Build%20219/pywin32-219.win32-py2.7.exe/download -d /tmp \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading pywin32.exe" 1>&2      #***!!! hardcoded path!
mv  /tmp/pywin32-219.win32-py2.7.exe /tmp/pywin32.exe
wine msiexec /i /tmp/python.msi /qb 2>&1 | grep -v 'If something goes wrong, please rerun with\|for more detailed debugging output'
pushd /tmp/ >/dev/null
rm -rf "PLATLIB/" "SCRIPTS/"
unzip -q -o /tmp/pywin32.exe
cp -rf PLATLIB/* ~/.wine/drive_c/Python27/Lib/site-packages/
cp -rf SCRIPTS/* ~/.wine/drive_c/Python27/Scripts/
rm -rf "PLATLIB/" "SCRIPTS/"
popd >/dev/null


##### Install veil framework
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}veil-evasion framework${RESET} ~ bypassing anti-virus"
apt -y -qq install veil-evasion \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#bash /usr/share/veil/setup/setup.sh --silent
#mkdir -p /var/lib/veil-evasion/go/bin/
#touch /etc/veil/settings.py
#sed -i 's/TERMINAL_CLEAR=".*"/TERMINAL_CLEAR="false"/' /etc/veil/settings.py


###### Install OP packers
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}OP packers${RESET} ~ bypassing anti-virus"
#mkdir -p /opt/packers/
#echo -n '[2/3]'; timeout 600 curl --progress -k -L -f "http://www.farbrausch.de/~fg/kkrunchy/kkrunchy_023a2.zip" > /opt/packers/kkrunchy.zip \
#  && unzip -q -o -d /opt/packers/ /opt/packers/kkrunchy.zip \
#  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading kkrunchy.zip" 1>&2        #***!!! hardcoded version! Need to manually check for updates
#echo -n '[3/3]'; timeout 600 wget --show-progress --no-check-certificate -O /opt/packers/PEScrambler.zip "https://media.defcon.org/#DEF%20CON%2016/DEF%20CON%2016%20tools/PEScrambler_v0_1.zip" \
#  && unzip -q -o -d /opt/packers/ /opt/packers/PEScrambler.zip \
#  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading PEScrambler.zip" 1>&2     #***!!! hardcoded version! Need to manually check for updates
##--- Link to others
#ln -sf /opt/packers/ /usr/share/windows-binaries/packers


##### Install shellter
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}shellter${RESET} ~ dynamic shellcode injector"
apt -y -qq install shellter \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


###### Install BetterCap
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}BetterCap${RESET} ~ MITM framework"
#apt -y -qq install libpcap-dev \
#  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#git clone -q -b master https://github.com/bettercap/bettercap.git /opt/bettercap-git/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/bettercap-git/ >/dev/null
#git pull -q
#gem build bettercap.gemspec
#gem install bettercap*.gem
#popd >/dev/null


##### Install SecLists
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}SecLists${RESET} ~ pentester's companion"
apt -y -qq install seclists \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/danielmiessler/SecLists.git /opt/seclists-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Update wordlists
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Updating ${GREEN}wordlists${RESET} ~ collection of wordlists"
apt -y -qq install wordlists curl \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Extract rockyou wordlist
[ -e /usr/share/wordlists/rockyou.txt.gz ] \
  && gzip -dc < /usr/share/wordlists/rockyou.txt.gz > /usr/share/wordlists/rockyou.txt
#--- Add 10,000 Top/Worst/Common Passwords
mkdir -p /usr/share/wordlists/
cp /opt/SecLists-git/Passwords/10k_most_common.txt /usr/share/wordlists/
#mv -f /usr/share/wordlists/10k{\ most\ ,_most_}common.txt
#--- Linking to more - folders
[ -e /usr/share/dirb/wordlists ] \
  && ln -sf /usr/share/dirb/wordlists /usr/share/wordlists/dirb
#--- Extract sqlmap wordlist
unzip -o -d /usr/share/sqlmap/txt/ /usr/share/sqlmap/txt/wordlist.zip
ln -sf /usr/share/sqlmap/txt/wordlist.txt /usr/share/wordlists/sqlmap.txt
#--- Not enough? Want more? Check below!
#apt search wordlist
#find / \( -iname '*wordlist*' -or -iname '*passwords*' \) #-exec ls -l {} \;


###### Install Babel scripts
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Babel scripts${RESET} ~ post exploitation scripts"
#git clone -q -b master https://github.com/attackdebris/babel-sf.git /opt/babel-sf-git/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/babel-sf-git/ >/dev/null
#git pull -q
#popd >/dev/null


##### Install checksec
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}checksec${RESET} ~ check *nix OS for security features"
mkdir -p /usr/share/checksec/
file=/usr/share/checksec/checksec.sh
timeout 600 curl --progress -k -L -f "http://www.trapkit.de/tools/checksec.sh" > "${file}" \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading checksec.sh" 1>&2     #***!!! hardcoded patch
chmod +x "${file}"


###### Install shellconv
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}shellconv${RESET} ~ shellcode disassembler"
#git clone -q -b master https://github.com/hasherezade/shellconv.git /opt/shellconv-git/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/shellconv-git/ >/dev/null
#git pull -q
#popd >/dev/null
##--- Add to path
#mkdir -p /usr/local/bin/
#file=/usr/local/bin/shellconv-git
#cat <<EOF > "${file}" \
#  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
##!/bin/bash
#
#cd /opt/shellconv-git/ && python shellconv.py "\$@"
#EOF
#chmod +x "${file}"


##### Install bless
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}bless${RESET} ~ GUI hex editor"
apt -y -qq install bless \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


###### Install dhex
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}dhex${RESET} ~ CLI hex compare"
#apt -y -qq install dhex \
#  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


###### Install lnav
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}lnav${RESET} ~ CLI log veiwer"
#apt -y -qq install lnav \
#  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


###### Install smbspider
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}smbspider${RESET} ~ search network shares"
#git clone -q -b master https://github.com/T-S-A/smbspider.git /opt/smbspider-git/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/smbspider-git/ >/dev/null
#git pull -q
#popd >/dev/null


##### Install CrackMapExec
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}CrackMapExec${RESET} ~ Swiss army knife for Windows environments"
#apt -y -qq install crackmapexec \
#  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/byt3bl33d3r/CrackMapExec.git /opt/crackmapexec-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/crackmapexec-git/ >/dev/null
git pull -q
popd >/dev/null


###### Install credcrack
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}credcrack${RESET} ~ credential harvester via Samba"
#git clone -q -b master https://github.com/gojhonny/CredCrack.git /opt/credcrack-git/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/credcrack-git/ >/dev/null
#git pull -q
#popd >/dev/null


##### Install Empire
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Empire${RESET} ~ PowerShell post-exploitation"
git clone -q -b master https://github.com/PowerShellEmpire/Empire.git /opt/empire-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/empire-git/ >/dev/null
git pull -q
popd >/dev/null


###### Install wig (https://bugs.kali.org/view.php?id=1932)
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}wig${RESET} ~ web application detection"
#git clone -q -b master https://github.com/jekyc/wig.git /opt/wig-git/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/wig-git/ >/dev/null
#git pull -q
#popd >/dev/null
##--- Add to path
#mkdir -p /usr/local/bin/
#file=/usr/local/bin/wig-git
#cat <<EOF > "${file}" \
#  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
##!/bin/bash
#
#cd /opt/wig-git/ && python wig.py "\$@"
#EOF
#chmod +x "${file}"


##### Install CMSmap
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}CMSmap${RESET} ~ CMS detection"
git clone -q -b master https://github.com/Dionach/CMSmap.git /opt/cmsmap-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/cmsmap-git/ >/dev/null
git pull -q
popd >/dev/null
#--- Add to path
mkdir -p /usr/local/bin/
file=/usr/local/bin/cmsmap-git
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd /opt/cmsmap-git/ && python cmsmap.py "\$@"
EOF
chmod +x "${file}"


##### Install droopescan
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}DroopeScan${RESET} ~ Drupal vulnerability scanner"
git clone -q -b master https://github.com/droope/droopescan.git /opt/droopescan-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/droopescan-git/ >/dev/null
git pull -q
popd >/dev/null
#--- Add to path
mkdir -p /usr/local/bin/
file=/usr/local/bin/droopescan-git
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd /opt/droopescan-git/ && python droopescan "\$@"
EOF
chmod +x "${file}"


##### Install BeEF XSS
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}BeEF XSS${RESET} ~ XSS framework"
#--- Configure beef
file=/usr/share/beef-xss/config.yaml; [ -e "${file}" ] && cp -n $file{,.bkup}
username="root"
password="toor"
sed -i 's/user:.*".*"/user:   "'${username}'"/' "${file}"
sed -i 's/passwd:.*".*"/passwd:  "'${password}'"/'  "${file}"
echo -e " ${YELLOW}[i]${RESET} BeEF username: ${username}"
echo -e " ${YELLOW}[i]${RESET} BeEF password: ${password}   ***${BOLD}CHANGE THIS ASAP${RESET}***"
echo -e " ${YELLOW}[i]${RESET} Edit: /usr/share/beef-xss/config.yaml"
#--- Example
#<script src="http://192.168.155.175:3000/hook.js" type="text/javascript"></script>


##### Install patator (GIT)
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}patator${RESET} (GIT) ~ brute force"
git clone -q -b master https://github.com/lanjelot/patator.git /opt/patator-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/patator-git/ >/dev/null
git pull -q
popd >/dev/null
#--- Add to path
mkdir -p /usr/local/bin/
file=/usr/local/bin/patator-git
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd /opt/patator-git/ && python patator.py "\$@"
EOF
chmod +x "${file}"


###### Install crowbar
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}crowbar${RESET} ~ brute force"
#apt -y -qq install tigervnc-viewer \
#  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#git clone -q -b master https://github.com/galkan/crowbar.git /opt/crowbar-git/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/crowbar-git/ >/dev/null
#git pull -q
#popd >/dev/null
##--- Add to path
#mkdir -p /usr/local/bin/
#file=/usr/local/bin/crowbar-git
#cat <<EOF > "${file}" \
#  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
##!/bin/bash
#
#cd /opt/crowbar-git/ && python crowbar.py "\$@"
#EOF
#chmod +x "${file}"


###### Setup tftp client & server
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}tftp client${RESET} & ${GREEN}server${RESET} ~ file #transfer methods"
##--- Configure atftpd
#file=/etc/default/atftpd; [ -e "${file}" ] && cp -n $file{,.bkup}
#echo -e 'USE_INETD=false\nOPTIONS="--tftpd-timeout 600 --retry-timeout 5 --maxthread 100 --verbose=5 --daemon --port 69 /var/tftp"' > "${file}#"
#mkdir -p /var/tftp/
#chown -R nobody\:root /var/tftp/
#chmod -R 0755 /var/tftp/
##--- Setup alias
#file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
#([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
#grep -q '^## tftp' "${file}" 2>/dev/null \
#  || echo -e '## tftp\nalias tftproot="cd /var/tftp/"\n' >> "${file}"
##--- Apply new alias
#source "${file}" || source ~/.zshrc
##--- Remove from start up
#systemctl disable atftpd
##--- Disabling IPv6 can help
##echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
##echo 1 > /proc/sys/net/ipv6/conf/default/disable_ipv6


###### Install Pure-FTPd
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Pure-FTPd${RESET} ~ FTP server/file transfer method"
#apt -y -qq install pure-ftpd \
#  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
##--- Setup pure-ftpd
#mkdir -p /var/ftp/
#groupdel ftpgroup 2>/dev/null;
#groupadd ftpgroup
#userdel ftp 2>/dev/null;
#useradd -r -M -d /var/ftp/ -s /bin/false -c "FTP user" -g ftpgroup ftp
#chown -R ftp\:ftpgroup /var/ftp/
#chmod -R 0755 /var/ftp/
#pure-pw userdel ftp 2>/dev/null;
#echo -e '\n' | pure-pw useradd ftp -u ftp -d /var/ftp/
#pure-pw mkdb
##--- Configure pure-ftpd
#echo "no" > /etc/pure-ftpd/conf/UnixAuthentication
#echo "no" > /etc/pure-ftpd/conf/PAMAuthentication
#echo "yes" > /etc/pure-ftpd/conf/NoChmod
#echo "yes" > /etc/pure-ftpd/conf/ChrootEveryone
#echo "yes" > /etc/pure-ftpd/conf/AnonymousOnly
#echo "no" > /etc/pure-ftpd/conf/NoAnonymous
#echo "yes" > /etc/pure-ftpd/conf/AnonymousCanCreateDirs
#echo "yes" > /etc/pure-ftpd/conf/AllowAnonymousFXP
#echo "no" > /etc/pure-ftpd/conf/AnonymousCantUpload
#echo "30768 31768" > /etc/pure-ftpd/conf/PassivePortRange              #cat /proc/sys/net/ipv4/ip_local_port_range
#echo "/etc/pure-ftpd/welcome.msg" > /etc/pure-ftpd/conf/FortunesFile   #/etc/motd
#echo "FTP" > /etc/pure-ftpd/welcome.msg
#ln -sf /etc/pure-ftpd/conf/PureDB /etc/pure-ftpd/auth/50pure
##--- 'Better' MOTD
#apt -y -qq install cowsay \
#  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#echo "moo" | /usr/games/cowsay > /etc/pure-ftpd/welcome.msg
#echo -e " ${YELLOW}[i]${RESET} Pure-FTPd username: anonymous"
#echo -e " ${YELLOW}[i]${RESET} Pure-FTPd password: anonymous"
##--- Apply settings
#systemctl restart pure-ftpd
##--- Setup alias
#file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
#([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
#grep -q '^## ftp' "${file}" 2>/dev/null \
#  || echo -e '## ftp\nalias ftproot="cd /var/ftp/"\n' >> "${file}"
##--- Apply new alias
#source "${file}" || source ~/.zshrc
##--- Remove from start up
#systemctl disable pure-ftpd


###### Install samba
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}samba${RESET} ~ file transfer method"
##--- Installing samba
#apt -y -qq install cifs-utils \
#  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
##--- Create samba user
#groupdel smbgroup 2>/dev/null;
#groupadd smbgroup
#userdel samba 2>/dev/null;
#useradd -r -M -d /nonexistent -s /bin/false -c "Samba user" -g smbgroup samba
##--- Use the samba user
#file=/etc/samba/smb.conf; [ -e "${file}" ] && cp -n $file{,.bkup}
#sed -i 's/guest account = .*/guest account = samba/' "${file}" 2>/dev/null
#grep -q 'guest account' "${file}" 2>/dev/null \
#  || sed -i 's#\[global\]#\[global\]\n   guest account = samba#' "${file}"
##--- Setup samba paths
#grep -q '^\[shared\]' "${file}" 2>/dev/null \
#  || cat <<EOF >> "${file}"
#
#[shared]
#  comment = Shared
#  path = /var/samba/
#  browseable = yes
#  guest ok = yes
#  #guest only = yes
#  read only = no
#  writable = yes
#  create mask = 0644
#  directory mask = 0755
#EOF
##--- Create samba path and configure it
#mkdir -p /var/samba/
#chown -R samba\:smbgroup /var/samba/
#chmod -R 0755 /var/samba/
##--- Bug fix
#touch /etc/printcap
##--- Check
##systemctl restart samba
##smbclient -L \\127.0.0.1 -N
##mount -t cifs -o guest //127.0.0.1/share /mnt/smb     mkdir -p /mnt/smb
##--- Disable samba at startup
#systemctl stop samba
#systemctl disable samba
#echo -e " ${YELLOW}[i]${RESET} Samba username: guest"
#echo -e " ${YELLOW}[i]${RESET} Samba password: <blank>"
##--- Setup alias
#file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
#([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
#grep -q '^## smb' "${file}" 2>/dev/null \
#  || echo -e '## smb\nalias smb="cd /var/samba/"\n#alias smbroot="cd /var/samba/"\n' >> "${file}"
##--- Apply new alias
#source "${file}" || source ~/.zshrc


##### Install apache2 & php
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}apache2${RESET} & ${GREEN}php${RESET} ~ web server"
touch /var/www/html/favicon.ico
grep -q '<title>Apache2 Debian Default Page: It works</title>' /var/www/html/index.html 2>/dev/null \
  && rm -f /var/www/html/index.html \
  && echo '<?php echo "Access denied for " . $_SERVER["REMOTE_ADDR"]; ?>' > /var/www/html/index.php \
  && echo -e 'User-agent: *n\Disallow: /\n' > /var/www/html/robots.txt
#--- Setup alias
file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
grep -q '^## www' "${file}" 2>/dev/null \
  || echo -e '## www\nalias wwwroot="cd /var/www/html/"\n' >> "${file}"
#--- Apply new alias
source "${file}" || source ~/.zshrc


##### Install mariadb
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}MySQL${RESET} ~ database"
apt -y -qq install mariadb-server \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
echo -e " ${YELLOW}[i]${RESET} MySQL username: root"
echo -e " ${YELLOW}[i]${RESET} MySQL password: <blank>   ***${BOLD}CHANGE THIS ASAP${RESET}***"
[[ -e ~/.my.cnf ]] \
  || cat <<EOF > ~/.my.cnf
[client]
user=root
host=localhost
password=
EOF


###### Install rsh-client
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}rsh-client${RESET} ~ remote shell connections"
#apt -y -qq install rsh-client \
#  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install exiftool
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}exiftool${RESET} ~ image file metadata editor"
apt -y -qq install exiftool \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install jhead
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}jhead${RESET} ~ jpeg metadata editor"
apt -y -qq install jhead \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install sshpass
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}sshpass${RESET} ~ automating SSH connections"
apt -y -qq install sshpass \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install DBeaver
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}DBeaver${RESET} ~ GUI DB manager"
apt -y -qq install dbeaver \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install gdebi
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}gdebi${RESET} ~ package installer"
apt -y -qq install gdebi \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install BloodHound
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}BloodHound${RESET} ~ Six Degrees of Domain Admin"
apt -y -qq install bloodhound \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install PuTTY Tools
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}PuTTY Tools${RESET} ~ PuTTY CLI Tools"
apt -y -qq install putty-tools \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install impacket
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}impacket${RESET} ~ network protocols via python"
git clone -q -b master https://github.com/CoreSecurity/impacket.git /opt/impacket-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/impacket-git/ >/dev/null
git pull -q
popd >/dev/null


##### Install gotty
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}gotty${RESET} ~ terminal via the web"
git clone -q -b master https://github.com/yudai/gotty.git /opt/gotty-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/gotty-git/ >/dev/null
git pull -q
popd >/dev/null


##### Install nfs-common
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}nfs-common${RESET} ~ nfs common tools"
apt -y -qq install \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
apt -y -qq install nfs-common \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install LinuxSmartEnumeration
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}CrackMapExec${RESET} ~ Swiss army knife for Windows environments"
git clone -q -b master https://github.com/diego-treitos/linux-smart-enumeration.git /opt/linux-smart-enumeration-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/linux-smart-enumeration-git/ >/dev/null
git pull -q
popd >/dev/null


##### Install Sitadel
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Sitadel${RESET} ~ Web Application Security Scanner"
git clone -q -b master https://github.com/shenril/Sitadel.git /opt/sitadel-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/sitadel-git/ >/dev/null
git pull -q
popd >/dev/null



##### Setup SSH
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Setting up ${GREEN}SSH${RESET} ~ CLI access"
apt -y -qq install openssh-server \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Wipe current keys
rm -f /etc/ssh/ssh_host_*
find ~/.ssh/ -type f ! -name authorized_keys -delete 2>/dev/null
#--- Generate new keys
#ssh-keygen -b 4096 -t rsa1 -f /etc/ssh/ssh_host_key -P "" >/dev/null
ssh-keygen -b 4096 -t rsa -f /etc/ssh/ssh_host_rsa_key -P "" >/dev/null
ssh-keygen -b 1024 -t dsa -f /etc/ssh/ssh_host_dsa_key -P "" >/dev/null
ssh-keygen -b 521 -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -P "" >/dev/null
ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -P "" >/dev/null
#--- Change MOTD
apt -y -qq install cowsay \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
echo "Moo" | /usr/games/cowsay > /etc/motd
#--- Change SSH settings
file=/etc/ssh/sshd_config; [ -e "${file}" ] && cp -n $file{,.bkup}
sed -i 's/^PermitRootLogin .*/PermitRootLogin yes/g' "${file}"      # Accept password login (overwrite Debian 8+'s more secure default option...)
sed -i 's/^#AuthorizedKeysFile /AuthorizedKeysFile /g' "${file}"    # Allow for key based login
#sed -i 's/^Port .*/Port 2222/g' "${file}"
#--- Enable ssh at startup
#systemctl enable ssh
#--- Setup alias (handy for 'zsh: correct 'ssh' to '.ssh' [nyae]? n')
file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
grep -q '^## ssh' "${file}" 2>/dev/null \
  || echo -e '## ssh\nalias ssh-start="systemctl restart ssh"\nalias ssh-stop="systemctl stop ssh"\n' >> "${file}"
#--- Apply new alias
source "${file}" || source ~/.zshrc


##### Configure file   Note: need to restart xserver for effect
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}file${RESET} (Nautilus/Thunar) ~ GUI file system navigation"
#--- Settings
mkdir -p ~/.config/gtk-2.0/
file=~/.config/gtk-2.0/gtkfilechooser.ini; [ -e "${file}" ] && cp -n $file{,.bkup}
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
sed -i 's/^.*ShowHidden.*/ShowHidden=true/' "${file}" 2>/dev/null \
  || cat <<EOF > "${file}"
[Filechooser Settings]
LocationMode=path-bar
ShowHidden=true
ExpandFolders=false
ShowSizeColumn=true
GeometryX=66
GeometryY=39
GeometryWidth=780
GeometryHeight=618
SortColumn=name
SortOrder=ascending
EOF
dconf write /org/gnome/nautilus/preferences/show-hidden-files true
#--- Bookmarks
file=/root/.gtk-bookmarks; [ -e "${file}" ] && cp -n $file{,.bkup}
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
grep -q '^file:///root/Downloads ' "${file}" 2>/dev/null \
  || echo 'file:///root/Downloads Downloads' >> "${file}"
(dmidecode | grep -iq vmware) \
  && (mkdir -p /mnt/hgfs/ 2>/dev/null; grep -q '^file:///mnt/hgfs ' "${file}" 2>/dev/null \
    || echo 'file:///mnt/hgfs VMShare' >> "${file}")
grep -q '^file:///tmp ' "${file}" 2>/dev/null \
  || echo 'file:///tmp /TMP' >> "${file}"
grep -q '^file:///usr/share ' "${file}" 2>/dev/null \
  || echo 'file:///usr/share Kali Tools' >> "${file}"
grep -q '^file:///opt ' "${file}" 2>/dev/null \
  || echo 'file:///opt /opt' >> "${file}"
grep -q '^file:///usr/local/src ' "${file}" 2>/dev/null \
  || echo 'file:///usr/local/src SRC' >> "${file}"
grep -q '^file:///var/ftp ' "${file}" 2>/dev/null \
  || echo 'file:///var/ftp FTP' >> "${file}"
grep -q '^file:///var/samba ' "${file}" 2>/dev/null \
  || echo 'file:///var/samba Samba' >> "${file}"
grep -q '^file:///var/tftp ' "${file}" 2>/dev/null \
  || echo 'file:///var/tftp TFTP' >> "${file}"
grep -q '^file:///var/www/html ' "${file}" 2>/dev/null \
  || echo 'file:///var/www/html WWW' >> "${file}"
##--- Configure file browser - Thunar (need to re-login for effect)
#mkdir -p ~/.config/Thunar/
#file=~/.config/Thunar/thunarrc; [ -e "${file}" ] && cp -n $file{,.bkup}
#([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
#sed -i 's/LastShowHidden=.*/LastShowHidden=TRUE/' "${file}" 2>/dev/null \
#  || echo -e "[Configuration]\nLastShowHidden=TRUE" > "${file}"


##### Install LightDM
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}lightdm${RESET} ~ leaner display manager"
apt -y -qq install lightdm \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install PhantomJS
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}phantomjs${RESET} ~ Full web stack, no browser"
apt -y -qq install phantomjs \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install LinEnum
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}LinEnum${RESET} ~ Linux PrivEsc Checker"
git clone -q https://github.com/rebootuser/LinEnum.git /opt/linenum-git \
  || echo -e ' '${RED}'[!] Issue with git clone'${RESET} 1>&2

##### Install RootHelper
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}RootHelper${RESET} ~ Linux PrivEsc Checker"
git clone -q https://github.com/NullArray/RootHelper.git /opt/roothelper-git/ \
  || echo -e ' '${RED}'[!] Issue with git clone'${RESET} 1>&2

##### Install Sn1per
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Sn1per${RESET} ~ Automated Pentest Framework"
git clone -q https://github.com/1N3/Sn1per.git /opt/sn1per-git/ \
  || echo -e ' '${RED}'[!] Issue with git clone'${RESET} 1>&2


###### Install unix-privesc-check
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}unix-privesc-check${RESET} ~ Unix PrivEsc Checker"
#git clone -q https://github.com/pentestmonkey/unix-privesc-check.git /opt/unix-privesc-check-git \
#  || echo -e ' '${RED}'[!] Issue with git clone'${RESET} 1>&2


##### Install apt2
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}apt2${RESET} ~ Automated Penetration Testing Tool"
git clone -q https://github.com/MooseDojo/apt2.git /opt/apt2-git \
  || echo -e ' '${RED}'[!] Issue with git clone'${RESET} 1>&2


##### Install dirsearch
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}dirsearch${RESET} ~ Directory Bruteforcer"
cd /opt
git clone -q https://github.com/maurosoria/dirsearch.git dirsearch-git \
  || echo -e ' '${RED}'[!] Issue with git clone'${RESET} 1>&2


##### Install nload
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}nload${RESET} ~ Network Traffic Monitor"
apt -y -qq install nload \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install byobu
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}byobu${RESET} ~ text-based window manager and terminal multiplexer"
apt -y -qq install byobu \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install PCManFM
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}pcmanfm${RESET} ~ PCMAN File Manager"
apt -y -qq install pcmanfm \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Configure pcmanfm
mkdir -p ~/.config/pcmanfm/default/
file=~/.config/pcmanfm/default/pcmanfm.conf; [ -e "${file}" ] && cp -n $file{,.bkup}
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
[config]
bm_open_method=0

[volume]
mount_on_startup=1
mount_removable=1
autorun=1

[ui]
always_show_tabs=1
max_tab_chars=32
win_width=871
win_height=632
splitter_pos=184
media_in_new_tab=0
desktop_folder_new_win=0
change_tab_on_drop=1
close_on_unmount=1
focus_previous=0
side_pane_mode=places
view_mode=compact
show_hidden=0
sort=name;ascending;
toolbar=newtab;navigation;home;
show_statusbar=1
pathbar_mode_buttons=0

EOF


###### Install BurpSuitePro
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}BurpSuitePro${RESET} ~ Web App Proxy"
#cp /opt/scripts/tools/burpsuite_pro_linux_current.7z /tmp
#cd /tmp
#7z x burpsuite_pro_linux_current.7z -p$BURPPASS
#bash burpsuite_pro_linux_current.sh -q


##### Install winetricks
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}WINE${RESET} ~ run Windows programs on *nix"
apt -y -qq install winetricks \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install Vanquish
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Vanquish${RESET} ~ automated enumeration orchestrator"
apt -y -qq install nbtscan-unixwiz \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q https://github.com/frizb/Vanquish.git /opt/vanquish/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#--- Vanquish install
cd /opt/vanquish/
python Vanquish2.py -install


##### Install LinEnum
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}LinEnum.sh${RESET} ~ Linux PrivEsc Checker"
mkdir -p /opt/PrivEsc/LinEnum
wget https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh -O /opt/PrivEsc/LinEnum/LinEnum.sh \
  || echo -e ' '${RED}'[!] Issue with intall'${RESET} 1>&2


##### Install Powerless
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Powerless${RESET} ~ Windows PrivEsc Checker"
mkdir -p /opt/PrivEsc/Powerless
wget https://raw.githubusercontent.com/M4ximuss/Powerless/master/Powerless.bat -O /opt/PrivEsc/Powerless/Powerless.bat \
  || echo -e ' '${RED}'[!] Issue with intall'${RESET} 1>&2


##### Install PowerSploit
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}PowerSploit${RESET} ~ Windows Post-Exploitation Framework"
mkdir -p /opt/PostExploit/
git clone https://github.com/PowerShellMafia/PowerSploit.git /opt/PostExploit/PowerSploit \
  || echo -e ' '${RED}'[!] Issue with intall'${RESET} 1>&2
  cd /opt/PostExploit/PowerSploit
  git checkout -b dev


##### Install Linux Exploit Suggester
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Linux Exploit Suggester${RESET} ~ Linux Exploit Suggester"
mkdir -p /opt/PrivEsc/linux-exploit-suggester
wget https://raw.githubusercontent.com/mzet-/linux-exploit-suggester/master/linux-exploit-suggester.sh -O /opt/PrivEsc/linux-exploit-suggester/linux-exploit-suggester.sh \
  || echo -e ' '${RED}'[!] Issue with intall'${RESET} 1>&2


##### Install Windows Exploit Suggester - Next Generation
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}WES-NG${RESET} ~ Windows PrivEsc Checker"
mkdir -p /opt/PrivEsc/
git clone https://github.com/bitsadmin/wesng.git /opt/PrivEsc/WES-NG  \
  || echo -e ' '${RED}'[!] Issue with intall'${RESET} 1>&2



##### Install RevShellGen
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}RevShellGen${RESET} ~ Reverse Shell Generator"
mkdir -p /opt/Exploitation/
git clone https://github.com/m0rph-1/revshellgen.git /opt/Exploitation/revshellgen \
  || echo -e ' '${RED}'[!] Issue with intall'${RESET} 1>&2


##### Install SILENTTRINITY
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}RevShellGen${RESET} ~ Reverse Shell Generator"
mkdir -p /opt/Exploitation/
git clone https://github.com/byt3bl33d3r/SILENTTRINITY.git /opt/Exploitation/SILENTTRINITY \
  || echo -e ' '${RED}'[!] Issue with intall'${RESET} 1>&2





##### Configure Java default jre
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}Java 8${RESET} ~ default JavaVM"
update-java-alternatives --jre --set java-1.8.0-openjdk-amd64 \
  || echo -e ' '${RED}'[!] Issue with configuration'${RESET} 1>&2


##### Clean the system
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) ${GREEN}Cleaning${RESET} the system"
#--- Clean package manager
for FILE in clean autoremove; do apt -y -qq "${FILE}"; done
apt -y -qq purge $(dpkg -l | tail -n +6 | egrep -v '^(h|i)i' | awk '{print $2}')   # Purged packages
apt -y -qq upgrade && apt -y -qq dist-upgrade
#--- Update slocate database
updatedb
#--- Reset folder location
cd ~/ &>/dev/null
#--- Remove any history files (as they could contain sensitive info)
history -c 2>/dev/null
for i in $(cut -d: -f6 /etc/passwd | sort -u); do
  [ -e "${i}" ] && find "${i}" -type f -name '.*_history' -delete
done


##### Time taken
finish_time=$(date +%s)
echo -e "\n\n ${YELLOW}[i]${RESET} Time (roughly) taken: ${YELLOW}$(( $(( finish_time - start_time )) / 60 )) minutes${RESET}"


#-Done-----------------------------------------------------------------#


##### Done!
echo -e "\n ${YELLOW}[i]${RESET} Don't forget to:"
echo -e " ${YELLOW}[i]${RESET} + Check the above output (Did everything install? Any errors? (${RED}HINT: What's in RED${RESET}?)"
echo -e " ${YELLOW}[i]${RESET} + Manually install: Nessus, Nexpose, and/or Metasploit Community"
echo -e " ${YELLOW}[i]${RESET} + Agree/Accept to: Maltego, OWASP ZAP, w3af, etc"
echo -e " ${YELLOW}[i]${RESET} + Setup git:   ${YELLOW}git config --global user.name <name>;git config --global user.email <email>${RESET}"
echo -e " ${YELLOW}[i]${RESET} + ${BOLD}Change default passwords${RESET}: Samba, Pure-FTPd, PostgreSQL/MSF, MySQL, OpenVAS, BeEF XSS, etc"
echo -e " ${YELLOW}[i]${RESET} + ${YELLOW}Reboot${RESET}"
(dmidecode | grep -iq virtual) \
  && echo -e " ${YELLOW}[i]${RESET} + Take a snapshot   (Virtual machine detected)"


echo -e '\n'${BLUE}'[*]'${RESET}' '${BOLD}'Done!'${RESET}'\n\a'
exit 0