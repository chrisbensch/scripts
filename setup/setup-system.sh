#!/bin/bash
#-Metadata----------------------------------------------------#
#  Filename: setup.sh             (Update: 04-FEB-2023)       #
#-Info--------------------------------------------------------#
#  Personal post-install script for Kali Linux Rolling        #
#-Author(s)---------------------------------------------------#
#  chrisbensch ~ https://github.com/chrisbensch/scripts       #
#  g0tmi1k ~ https://github.com/g0tmi1k/os-scripts original   #
#-------------------------------------------------------------#

#-Defaults-------------------------------------------------------------#


##### Location information
timezone="America/Los_Angeles"       # Set timezone location          [ --timezone Europe/London ]

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

file=/usr/local/sbin/restart-vm-tools; [ -e "${file}" ] && cp -n $file{,.bkup}
  cat <<EOF > "${file}" \
    || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash
killall -q -w vmtoolsd
vmware-user-suid-wrapper vmtoolsd -n vmusr 2>/dev/null
vmtoolsd -b /var/run/vmroot 2>/dev/null
EOF
  chmod +x "${file}"

elif (dmidecode | grep -iq virtualbox); then
  ##### Installing VirtualBox Guest Additions.   Note: Need VirtualBox 4.2.xx+ for the host (http://docs.kali.org/general-use/kali-linux-virtual-box-guest)
  (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}VirtualBox's guest additions${RESET}"
  apt -y -qq install virtualbox-guest-x11 virtualbox-guest-utils virtualbox-guest-dkms \
    || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
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
/etc/init.d/ntp restart
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


##### Install build essential tools
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}build-essential${RESET}"
apt -y -qq install build-essential \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Hide login message
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) ${GREEN}Hiding login message${RESET}"
touch ~/.hushlogin \
  || echo -e ' '${RED}'[!] Issue with shell command'${RESET} 1>&2


##### Install python and python3 essential tools
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}python3 tools${RESET}"
apt -y -qq install python3-pip \
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


##### Configure GRUB
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}GRUB${RESET} ~ boot manager"
grubTimeout=5
(dmidecode | grep -iq virtual) && grubTimeout=1   # Much less if we are in a VM
file=/etc/default/grub; [ -e "${file}" ] && cp -n $file{,.bkup}
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT='${grubTimeout}'/' "${file}"                           # Time out (lower if in a virtual machine, else possible dual booting)
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="vga=0x0318"/' "${file}"   # TTY resolution
update-grub


##### Install Visual Studio Code
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}VS Code${RESET} ~ code editor"
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list
apt update && apt install code \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


###### Setup firefox
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}firefox${RESET} ~ GUI web browser"
timeout 15 firefox >/dev/null 2>&1                # Start and kill. Files needed for first time run
timeout 5 killall -9 -q -w firefox-esr >/dev/null
#--- Wipe session (due to force close)
#find ~/.mozilla/firefox/*.default*/ -maxdepth 1 -type f -name 'sessionstore.*' -delete


##### Configure metasploit ~ http://docs.kali.org/general-use/starting-metasploit-framework-in-kali
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}metasploit${RESET} ~ exploit framework"
msfdb reinit
sleep 5s


##### Install flameshot
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}flameshot${RESET} ~ Powerful yet simple to use screenshot software"
apt -y -qq install flameshot \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install htop
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}htop${RESET} ~ CLI process viewer"
apt -y -qq install htop \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install filezilla
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}FileZilla${RESET} ~ GUI file transfer"
apt -y -qq install filezilla \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install gobuster
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}gobuster${RESET} ~ Directory/File/DNS busting tool"
apt -y -qq install gobuster \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install proxychains-ng (https://bugs.kali.org/view.php?id=2037)
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}proxychains-ng${RESET} ~ Proxifier"
git clone -q -b master https://github.com/rofl0r/proxychains-ng.git /opt/proxychains-ng/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/proxychains-ng/ >/dev/null
git pull -q
make -s clean
./configure --prefix=/usr --sysconfdir=/etc >/dev/null
make -s 2>/dev/null && make -s install   # bad, but it gives errors which might be confusing (still builds)
popd >/dev/null
#--- Add to path (with a 'better' name)
mkdir -p /usr/local/bin/
ln -sf /usr/bin/proxychains4 /usr/local/bin/proxychains-ng


##### Install SecLists
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}SecLists${RESET} ~ pentester's companion"
apt -y -qq install seclists \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Update wordlists
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Updating ${GREEN}wordlists${RESET} ~ collection of wordlists"
apt -y -qq install wordlists curl \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Extract rockyou wordlist
[ -e /usr/share/wordlists/rockyou.txt.gz ] \
  && gzip -dc < /usr/share/wordlists/rockyou.txt.gz > /usr/share/wordlists/rockyou.txt
#--- Add 10,000 Top/Worst/Common Passwords
mkdir -p /usr/share/wordlists/
#mv -f /usr/share/wordlists/10k{\ most\ ,_most_}common.txt
#--- Linking to more - folders
[ -e /usr/share/dirb/wordlists ] \
  && ln -sf /usr/share/dirb/wordlists /usr/share/wordlists/dirb
