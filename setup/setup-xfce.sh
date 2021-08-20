#!/bin/bash
#-Metadata----------------------------------------------------#
#  Filename: setup-xfce.sh             (Update: 2018-06-25)   #
#-Info--------------------------------------------------------#
#  Personal post-install script for Kali Linux Rolling        #
#  This installs and customizes XFCE                          #
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


##### Are we using XFCE?
#--- Configuring XFCE (Power Options)
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}XFCE Power${RESET} options"
cat <<EOF > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfce4-power-manager" version="1.0">
  <property name="xfce4-power-manager" type="empty">
    <property name="power-button-action" type="empty"/>
    <property name="dpms-enabled" type="bool" value="true"/>
    <property name="blank-on-ac" type="int" value="0"/>
    <property name="dpms-on-ac-sleep" type="uint" value="0"/>
    <property name="dpms-on-ac-off" type="uint" value="0"/>
  </property>
</channel>
EOF

###### Setup XFCE Terminal settings
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Customizing ${GREEN}XFCE Terminal${RESET} #settings"
#cat <<EOF > ~/.config/xfce4/terminal/terminalrc \
#  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#[Configuration]
#BackgroundDarkness=0.850000
#MiscAlwaysShowTabs=FALSE
#MiscBell=FALSE
#MiscBellUrgent=FALSE
#MiscBordersDefault=TRUE
#MiscCursorBlinks=TRUE
#MiscCursorShape=TERMINAL_CURSOR_SHAPE_BLOCK
#MiscDefaultGeometry=100x38
#MiscInheritGeometry=FALSE
#MiscMenubarDefault=TRUE
#MiscMouseAutohide=FALSE
#MiscMouseWheelZoom=TRUE
#MiscToolbarDefault=FALSE
#MiscConfirmClose=TRUE
#MiscCycleTabs=TRUE
#MiscTabCloseButtons=TRUE
#MiscTabCloseMiddleClick=TRUE
#MiscTabPosition=GTK_POS_TOP
#MiscHighlightUrls=TRUE
#MiscMiddleClickOpensUri=FALSE
#MiscCopyOnSelect=TRUE
#MiscDefaultWorkingDir=
#MiscRewrapOnResize=TRUE
#MiscUseShiftArrowsToScroll=FALSE
#MiscSlimTabs=FALSE
#ScrollingUnlimited=TRUE
#ColorCursorUseDefault=FALSE
#ColorCursor=#8a8ae2e23434
#EOF


###### Install XFCE4
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}XFCE4 Extras${RESET}${RESET} ~ desktop environment"
export DISPLAY=:0.0
apt -y -qq install xfce4 xfce4-mount-plugin xfce4-notifyd xfce4-places-plugin \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
(dmidecode | grep -iq virtual) \
  || (apt -y -qq install xfce4-battery-plugin \
    || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2)
