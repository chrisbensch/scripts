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


##### Insert BlackArch backbone
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Inserting ${GREEN}BlackArch Linux${RESET} ~ Powerful Attack Linux"
# Download and run current BlackArch bootstrap script
curl https://blackarch.org/strap.sh > /tmp/strap.sh
sed -i 's/  check_internet/  #checkinternet/g' /tmp/strap.sh
bash /tmp/strap.sh


##### Install BlackArch tools
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}BlackArch Tools${RESET} ~ Powerful Attack Tools"
# Download and run current BlackArch bootstrap script
#pacman --noconfirm --needed --quiet -S
#pacman -S jdk8-openjdk blackarch/aircrack-ng blackarch/apt2 blackarch/arachni blackarch/armitage blackarch/arp-scan blackarch/beef blackarch/bettercap blackarch/binwalk blackarch/brutespray blackarch/burpsuite blackarch/cadaver blackarch/cewl blackarch/changeme blackarch/cmsmap blackarch/commix blackarch/crackmapexec blackarch/dirb blackarch/dirbuster blackarch/dirbuster-ng blackarch/dirscanner blackarch/dirsearch blackarch/dnsenum blackarch/dotdotpwn blackarch/droopescan blackarch/empire blackarch/enum4linux blackarch/exploit-db blackarch/exploitpack blackarch/fern-wifi-cracker blackarch/fluxion blackarch/gerix-wifi-cracker blackarch/gobuster blackarch/guymager blackarch/hash-buster blackarch/hashcat blackarch/hashdb blackarch/hashid blackarch/hydra blackarch/intercepter-ng blackarch/jad blackarch/jadx blackarch/jd-gui blackarch/john blackarch/johnny blackarch/joomscan blackarch/kekeo blackarch/kismet blackarch/kismet2earth blackarch/kismet-earth blackarch/laudanum blackarch/lazagne blackarch/linenum blackarch/lynis blackarch/macchanger blackarch/maltego blackarch/masscan blackarch/masscan-automation blackarch/medusa blackarch/metasploit blackarch/mimikatz blackarch/nbtscan blackarch/ncrack blackarch/netdiscover blackarch/nikto blackarch/nirsoft blackarch/nishang blackarch/nmap blackarch/obfs4proxy blackarch/oclhashcat blackarch/ollydbg blackarch/onesixtyone blackarch/onetwopunch blackarch/onionscan blackarch/openstego blackarch/ophcrack blackarch/patator blackarch/pdfcrack blackarch/pentestly blackarch/proxychains-ng blackarch/quickrecon blackarch/rarcrack blackarch/reaver blackarch/reconscan blackarch/responder blackarch/responder-multirelay blackarch/ridenum blackarch/scapy blackarch/searchsploit blackarch/sn1per blackarch/socat blackarch/sparta blackarch/sploitego blackarch/sqlmap blackarch/sqlninja blackarch/sshuttle blackarch/stegdetect blackarch/stunnel blackarch/sysinternals-suite blackarch/tcpdump blackarch/tor blackarch/torsocks blackarch/unicorn-powershell blackarch/unicornscan blackarch/unix-privesc-check blackarch/upx blackarch/veil blackarch/vncrack blackarch/w3af blackarch/webshells blackarch/weevely blackarch/wfuzz blackarch/wifite blackarch/winexe blackarch/wireshark-gtk blackarch/wpscan blackarch/xsser blackarch/xsssniper blackarch/xsstrike blackarch/zaproxy


pacman -S jdk8-openjdk aircrack-ng apt2 arachni blackarch/armitage arp-scan beef bettercap binwalk brutespray burpsuite cadaver cewl changeme cmsmap blackarch/commix blackarch/crackmapexec dirb dirbuster dirbuster-ng dirscanner dirsearch dnsenum dotdotpwn droopescan blackarch/empire enum4linux blackarch/exploit-db exploitpack fern-wifi-cracker fluxion gerix-wifi-cracker gobuster guymager hash-buster hashcat hashdb hashid hydra intercepter-ng jad jadx jd-gui john johnny joomscan kekeo kismet kismet2earth kismet-earth laudanum lazagne linenum lynis macchanger maltego masscan masscan-automation medusa blackarch/metasploit mimikatz nbtscan ncrack netdiscover nikto nirsoft nishang blackarch/nmap obfs4proxy oclhashcat ollydbg onesixtyone onetwopunch onionscan openstego ophcrack patator pdfcrack pentestly proxychains-ng quickrecon rarcrack reaver reconscan responder responder-multirelay ridenum scapy blackarch/searchsploit sn1per socat sparta sploitego blackarch/sqlmap sqlninja sshuttle stegdetect stunnel sysinternals-suite tcpdump tor torsocks unicorn-powershell unicornscan unix-privesc-check upx veil vncrack w3af webshells weevely wfuzz wifite winexe wireshark-gtk wpscan xsser xsssniper xsstrike zaproxy