#--- Extract sqlmap wordlist
#unzip -o -d /usr/share/sqlmap/txt/ /usr/share/sqlmap/txt/wordlist.zip
ln -sf /usr/share/sqlmap/txt/wordlist.txt /usr/share/wordlists/sqlmap.txt
#--- Not enough? Want more? Check below!
#apt search wordlist
#find / \( -iname '*wordlist*' -or -iname '*passwords*' \) #-exec ls -l {} \;


##### Install Empire
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Empire${RESET} ~ PowerShell post-exploitation"
apt -y -qq install powershell-empire starkiller 


##### Install exiftool
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}exiftool${RESET} ~ image file metadata editor"
apt -y -qq install exiftool \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install DBeaver
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}DBeaver${RESET} ~ GUI DB manager"
apt -y -qq install dbeaver \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install BloodHound
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}BloodHound${RESET} ~ Six Degrees of Domain Admin"
apt -y -qq install bloodhound \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install impacket
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}impacket${RESET} ~ network protocols via python"
git clone -q -b master https://github.com/CoreSecurity/impacket.git /opt/impacket/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Install nfs-common
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}nfs-common${RESET} ~ nfs common tools"
apt -y -qq install nfs-common \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Setup SSH
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Setting up ${GREEN}SSH${RESET} ~ CLI access"
apt -y -qq install openssh-server \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Wipe current keys
rm -f /etc/ssh/ssh_host_*
#find ~/.ssh/ -type f ! -name authorized_keys -delete 2>/dev/null
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
#file=/etc/ssh/sshd_config; [ -e "${file}" ] && cp -n $file{,.bkup}
#sed -i 's/^PermitRootLogin .*/PermitRootLogin yes/g' "${file}"      # Accept password login (overwrite Debian 8+'s more secure default option...)
#sed -i 's/^#AuthorizedKeysFile /AuthorizedKeysFile /g' "${file}"    # Allow for key based login


##### Install Powerless
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Powerless${RESET} ~ Windows PrivEsc Checker"Powerless
git clone https://github.com/M4ximuss/Powerless.git /opt/powerless/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Install PowerSploit
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}PowerSploit${RESET} ~ Windows Post-Exploitation Framework"
git clone https://github.com/PowerShellMafia/PowerSploit.git /opt/powersploit \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Install PEASS - Privilege Escalation Awesome Scripts SUITE (with colors) https://book.hacktricks.xyz
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}PEASS${RESET} ~ Privilege Escalation Awesome Scripts SUITE"
git clone https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite.git /opt/peass \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Install AutoRecon - AutoRecon is a multi-threaded network reconnaissance tool which performs automated #enumeration of services. 
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}AutoRecon${RESET} ~ #Multi-threaded Recond Tool"
python3 -m pip install git+https://github.com/Tib3rius/AutoRecon.git \
  || echo -e ' '${RED}'[!] Issue with pip3 install'${RESET} 1>&2


##### Install evil-winrm - WinRM shell
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}evil-winrm${RESET} ~ The ultimate WinRM shell for hacking/pentesting "
git clone https://github.com/Hackplayers/evil-winrm.git /opt/evil-winrm
cd /opt/evil-winrm
gem install winrm winrm-fs stringio \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Install kerbrute
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}kerbrute${RESET} ~ Kerberos pre-auth bruteforcing "
git clone https://github.com/ropnop/kerbrute.git /opt/kerbrute \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Install pyKerbrute
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}pyKerbrute${RESET} ~ Python to perform Kerberos pre-auth bruteforcing "
git clone https://github.com/3gstudent/pyKerbrute.git /opt/pykerbrute \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Install Covenant
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Covenant${RESET} ~ Collaborative .NET C2 framework "
git clone https://github.com/cobbr/Covenant.git /opt/covenant \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Install PywerView
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}PowerView${RESET} ~ PowerView Rewritten in Python"
apt -y -qq install python3-pywerview \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install PywerView
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Post Exploitation${RESET} ~ Kali Post Exploitation Tools"
apt -y -qq install kali-tools-post-exploitation \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install PywerView
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Windows Resources${RESET} ~ Kali Windows Tools Resources"
apt -y -qq install kali-tools-windows-resources \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install SafetyKatz
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}SafetyKatz${RESET} ~ Upgraded mimikatz "
git clone https://github.com/GhostPack/SafetyKatz.git /opt/safetykatz \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Install SharpDump
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}SharpDump${RESET} ~ C# PowerDump "
git clone https://github.com/GhostPack/SharpDump.git /opt/sharpdump \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Install Rubeus
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Rubeus${RESET} ~ C# Kerberos Tools "
git clone https://github.com/GhostPack/Rubeus.git /opt/rubeus \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Install LAPSToolkit
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}LAPSToolkit${RESET} ~ Audit and attack LAPS "
git clone https://github.com/leoloobeek/LAPSToolkit.git /opt/lapstoolkit \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Install LAPSToolkit
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}offsec-tools${RESET} ~ Precompiled Tools "
git clone https://github.com/Syslifters/offsec-tools /opt/offsec-tools \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Install GitHub CLI Tool gh
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}GitHub CLI${RESET} ~ gh for cli "
type -p curl >/dev/null || sudo apt install curl -y
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
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
echo -e '\n'${BLUE}'[*]'${RESET}' '${BOLD}'Done!'${RESET}'\n\a'
exit 0