##--- Configuring XFCE
rm -rf /root/.config/xfce4/panel/*
mkdir -p ~/.config/xfce4/panel/launcher-{6,8,9,16,18,20,19,17,11,10}/
mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml/
cat <<EOF > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfce4-keyboard-shortcuts" version="1.0">
  <property name="commands" type="empty">
    <property name="custom" type="empty">
      <property name="XF86Display" type="string" value="xfce4-display-settings --minimal"/>
      <property name="&lt;Alt&gt;F2" type="string" value="xfrun4"/>
      <property name="&lt;Primary&gt;space" type="string" value="xfce4-appfinder"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;t" type="string" value="/usr/bin/exo-open --launch TerminalEmulator"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;Delete" type="string" value="xflock4"/>
      <property name="&lt;Primary&gt;Escape" type="string" value="xfdesktop --menu"/>
      <property name="&lt;Super&gt;p" type="string" value="xfce4-display-settings --minimal"/>
      <property name="override" type="bool" value="true"/>
    </property>
  </property>
  <property name="xfwm4" type="empty">
    <property name="custom" type="empty">
      <property name="&lt;Alt&gt;&lt;Control&gt;End" type="string" value="move_window_next_workspace_key"/>
      <property name="&lt;Alt&gt;&lt;Control&gt;Home" type="string" value="move_window_prev_workspace_key"/>
      <property name="&lt;Alt&gt;&lt;Control&gt;KP_1" type="string" value="move_window_workspace_1_key"/>
      <property name="&lt;Alt&gt;&lt;Control&gt;KP_2" type="string" value="move_window_workspace_2_key"/>
      <property name="&lt;Alt&gt;&lt;Control&gt;KP_3" type="string" value="move_window_workspace_3_key"/>
      <property name="&lt;Alt&gt;&lt;Control&gt;KP_4" type="string" value="move_window_workspace_4_key"/>
      <property name="&lt;Alt&gt;&lt;Control&gt;KP_5" type="string" value="move_window_workspace_5_key"/>
      <property name="&lt;Alt&gt;&lt;Control&gt;KP_6" type="string" value="move_window_workspace_6_key"/>
      <property name="&lt;Alt&gt;&lt;Control&gt;KP_7" type="string" value="move_window_workspace_7_key"/>
      <property name="&lt;Alt&gt;&lt;Control&gt;KP_8" type="string" value="move_window_workspace_8_key"/>
      <property name="&lt;Alt&gt;&lt;Control&gt;KP_9" type="string" value="move_window_workspace_9_key"/>
      <property name="&lt;Alt&gt;&lt;Shift&gt;Tab" type="string" value="cycle_reverse_windows_key"/>
      <property name="&lt;Alt&gt;Delete" type="string" value="del_workspace_key"/>
      <property name="&lt;Alt&gt;F10" type="string" value="maximize_window_key"/>
      <property name="&lt;Alt&gt;F11" type="string" value="fullscreen_key"/>
      <property name="&lt;Alt&gt;F12" type="string" value="above_key"/>
      <property name="&lt;Alt&gt;F4" type="string" value="close_window_key"/>
      <property name="&lt;Alt&gt;F6" type="string" value="stick_window_key"/>
      <property name="&lt;Alt&gt;F7" type="string" value="move_window_key"/>
      <property name="&lt;Alt&gt;F8" type="string" value="resize_window_key"/>
      <property name="&lt;Alt&gt;F9" type="string" value="hide_window_key"/>
      <property name="&lt;Alt&gt;Insert" type="string" value="add_workspace_key"/>
      <property name="&lt;Alt&gt;space" type="string" value="popup_menu_key"/>
      <property name="&lt;Alt&gt;Tab" type="string" value="cycle_windows_key"/>
      <property name="&lt;Control&gt;&lt;Alt&gt;d" type="string" value="show_desktop_key"/>
      <property name="&lt;Control&gt;&lt;Alt&gt;Down" type="string" value="down_workspace_key"/>
      <property name="&lt;Control&gt;&lt;Alt&gt;Left" type="string" value="left_workspace_key"/>
      <property name="&lt;Control&gt;&lt;Alt&gt;Right" type="string" value="right_workspace_key"/>
      <property name="&lt;Control&gt;&lt;Alt&gt;Up" type="string" value="up_workspace_key"/>
      <property name="&lt;Control&gt;&lt;Shift&gt;&lt;Alt&gt;Left" type="string" value="move_window_left_key"/>
      <property name="&lt;Control&gt;&lt;Shift&gt;&lt;Alt&gt;Right" type="string" value="move_window_right_key"/>
      <property name="&lt;Control&gt;&lt;Shift&gt;&lt;Alt&gt;Up" type="string" value="move_window_up_key"/>
      <property name="&lt;Control&gt;F1" type="string" value="workspace_1_key"/>
      <property name="&lt;Control&gt;F10" type="string" value="workspace_10_key"/>
      <property name="&lt;Control&gt;F11" type="string" value="workspace_11_key"/>
      <property name="&lt;Control&gt;F12" type="string" value="workspace_12_key"/>
      <property name="&lt;Control&gt;F2" type="string" value="workspace_2_key"/>
      <property name="&lt;Control&gt;F3" type="string" value="workspace_3_key"/>
      <property name="&lt;Control&gt;F4" type="string" value="workspace_4_key"/>
      <property name="&lt;Control&gt;F5" type="string" value="workspace_5_key"/>
      <property name="&lt;Control&gt;F6" type="string" value="workspace_6_key"/>
      <property name="&lt;Control&gt;F7" type="string" value="workspace_7_key"/>
      <property name="&lt;Control&gt;F8" type="string" value="workspace_8_key"/>
      <property name="&lt;Control&gt;F9" type="string" value="workspace_9_key"/>
      <property name="&lt;Shift&gt;&lt;Alt&gt;Page_Down" type="string" value="lower_window_key"/>
      <property name="&lt;Shift&gt;&lt;Alt&gt;Page_Up" type="string" value="raise_window_key"/>
      <property name="&lt;Super&gt;Tab" type="string" value="switch_window_key"/>
      <property name="Down" type="string" value="down_key"/>
      <property name="Escape" type="string" value="cancel_key"/>
      <property name="Left" type="string" value="left_key"/>
      <property name="Right" type="string" value="right_key"/>
      <property name="Up" type="string" value="up_key"/>
      <property name="override" type="bool" value="true"/>
      <property name="&lt;Super&gt;Left" type="string" value="tile_left_key"/>
      <property name="&lt;Super&gt;Right" type="string" value="tile_right_key"/>
      <property name="&lt;Super&gt;Up" type="string" value="maximize_window_key"/>
    </property>
  </property>
  <property name="providers" type="array">
    <value type="string" value="xfwm4"/>
    <value type="string" value="commands"/>
  </property>
</channel>
EOF
#--- Configuring XFCE (Power Options)
cat <<EOF > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfce4-power-manager" version="1.0">
  <property name="xfce4-power-manager" type="empty">
    <property name="power-button-action" type="empty"/>
    <property name="dpms-enabled" type="bool" value="true"/>
    <property name="blank-on-ac" type="int" value="0"/>
    <property name="dpms-on-ac-sleep" type="uint" value="0"/>
    <property name="dpms-on-ac-off" type="uint" value="0"/>
  </property>
</channel>
EOF
# Mine
xfconf-query --create --channel xfce4-panel --property /panels/panel-2/plugin-ids \
  -t int -s 6 -t int -s 8 -t int -s 9 -t int -s 16 -t int -s 18 -t int -s 20 -t int -s 19 -t int -s 17 \
  -t int -s 11 -t int -s 10
xfconf-query -n -c xfce4-panel -p /panels/panel-2/position -t string -s "p=10;x=0;y=0"
xfconf-query -n -c xfce4-panel -p /panels/panel-2/position-locked -t bool -s true
xfconf-query -n -c xfce4-panel -p /plugins/plugin-10 -t string -s launcher
xfconf-query -n -c xfce4-panel -p /plugins/plugin-10/items -t string -s "pcmanfm.desktop" -a
xfconf-query -n -c xfce4-panel -p /plugins/plugin-11 -t string -s launcher
xfconf-query -n -c xfce4-panel -p /plugins/plugin-11/items -t string -s "exo-web-browser.desktop" -a
xfconf-query -n -c xfce4-panel -p /plugins/plugin-16 -t string -s launcher
xfconf-query -n -c xfce4-panel -p /plugins/plugin-16/items -t string -s "sublime_text.desktop" -a
xfconf-query -n -c xfce4-panel -p /plugins/plugin-17 -t string -s launcher
xfconf-query -n -c xfce4-panel -p /plugins/plugin-17/items -t string -s "kali-burpsuite.desktop" -a
xfconf-query -n -c xfce4-panel -p /plugins/plugin-18 -t string -s launcher
xfconf-query -n -c xfce4-panel -p /plugins/plugin-18/items -t string -s "kali-zenmap.desktop" -a
xfconf-query -n -c xfce4-panel -p /plugins/plugin-19 -t string -s launcher
xfconf-query -n -c xfce4-panel -p /plugins/plugin-19/items -t string -s "kali-faraday.desktop" -a
xfconf-query -n -c xfce4-panel -p /plugins/plugin-20 -t string -s launcher
xfconf-query -n -c xfce4-panel -p /plugins/plugin-20/items -t string -s "kali-msfconsole.desktop" -a
xfconf-query -n -c xfce4-panel -p /plugins/plugin-6 -t string -s showdesktop
xfconf-query -n -c xfce4-panel -p /plugins/plugin-8 -t string -s separator
xfconf-query -n -c xfce4-panel -p /plugins/plugin-8/style -t string -s "1" -a
xfconf-query -n -c xfce4-panel -p /plugins/plugin-9 -t string -s launcher
xfconf-query -n -c xfce4-panel -p /plugins/plugin-9/items -t string -s "exo-terminal-emulator.desktop" -a
xfconf-query -c xfce4-panel -p /panels/panel-2/size -s 32 -t int --create

##--- clock
xfconf-query -n -c xfce4-panel -p /plugins/plugin-17/show-frame -t bool -s false
xfconf-query -n -c xfce4-panel -p /plugins/plugin-17/mode -t int -s 2
xfconf-query -n -c xfce4-panel -p /plugins/plugin-17/digital-format -t string -s "%R, %Y-%m-%d"
##--- Theme options
apt install -y arc-theme
xfconf-query -n -c xsettings -p /Net/ThemeName -s "Arc-Dark"
xfconf-query -n -c xfwm4 -p /general/theme -s "Arc-Dark"
xfconf-query -n -c xsettings -p /Net/IconThemeName -s "Vibrancy-Kali-Dark"
xfconf-query -n -c xsettings -p /Gtk/MenuImages -t bool -s true
##--- Window management
xfconf-query -n -c xfwm4 -p /general/snap_to_border -t bool -s true
xfconf-query -n -c xfwm4 -p /general/snap_to_windows -t bool -s true
xfconf-query -n -c xfwm4 -p /general/wrap_windows -t bool -s false
xfconf-query -n -c xfwm4 -p /general/wrap_workspaces -t bool -s false
xfconf-query -n -c xfwm4 -p /general/click_to_focus -t bool -s false
xfconf-query -n -c xfwm4 -p /general/click_to_focus -t bool -s true
##--- Start and exit values
xfconf-query -n -c xfce4-session -p /splash/Engine -t string -s ""
xfconf-query -n -c xfce4-session -p /shutdown/LockScreen -t bool -s true
xfconf-query -n -c xfce4-session -p /general/SaveOnExit -t bool -s false
##--- Enable compositing
xfconf-query -n -c xfwm4 -p /general/use_compositing -t bool -s true
xfconf-query -n -c xfwm4 -p /general/frame_opacity -t int -s 85
##--- Disable user folders in home folder
#file=/etc/xdg/user-dirs.conf; [ -e "${file}" ] && cp -n $file{,.bkup}
#sed -i 's/^XDG_/XDG_/g; s/^XDG_DESKTOP/XDG_DESKTOP/g;' "${file}"
#sed -i 's/^enable=.*/enable=False/' "${file}"
#find ~/ -maxdepth 1 -mindepth 1 -type d \
#  \( -o -name 'Music' -o -name 'Pictures' -o -name 'Public' -o -name 'Templates' -o -name 'Videos' \) -empty #-delete
#apt -y -qq install xdg-user-dirs \
#  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#xdg-user-dirs-update
##--- Remove any old sessions
rm -rf ~/.cache/sessions/*


##### Set default term back to xfce4-terminal
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) ${GREEN}xfce4 terminal${RESET}${RESET} ~ default term xfce4-terminal"
#export DISPLAY=:1
#update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal.wrapper


##### Set default file manager to nautilus
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) ${GREEN}nautilus${RESET}${RESET} ~ file manager"
#export DISPLAY=:0.0
#apt -y -qq install nautilus
#xdg-mime default /usr/share/applications/nautilus-classic.desktop inode/directory
#file=~/.config/mimeapps.list; [ -e "${file}" ] && cp -n $file{,.bkup}
#cat <<EOF > "${file}"
#[Desktop Entry]
#Version=1.0
#Type=Application
#Exec=exo-open --launch FileManager %u
#Icon=system-file-manager
#StartupNotify=true
#Terminal=false
#Categories=Utility;X-XFCE;X-Xfce-Toplevel;
#OnlyShowIn=XFCE;
#X-XFCE-MimeType=inode/directory;x-scheme-handler/trash;
#Name=File Manager
#Comment=Browse the file system
#EOF


echo -e '\n'${BLUE}'[*]'${RESET}' '${BOLD}'Done!'${RESET}'\n\a'
exit 0
