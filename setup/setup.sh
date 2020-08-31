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


##### Location information
timezone="US/Pacific"       # Set timezone location                                     [ --timezone Europe/London ]

##### Optional steps
burpFree=true              # Disable configuring Burp Suite (for Burp Pro users...)    [ --burp ]
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
  ln -sf "${file}" ~/Desktop/mount-shared-folders.sh
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
  ln -sf "${file}" ~/Desktop/restart-vm-tools.sh
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


###### Install "kali full" meta packages (default tool selection)
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}kali-linux-full${RESET} meta-package"
#echo -e " ${YELLOW}[i]${RESET}  ...this ${BOLD}may take a while${RESET} depending on your Kali version (e.g. ARM, light, mini or docker...)"
##--- Kali's default tools ~ https://www.kali.org/news/kali-linux-metapackages/
#apt -y -qq install kali-linux-full \
#  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


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


##### Install zsh
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}zsh${RESET} ~ zsh shell"
apt -y -qq install zsh \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#Installing zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
#Configuring zsh - cheating
cp ./res/zshrc ~/.zshrc


##### Install oh-my-zsh
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}oh-my-zsh${RESET} ~ zsh customization"
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
chsh -s "$(which zsh)"


##### Install PowerLevel10k
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}PowerLevel10k${RESET} ~ zsh customization"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k \
  || echo -e ' '${RED}'[!] Issue with git clone'${RESET} 1>&2
#Installing PowerLevel10k fonts
cd /usr/local/share/fonts || return
wget "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS NF Regular.ttf"
wget "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS NF Bold.ttf"
wget "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS NF Italic.ttf"
wget "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS NF Bold Italic.ttf"
fc-cache -rv
#Configuring Konsole to use new fonts
file=~/.local/share/konsole/Kali-Dark.profile
cat <<EOF > "${file}"
 Font=MesloLGS NF,12,-1,5,50,0,0,0,0,0
EOF
#Configuring PowerLevel10k - cheating
cp ./res/p10k.zsh ~/.p10k.zsh


#



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
apt -y -qq install --reinstall metasploit-framework \
    || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
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


##### Install flameshot
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}flameshot${RESET} ~ Powerful yet simple to use screenshot software"
apt -y -qq install flameshot \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install htop
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}htop${RESET} ~ CLI process viewer"
apt -y -qq install htop \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install iotop
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}iotop${RESET} ~ CLI I/O usage"
apt -y -qq install iotop \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install filezilla
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}FileZilla${RESET} ~ GUI file transfer"
apt -y -qq install filezilla \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install wafw00f
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}wafw00f${RESET} ~ WAF detector"
git clone https://github.com/EnableSecurity/wafw00f.git /opt/wafw00f-git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install aria2c
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


##### Install Babadook
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Babadook${RESET} ~ connection-less powershell Backdoor#"
git clone -q -b master https://github.com/jseidl/Babadook.git /opt/babadook-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/babadook-git/ >/dev/null
git pull -q
popd >/dev/null


##### Install gobuster
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}gobuster${RESET} ~ Directory/File/DNS busting tool"
apt -y -qq install gobuster \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


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


##### Install Veil framework
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}veil-evasion framework${RESET} ~ bypassing anti-virus"
apt -y -qq install veil-evasion \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install shellter
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}shellter${RESET} ~ dynamic shellcode injector"
apt -y -qq install shellter \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


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


##### Install bless
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}bless${RESET} ~ GUI hex editor"
apt -y -qq install bless \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install CrackMapExec 3.x
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}CrackMapExec 3.x${RESET} ~ Swiss army knife for Windows environments"
apt -y -qq install crackmapexec \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install CrackMapExec 4.x
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}CrackMapExec 4.x${RESET} ~ Swiss army knife for Windows environments"
apt -y -qq install libssl-dev libffi-dev python-dev build-essential
pip install pipenv
git clone --recursive https://github.com/byt3bl33d3r/CrackMapExec.git /opt/crackmapexec-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
cd /opt/crackmapexec-git && pipenv install
pipenv run python setup.py install


