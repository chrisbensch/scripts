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

##### Configure User Settings

## Shared folders support for Open-VM-Tools
file=/usr/local/sbin/mount-shared-folders; [ -e "${file}" ]
ln -sf "${file}" ~/Desktop/mount-shared-folders.sh
 ## Restart Open-VM-Tools
file=/usr/local/sbin/restart-vm-tools; [ -e "${file}" ]
ln -sf "${file}" ~/Desktop/restart-vm-tools.sh


#### Configuring Sublime Text
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}Sublime Text${RESET} ~ Awesome Editor"
# Run once to do basic setup
subl >/dev/null 2>&1                # Start and kill. Files/folders needed for first time run
sleep 5
killall -9 -q -w sublime_text >/dev/null

# Install Package Control
mkdir -p "~/.config/sublime-text/Installed Packages/"
cd "~/.config/sublime-text/Installed Packages/"
curl --progress-bar -k -L -f "https://packagecontrol.io/Package%20Control.sublime-package" --output "Package Control.sublime-package" 2>/dev/null

# Configure Install Packages
mkdir -p ~/.config/sublime-text/Packages/User/
cd ~/.config/sublime-text/Packages/User/
touch "Package Control.sublime-settings"
file="Package Control.sublime-settings"
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
sleep 30
killall -9 -q -w sublime_text >/dev/null

# Run ST3 once again to get packages installed
subl >/dev/null 2>&1
sleep 60
killall -9 -q -w sublime_text >/dev/null

# Configure special settings
file=~/.config/sublime-text/Packages/User/Preferences.sublime-settings; [ -e "${file}" ]
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



##### Install tmux - all users
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}tmux${RESET} ~ multiplex virtual consoles"
file=~/.tmux.conf; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/tmux.conf
#--- Configure tmux
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#-Settings---------------------------------------------------------------------
## Make it like screen (use CTRL+a)
#unbind C-b
#set -g prefix C-a

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
source ~/.bashrc   #(issues if you use /bin/bash & Debian)

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
cp /opt/scripts/misc/places.sqlite.backup /tmp
sqlite3 "${file}" ".restore /tmp/places.sqlite.backup"


##### Setup SSH
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}SSH${RESET} ~ CLI access"
find ~/.ssh/ -type f ! -name authorized_keys -delete 2>/dev/null
#--- Generate new keys
#ssh-keygen -b 4096 -t rsa1 -f /etc/ssh/ssh_host_key -P "" >/dev/null
ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -P "" >/dev/null


##### Install oh-my-zsh
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}oh-my-zsh${RESET} ~ zsh customization"
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#Installing zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/plugins/zsh-syntax-highlighting


##### Install PowerLevel10k
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}PowerLevel10k${RESET} ~ zsh customization"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k \
  || echo -e ' '${RED}'[!] Issue with git clone'${RESET} 1>&2
#Installing PowerLevel10k fonts
#cd /usr/local/share/fonts || return
mkdir $HOME/.fonts
wget -P $HOME/.fonts/ "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS NF Regular.ttf"
wget -P $HOME/.fonts/ "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS NF Bold.ttf"
wget -P $HOME/.fonts/ "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS NF Italic.ttf"
wget -P $HOME/.fonts/ "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS NF Bold Italic.ttf"
fc-cache -rv

#Configuring PowerLevel10k - cheating
cp ./res/p10k.zsh ~/.p10k.zsh
chmod 775 ~/.p10k.zsh
cp ./res/zshrc ~/.zshrc
chmod 755 ~/.zshrc

################################################################################


##### Clean the system
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) ${GREEN}Cleaning${RESET} the system"
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