##### Configure metasploit-framework
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}metasploit framework${RESET} ~ Powerful exploitation framework"
# Setup environment for MSF and Locale
file="/etc/environment"
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#
# This file is parsed by pam_env module
#
# Syntax: simple "KEY=VAL" pairs on separate lines
#
QT_QPA_PLATFORMTHEME="qt5ct"
EDITOR=/usr/bin/nano
MSF_DATABASE_CONFIG="/opt/metasploit/config/database.yml"
LANG=en_US.UTF-8
LC_CTYPE=en_US.UTF-8
EOF

file="/opt/metasploit/msfdb"
echo -n IyEvYmluL2Jhc2gKCk1FVEFTUExPSVRfQkFTRURJUj0vb3B0L21ldGFzcGxvaXQKCkRCX0NPTkY9JHtNRVRBU1BMT0lUX0JBU0VESVJ9L2NvbmZpZy9kYXRhYmFzZS55bWwKREJfTkFNRT1tc2YKREJfVVNFUj1tc2YKREJfUE9SVD01NDMyClBHX1NFUlZJQ0U9cG9zdGdyZXNxbAoKIyMgQmFzaCBDb2xvdXIgb3V0cHV0ClJFRD0iXDAzM1swMTszMW0iCkdSRUVOPSJcMDMzWzAxOzMybSIKWUVMTE9XPSJcMDMzWzAxOzMzbSIKUkVTRVQ9IlwwMzNbMDBtIgoKcHdfZ2VuKCkgewogIG9wZW5zc2wgcmFuZCAtYmFzZTY0IDMyCn0KCnBnX2NtZCgpIHsKICBzdSAtIHBvc3RncmVzIC1jICIkKiIKfQoKZGJfZXhpc3RzKCkgewogIGlmIHBnX2NtZCAicHNxbCAtbHF0IiB8IGN1dCAtZCBcfCAtZiAxIHwgZ3JlcCAtcXcgJDE7IHRoZW4KICAgIHJldHVybiAwCiAgZmkKICByZXR1cm4gMQp9Cgp1c2VyX2V4aXN0cygpIHsKICBpZiBlY2hvICJTRUxFQ1QgdXNlbmFtZSBGUk9NIHBnX3VzZXI7IiB8IHBnX2NtZCAicHNxbCAtcXQgcG9zdGdyZXMiIHwgZ3JlcCAtcXcgJDE7IHRoZW4KICAgIHJldHVybiAwCiAgZmkKICByZXR1cm4gMQp9CgpzdGFydF9kYigpIHsKICBpZiAhIHN5c3RlbWN0bCBzdGF0dXMgJHtQR19TRVJWSUNFfSA+L2Rldi9udWxsOyB0aGVuCiAgICBlY2hvIC1lICIke0dSRUVOfVsrXSR7UkVTRVR9IFN0YXJ0aW5nIGRhdGFiYXNlIgogICAgc3lzdGVtY3RsIHN0YXJ0ICR7UEdfU0VSVklDRX0KICBlbHNlCiAgICBlY2hvIC1lICIke1lFTExPV31baV0ke1JFU0VUfSBEYXRhYmFzZSBhbHJlYWR5IHN0YXJ0ZWQiCiAgZmkKfQoKc3RvcF9kYigpIHsKICBpZiBzeXN0ZW1jdGwgc3RhdHVzICR7UEdfU0VSVklDRX0gPi9kZXYvbnVsbDsgdGhlbgogICAgZWNobyAtZSAiJHtHUkVFTn1bK10ke1JFU0VUfSBTdG9wcGluZyBkYXRhYmFzZSIKICAgIHN5c3RlbWN0bCBzdG9wICR7UEdfU0VSVklDRX0KICBlbHNlCiAgICBlY2hvIC1lICIke1lFTExPV31baV0ke1JFU0VUfSBEYXRhYmFzZSBhbHJlYWR5IHN0b3BwZWQiCiAgZmkKfQoKaW5pdF9kYigpIHsKICBzdGFydF9kYgoKICBpZiBbIC1lICR7REJfQ09ORn0gXTsgdGhlbgogICAgZWNobyAtZSAiJHtZRUxMT1d9W2ldJHtSRVNFVH0gVGhlIGRhdGFiYXNlIGFwcGVhcnMgdG8gYmUgYWxyZWFkeSBjb25maWd1cmVkLCBza2lwcGluZyBpbml0aWFsaXphdGlvbiIKICAgIHJldHVybgogIGZpCgogIERCX1BBU1M9JChwd19nZW4pCiAgaWYgdXNlcl9leGlzdHMgJHtEQl9VU0VSfTsgdGhlbgogICAgZWNobyAtZSAiJHtHUkVFTn1bK10ke1JFU0VUfSBSZXNldHRpbmcgcGFzc3dvcmQgb2YgZGF0YWJhc2UgdXNlciAnJHtEQl9VU0VSfSciCiAgICBwcmludGYgIkFMVEVSIFJPTEUgJHtEQl9VU0VSfSBXSVRIIFBBU1NXT1JEICckREJfUEFTUyc7XG4iIHwgcGdfY21kIHBzcWwgcG9zdGdyZXMgPi9kZXYvbnVsbAogIGVsc2UKICAgIGVjaG8gLWUgIiR7R1JFRU59WytdJHtSRVNFVH0gQ3JlYXRpbmcgZGF0YWJhc2UgdXNlciAnJHtEQl9VU0VSfSciCiAgICBUTVBGSUxFPSQobWt0ZW1wKSB8fCAoZWNobyAtZSAiJHtSRUR9Wy1dJHtSRVNFVH0gRXJyb3I6IENvdWxkbid0IGNyZWF0ZSB0ZW1wIGZpbGUiICYmIGV4aXQgMSkKICAgIHByaW50ZiAiJXNcbiVzXG4iICIke0RCX1BBU1N9IiAiJHtEQl9QQVNTfSIgfCBwZ19jbWQgY3JlYXRldXNlciAtUyAtRCAtUiAtUCAke0RCX1VTRVJ9ID4vZGV2L251bGwgMj4iJHtUTVBGSUxFfSIKICAgIGdyZXAgLXYgIl5FbnRlciBwYXNzd29yZCBmb3IgbmV3IHJvbGU6ICRcfF5FbnRlciBpdCBhZ2FpbjogJCIgIiR7VE1QRklMRX0iCiAgICBybSAtZiAiJHtUTVBGSUxFfSIKICBmaQoKICBpZiAhIGRiX2V4aXN0cyAke0RCX05BTUV9OyB0aGVuCiAgICBlY2hvIC1lICIke0dSRUVOfVsrXSR7UkVTRVR9IENyZWF0aW5nIGRhdGFiYXNlcyAnJHtEQl9OQU1FfSciCiAgICBwZ19jbWQgY3JlYXRlZGIgJHtEQl9OQU1FfSAtTyAke0RCX1VTRVJ9IC1UIHRlbXBsYXRlMCAtRSBVVEYtOAogIGZpCgogIGlmICEgZGJfZXhpc3RzICR7REJfTkFNRX1fdGVzdDsgdGhlbgogICAgZWNobyAtZSAiJHtHUkVFTn1bK10ke1JFU0VUfSBDcmVhdGluZyBkYXRhYmFzZXMgJyR7REJfTkFNRX1fdGVzdCciCiAgICBwZ19jbWQgY3JlYXRlZGIgJHtEQl9OQU1FfV90ZXN0IC1PICR7REJfVVNFUn0gLVQgdGVtcGxhdGUwIC1FIFVURi04CiAgZmkKCiAgZWNobyAtZSAiJHtHUkVFTn1bK10ke1JFU0VUfSBDcmVhdGluZyBjb25maWd1cmF0aW9uIGZpbGUgJyR7REJfQ09ORn0nIgogIGNhdCA+ICR7REJfQ09ORn0gPDwtRU9GCmRldmVsb3BtZW50OgogIGFkYXB0ZXI6IHBvc3RncmVzcWwKICBkYXRhYmFzZTogJHtEQl9OQU1FfQogIHVzZXJuYW1lOiAke0RCX1VTRVJ9CiAgcGFzc3dvcmQ6ICR7REJfUEFTU30KICBob3N0OiBsb2NhbGhvc3QKICBwb3J0OiAkREJfUE9SVAogIHBvb2w6IDUKICB0aW1lb3V0OiA1Cgpwcm9kdWN0aW9uOgogIGFkYXB0ZXI6IHBvc3RncmVzcWwKICBkYXRhYmFzZTogJHtEQl9OQU1FfQogIHVzZXJuYW1lOiAke0RCX1VTRVJ9CiAgcGFzc3dvcmQ6ICR7REJfUEFTU30KICBob3N0OiBsb2NhbGhvc3QKICBwb3J0OiAkREJfUE9SVAogIHBvb2w6IDUKICB0aW1lb3V0OiA1Cgp0ZXN0OgogIGFkYXB0ZXI6IHBvc3RncmVzcWwKICBkYXRhYmFzZTogJHtEQl9OQU1FfV90ZXN0CiAgdXNlcm5hbWU6ICR7REJfVVNFUn0KICBwYXNzd29yZDogJHtEQl9QQVNTfQogIGhvc3Q6IGxvY2FsaG9zdAogIHBvcnQ6ICREQl9QT1JUCiAgcG9vbDogNQogIHRpbWVvdXQ6IDUKRU9GCgogIGVjaG8gLWUgIiR7R1JFRU59WytdJHtSRVNFVH0gQ3JlYXRpbmcgaW5pdGlhbCBkYXRhYmFzZSBzY2hlbWEiCiAgY2QgJHtNRVRBU1BMT0lUX0JBU0VESVJ9LwogIGJ1bmRsZSBleGVjIHJha2UgZGI6bWlncmF0ZSA+L2Rldi9udWxsCn0KCmRlbGV0ZV9kYigpIHsKICBzdGFydF9kYgoKICBpZiBkYl9leGlzdHMgJHtEQl9OQU1FfTsgdGhlbgogICAgZWNobyAtZSAiJHtHUkVFTn1bK10ke1JFU0VUfSBEcm9wcGluZyBkYXRhYmFzZXMgJyR7REJfTkFNRX0nIgogICAgcGdfY21kIGRyb3BkYiAke0RCX05BTUV9CiAgZmkKCiAgaWYgZGJfZXhpc3RzICR7REJfTkFNRX1fdGVzdDsgdGhlbgogICAgZWNobyAtZSAiJHtHUkVFTn1bK10ke1JFU0VUfSBEcm9wcGluZyBkYXRhYmFzZXMgJyR7REJfTkFNRX1fdGVzdCciCiAgICBwZ19jbWQgZHJvcGRiICR7REJfTkFNRX1fdGVzdAogIGZpCgogIGlmIHVzZXJfZXhpc3RzICR7REJfVVNFUn07IHRoZW4KICAgIGVjaG8gLWUgIiR7R1JFRU59WytdJHtSRVNFVH0gRHJvcHBpbmcgZGF0YWJhc2UgdXNlciAnJHtEQl9VU0VSfSciCiAgICBwZ19jbWQgZHJvcHVzZXIgJHtEQl9VU0VSfQogIGZpCgogIGVjaG8gLWUgIiR7R1JFRU59WytdJHtSRVNFVH0gRGVsZXRpbmcgY29uZmlndXJhdGlvbiBmaWxlICR7REJfQ09ORn0iCiAgcm0gLWYgJHtEQl9DT05GfQoKICBzdG9wX2RiCn0KCnJlaW5pdF9kYigpIHsKICBkZWxldGVfZGIKICBpbml0X2RiCn0KCnN0YXR1c19kYigpIHsKICBzeXN0ZW1jdGwgLS1uby1wYWdlciAtbCBzdGF0dXMgJHtQR19TRVJWSUNFfQoKICAjIyBDaGVjayBpZiB0aGUgcG9ydCBpcyBmcmVlCiAgaWYgbHNvZiAtUGkgOiR7REJfUE9SVH0gLXNUQ1A6TElTVEVOIC10ID4vZGV2L251bGwgOyB0aGVuCiAgICBlY2hvICIiCiAgICAjIyBTaG93IG5ldHdvcmsgc2VydmllcwogICAgbHNvZiAtUGkgOiR7REJfUE9SVH0gLXNUQ1A6TElTVEVOCiAgICBlY2hvICIiCiAgICAjIyBTaG93IHJ1bm5pbmcgcHJvY2Vzc2VzCiAgICBwcyAtZiAkKCBsc29mIC1QaSA6JHtEQl9QT1JUfSAtc1RDUDpMSVNURU4gLXQgKQogICAgZWNobyAiIgogIGVsc2UKICAgIGVjaG8gLWUgIiR7WUVMTE9XfVtpXSR7UkVTRVR9IE5vIG5ldHdvcmsgc2VydmljZSBydW5uaW5nIgogIGZpCgogIGlmIFsgLWUgJHtEQl9DT05GfSBdOyB0aGVuCiAgICBlY2hvIC1lICIke0dSRUVOfVsrXSR7UkVTRVR9IERldGVjdGVkIGNvbmZpZ3VyYXRpb24gZmlsZSAoJHtEQl9DT05GfSkiCiAgZWxzZQogICAgZWNobyAtZSAiJHtZRUxMT1d9W2ldJHtSRVNFVH0gTm8gY29uZmlndXJhdGlvbiBmaWxlIGZvdW5kIgogIGZpCn0KCnJ1bl9kYigpIHsKICAjIyBJcyB0aGVyZSBhIGNvbmZpZyBmaWxlPwogIGlmIFsgISAtZSAke0RCX0NPTkZ9IF07IHRoZW4KICAgICMjIE5vLCBzbyBsZXRzIGNyZWF0ZSBvbmUgKGZpcnN0IHRpbWUgcnVuISkKICAgIGluaXRfZGIKICBlbHNlCiAgICMjIFRoZXJlIGlzLCBzbyBqdXN0IHN0YXJ0IHVwCiAgICBzdGFydF9kYgogIGZpCgogICMjIFJ1biBtZXRhc3Bsb2l0LWZyYW1ld29yaydzIG1haW4gY29uc29sZQogIG1zZmNvbnNvbGUKfQoKdXNhZ2UoKSB7CiAgUFJPRz0iJChiYXNlbmFtZSAkMCkiCiAgZWNobwogIGVjaG8gIk1hbmFnZSB0aGUgbWV0YXNwbG9pdCBmcmFtZXdvcmsgZGF0YWJhc2UiCiAgZWNobwogIGVjaG8gIiAgJHtQUk9HfSBpbml0ICAgICAjIHN0YXJ0IGFuZCBpbml0aWFsaXplIHRoZSBkYXRhYmFzZSIKICBlY2hvICIgICR7UFJPR30gcmVpbml0ICAgIyBkZWxldGUgYW5kIHJlaW5pdGlhbGl6ZSB0aGUgZGF0YWJhc2UiCiAgZWNobyAiICAke1BST0d9IGRlbGV0ZSAgICMgZGVsZXRlIGRhdGFiYXNlIGFuZCBzdG9wIHVzaW5nIGl0IgogIGVjaG8gIiAgJHtQUk9HfSBzdGFydCAgICAjIHN0YXJ0IHRoZSBkYXRhYmFzZSIKICBlY2hvICIgICR7UFJPR30gc3RvcCAgICAgIyBzdG9wIHRoZSBkYXRhYmFzZSIKICBlY2hvICIgICR7UFJPR30gc3RhdHVzICAgIyBjaGVjayBzZXJ2aWNlIHN0YXR1cyIKICBlY2hvICIgICR7UFJPR30gcnVuICAgICAgIyBzdGFydCB0aGUgZGF0YWJhc2UgYW5kIHJ1biBtc2Zjb25zb2xlIgogIGVjaG8KICBleGl0IDAKfQoKaWYgWyAiJCMiIC1uZSAxIF07IHRoZW4KICB1c2FnZQpmaQoKaWYgWyAkKGlkIC11KSAtbmUgMCBdOyB0aGVuCiAgZWNobyAtZSAiJHtSRUR9Wy1dJHtSRVNFVH0gRXJyb3I6ICQwIG11c3QgYmUgJHtSRUR9cnVuIGFzIHJvb3Qke1JFU0VUfSIgMT4mMgogIGV4aXQgMQpmaQoKY2FzZSAkMSBpbgogIGluaXQpIGluaXRfZGIgOzsKICByZWluaXQpIHJlaW5pdF9kYiA7OwogIGRlbGV0ZSkgZGVsZXRlX2RiIDs7CiAgc3RhcnQpIHN0YXJ0X2RiIDs7CiAgc3RvcCkgc3RvcF9kYiA7OwogIHN0YXR1cykgc3RhdHVzX2RiIDs7CiAgcnVuKSBydW5fZGIgOzsKICAqKSBlY2hvIC1lICIke1JFRH1bLV0ke1JFU0VUfSBFcnJvcjogdW5yZWNvZ25pemVkIGFjdGlvbiAnJHtSRUR9JHsxfSR7UkVTRVR9JyIgMT4mMjsgdXNhZ2UgOzsKZXNhYwoK | base64 -d > "${file}"


mkdir -p /var/lib/postgres/data
su - postgres -c "initdb --locale en_US.UTF-8 -D '/var/lib/postgres/data'"
/opt/metasploit/msfdb reinit

# #--- First time run with Metasploit
# (( STAGE++ )); echo -e " ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) ${GREEN}Starting Metasploit for the first time${RESET} ~ this ${BOLD}will take a ~350 seconds${RESET} (~6 mintues)"
# echo "Started at: $(date)"
# msfdb start
# msfconsole -q -x 'version;db_status;sleep 310;exit'