##### Install Empire
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Empire${RESET} ~ PowerShell post-exploitation"
apt -y -qq install sudo apt install powershell-empire \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install Starkiller
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Starkiller${RESET} ~ Empire Frontend"
mkdir /opt/starkiller
wget https://github.com/BC-SECURITY/Starkiller/releases/download/v1.3.2/starkiller-1.3.2.AppImage -O /opt/starkiller/starkiller.AppImage \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install CMSmap
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}CMSmap${RESET} ~ CMS detection"
git clone -q -b master https://github.com/Dionach/CMSmap.git /opt/cmsmap-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
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
#--- Add to path
mkdir -p /usr/local/bin/
file=/usr/local/bin/droopescan-git
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd /opt/droopescan-git/ && python droopescan "\$@"
EOF
chmod +x "${file}"


##### Configure BeEF XSS
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
#--- Add to path
mkdir -p /usr/local/bin/
file=/usr/local/bin/patator-git
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd /opt/patator-git/ && python patator.py "\$@"
EOF
chmod +x "${file}"


##### Install JuicyPotato (GIT)
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}JuicyPotato${RESET} Abuse Golden Privileges"
git clone -q https://github.com/ohpe/juicy-potato.git /opt/juicy-potato-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


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


##### Install gotty
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}gotty${RESET} ~ terminal via the web"
git clone -q -b master https://github.com/yudai/gotty.git /opt/gotty-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2

##### Install nfs-common
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}nfs-common${RESET} ~ nfs common tools"
apt -y -qq install \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
apt -y -qq install nfs-common \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install LinuxSmartEnumeration
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}LinuxSmartEnumeration${RESET} ~ Linux Enumeration Tool"
git clone -q -b master https://github.com/diego-treitos/linux-smart-enumeration.git /opt/linux-smart-enumeration-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Install Sitadel
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Sitadel${RESET} ~ Web Application Security Scanner"
git clone -q -b master https://github.com/shenril/Sitadel.git /opt/sitadel-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


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


##### Install Powerless
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Powerless${RESET} ~ Windows PrivEsc Checker"Powerless
mkdir -p /opt/powerless
wget https://raw.githubusercontent.com/M4ximuss/Powerless/master/Powerless.bat -O /opt/powerless/powerless.bat \
  || echo -e ' '${RED}'[!] Issue with intall'${RESET} 1>&2


##### Install PowerSploit
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}PowerSploit${RESET} ~ Windows Post-Exploitation Framework"
git clone https://github.com/PowerShellMafia/PowerSploit.git /opt/powersploit-git \
  || echo -e ' '${RED}'[!] Issue with intall'${RESET} 1>&2
  cd /opt/powersploit-git
  git checkout -b dev


##### Install Linux Exploit Suggester
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Linux Exploit Suggester${RESET} ~ Linux Exploit Suggester"
mkdir -p /opt/linux-exploit-suggester
wget https://raw.githubusercontent.com/mzet-/linux-exploit-suggester/master/linux-exploit-suggester.sh -O /opt/linux-exploit-suggester/linux-exploit-suggester.sh \
  || echo -e ' '${RED}'[!] Issue with intall'${RESET} 1>&2


##### Install Windows Exploit Suggester - Next Generation
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}WES-NG${RESET} ~ Windows PrivEsc Checker"
git clone https://github.com/bitsadmin/wesng.git /opt/wesng-git  \
  || echo -e ' '${RED}'[!] Issue with intall'${RESET} 1>&2


##### Install RevShellGen
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}RevShellGen${RESET} ~ Reverse Shell Generator"
git clone https://github.com/m0rph-1/revshellgen.git /opt/revshellgen-git \
  || echo -e ' '${RED}'[!] Issue with intall'${RESET} 1>&2


##### Install SILENTTRINITY
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}SILENTTRINITY${RESET} ~ Reverse Shell Generator"
git clone https://github.com/byt3bl33d3r/SILENTTRINITY.git /opt/silenttrinity-git \
  || echo -e ' '${RED}'[!] Issue with intall'${RESET} 1>&2


##### Configure Java default jre
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}Java 8${RESET} ~ default JavaVM"
update-java-alternatives --jre --set java-1.8.0-openjdk-amd64 \
  || echo -e ' '${RED}'[!] Issue with configuration'${RESET} 1>&2


##### Install PEASS - Privilege Escalation Awesome Scripts SUITE (with colors) https://book.hacktricks.xyz
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}PEASS${RESET} ~ Privilege Escalation Awesome Scripts SUITE"
git clone https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite.git /opt/peass-git \
  || echo -e ' '${RED}'[!] Issue with intall'${RESET} 1>&2


##### Configure Home perms, temp until split root and user functions
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) ${GREEN}Resetting my perms${RESET} ~ root->analyst"
chown -R analyst:analyst /home/analyst

################################################################################

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