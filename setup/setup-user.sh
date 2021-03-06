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
mkdir -p ~/.config/sublime-text-3/Installed Packages/
cd ~/.config/sublime-text-3/Installed\ Packages/
curl --progress-bar -k -L -f "https://packagecontrol.io/Package%20Control.sublime-package" --output "Package Control.sublime-package" 2>/dev/null

# Configure Install Packages
mkdir -p ~/.config/sublime-text-3/Packages/User/
cd ~/.config/sublime-text-3/Packages/User/
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
file=~/.config/sublime-text-3/Packages/User/Preferences.sublime-settings; [ -e "${file}" ]
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


##### Install (GNOME) Terminator
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring (GNOME) ${GREEN}Terminator${RESET} ~ multiple terminals in a single window"
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


###### Install WINE
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}WINE${RESET} ~ run Windows programs on *nix"
##--- Using x64?
#if [[ "$(uname -m)" == 'x86_64' ]]; then
#  (( STAGE++ )); echo -e " ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}WINE (x64)${RESET}"
#  export WINEARCH=win32
#  rm -rf ~/.wine
#fi
##--- Run WINE for the first time
#export WINEARCH=win32
#rm -rf ~/.wine
#[ -e /usr/share/windows-binaries/whoami.exe ] && wine /usr/share/windows-binaries/whoami.exe &>/dev/null
##--- Setup default file association for .exe
#mkdir -p ~/.local/share/applications/
#file=~/.local/share/applications/mimeapps.list; [ -e "${file}" ]
#([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
#echo -e 'application/x-ms-dos-executable=wine.desktop' >> "${file}"
#
#
###### Install MinGW (Windows) ~ cross compiling suite
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}MinGW (Windows)${RESET} ~ cross compiling suite"
#aria2c https://jaist.dl.sourceforge.net/project/mingw/Installer/mingw-get/mingw-get-0.6.2-beta-20131004-1/mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip -#d /tmp
#mv /tmp/mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip /tmp/mingw-get.zip \
#  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading mingw-get.zip" 1>&2       #***!!! hardcoded path!
#mkdir -p ~/.wine/drive_c/MinGW/bin/
#unzip -q -o -d ~/.wine/drive_c/MinGW/ /tmp/mingw-get.zip
#pushd ~/.wine/drive_c/MinGW/ >/dev/null
#for FILE in mingw32-base mingw32-gcc-g++ mingw32-gcc-objc; do   #msys-base
#  wine ./bin/mingw-get.exe install "${FILE}" 2>&1 | grep -v 'If something goes wrong, please rerun with\|for more detailed debugging output'
#done
#popd >/dev/null
##--- Add to windows path
#grep -q '^"PATH"=.*C:\\\\MinGW\\\\bin' ~/.wine/system.reg \
#  || sed -i '/^"PATH"=/ s_"$_;C:\\\\MinGW\\\\bin"_' ~/.wine/system.reg
#
#
###### Install Python (Windows via WINE)
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Python (Windows)${RESET}"
#echo -n '[1/2]'; aria2c https://www.python.org/ftp/python/2.7.9/python-2.7.9.msi -d /tmp \
#  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading python.msi" 1>&2       #***!!! hardcoded path!
#mv /tmp/python-2.7.9.msi /tmp/python.msi
#echo -n '[2/2]'; aria2c http://sourceforge.net/projects/pywin32/files/pywin32/Build%20219/pywin32-219.win32-py2.7.exe/download -d /tmp \
#  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading pywin32.exe" 1>&2      #***!!! hardcoded path!
#mv  /tmp/pywin32-219.win32-py2.7.exe /tmp/pywin32.exe
#wine msiexec /i /tmp/python.msi /qb 2>&1 | grep -v 'If something goes wrong, please rerun with\|for more detailed debugging output'
#pushd /tmp/ >/dev/null
#rm -rf "PLATLIB/" "SCRIPTS/"
#unzip -q -o /tmp/pywin32.exe
#cp -rf PLATLIB/* ~/.wine/drive_c/Python27/Lib/site-packages/
#cp -rf SCRIPTS/* ~/.wine/drive_c/Python27/Scripts/
#rm -rf "PLATLIB/" "SCRIPTS/"
#popd >/dev/null


##### Setup SSH
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}SSH${RESET} ~ CLI access"
find ~/.ssh/ -type f ! -name authorized_keys -delete 2>/dev/null
#--- Generate new keys
#ssh-keygen -b 4096 -t rsa1 -f /etc/ssh/ssh_host_key -P "" >/dev/null
ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -P "" >/dev/null


##### Install PCManFM
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}pcmanfm${RESET} ~ PCMAN File Manager"
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