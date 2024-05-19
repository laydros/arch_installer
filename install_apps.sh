#!/bin/bash

name=$(cat /tmp/user_name)

apps_path="/tmp/apps.csv"
curl https://raw.githubusercontent.com/laydros\
/arch_installer/master/apps.csv > $apps_path

dialog --title "Welcome!" \
    --msgbox "Welcome to the installation script for your apps and dotfiles!" \
    10 60

apps=("essential" "Essentials" on
      "network" "Network" on
      "tools" "Nice tools to have (highly recommended)" on
      "tmux" "Tmux" on
      "notifier" "Notification tools" on
      "git" "Git & git tools" on
      "i3" "i3 wm" on
      "zsh" "The Z-Shell (zsh)" on
      "neovim" "Neovim" on
      "urxvt" "URxvt" on
      "firefox" "Firefox (browser)" off
      "js" "JavaScript tooling" off
      "qutebrowser" "Qutebrowser (browser)" off
      "lynx" "Lynx (browser)" off)

dialog --checklist \
"You can now choose what group of applications you want to install. \n\n\
You can select an option with SPACE and valid your choices with ENTER." \
0 0 0 \
"${apps[@]}" 2> app_choices

choices=$(cat app_choices) && rm app_choices

