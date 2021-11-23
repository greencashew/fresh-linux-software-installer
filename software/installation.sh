#!/usr/bin/env bash

###################################################################
# INSTALL ALL SOFTWARE PACKAGES FROM software.list or given filename.
# Author       	   Jan Górkiewicz (https://greencashew.dev)
# Repository       https://github.com/greencashew/fresh-linux-software-installer/
#
# Usage:
# Add GPG keyring
# wget -O - https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor | sudo tee /usr/share/keyrings/docker-archive-keyring.gpg
# gpg https://download.docker.com/linux/ubuntu/gpg docker-archive-keyring.gpg
#
# Add PPA repository
# sudo add-apt-repository ppa:appimagelauncher-team/stable -y
# ppa:appimagelauncher-team/stable
#
# Get public key form keyserver
# sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
# key:BBEBDCB318AD50EC6865090613B00F1FD2C19886
#
# Add apt source list
# sudo print "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu hirsute stable" > /etc/apt/sources.list.d/docker.list
# deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu hirsute stable > docker.list
#
# Install evolution
# sudo apt install evolution -y
# apt evolution
#
# Install debian package directly
# sudo apt install -y /tmp/keybase_amd64.deb
# debian https://prerelease.keybase.io/keybase_amd64.deb
#
# Install dnf package
# sudo dnf install htop -y
# dnf htop
#
# Install flatpak package
# flatpak install flathub org.signal.Signal -y
# flatpak org.signal.Signal
#
# Install Snap package
# sudo snap install kubectl --classic
# snap kubectl --classic
#
# AppImage installation to $HOME/Apps directory
# $HOME/Apps/ledger-live.AppImage
# appimage https://download-live.ledger.com/releases/latest/download/linux ledger-live.AppImage
#
# Run external script from url
# wget -q -O - https://raw.githubusercontent.com/LedgerHQ/udev-rules/master/add_udev_rules.sh | sudo bash
# script https://raw.githubusercontent.com/LedgerHQ/udev-rules/master/add_udev_rules.sh
#
# Run command
# mkdir /home/janek/test
# command mkdir /home/janek/test
###################################################################

install_app_image() {
  appImageUrl=$1
  appImage=$2
  if [ ! -d "$HOME"/Apps ]; then
    mkdir "$HOME"/Apps
  fi

  if [ -f "$HOME"/Apps/"$appImage" ]; then
    echo "$appImage already installed."
  else
    echo "Going to install $appImage"
    curl -L "$appImageUrl" -o "/tmp/$appImage"
    chmod a+x "/tmp/$appImage"
    mv "/tmp/$appImage" "$HOME"/Apps/"$appImage"

    echo "$appImage saved into $HOME/Apps directory."
  fi
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

info() {
  echo >&2 -e "${YELLOW}${1-}${NOFORMAT}"
}
error() {
  echo >&2 -e "${RED}${1-}${NOFORMAT}"
}
setup_colors

if [ $# -gt "1" ]; then
  error "Only one file with package list is allowed."
  exit 1
fi

if [ $# -eq "1" ]; then
  CONFIG_FILE=$1
else
  CONFIG_FILE=software.list
fi

if [ "$(id -u)" -eq 0 ]; then
  error "Run script as no sudo user."
  exit 1
fi

info "Prompt SUDO password."
sudo echo "Sudo password applied successfully."

which apt &>/dev/null
if [ $? -ne 0 ]; then
  error "UNABLE TO FIND APT PACKAGE MANAGER. SKIPPING INSTALLATION OF ALL APT PACKAGES."
else
  GPG_URL_LIST=$(cat $CONFIG_FILE | grep -E "^gpg https:.*" | awk -F'#' '{ print $1}' | sed 's/^gpg //g' | tr ' ', ',')
  if [ -n "$GPG_URL_LIST" ]; then
    info "----------------- INSTALLING APT KEY FROM GPG URL -------------------"
    for gpg in $(echo "$GPG_URL_LIST"); do
      arr=(${gpg//,/ })
      echo "${arr[0]} => ${arr[1]}"
      wget -O - "${arr[0]}" | sudo gpg --dearmor | sudo tee /usr/share/keyrings/"${arr[1]}" >/dev/null
    done
    info "----------------- END OF INSTALLATION APT KEY FROM GPG URL -------------------"
  fi

  PPA_NAME_LIST=$(cat $CONFIG_FILE | grep -E "^ppa:" | awk -F'#' '{ print $1}')
  if [ -n "$PPA_NAME_LIST" ]; then
    info "----------------- ADDING PPA REPOSITORIES -------------------"
    for aptRepository in $(echo "$PPA_NAME_LIST"); do
      sudo add-apt-repository "$aptRepository" -y
    done
    info "----------------- END OF ADDING PPA REPOSITORIES -------------------"
  fi

  REPOSITORY_KEY_LIST=$(cat $CONFIG_FILE | grep -E "^key:" | awk -F'#' '{ print $1}' | sed 's/^key://g')
  if [ -n "$REPOSITORY_KEY_LIST" ]; then
    info "----------------- INSTALLING KEY SERVER -------------------"
    for keyserver in $(echo "$REPOSITORY_KEY_LIST"); do
      sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "$keyserver"
    done
    info "----------------- END OF KEY SERVER INSTALLATION -------------------"
  fi

  APT_SOURCES_LIST=$(cat $CONFIG_FILE | grep -E "^deb .* > .*\.list")
  if [ -n "$APT_SOURCES_LIST" ]; then
    info "----------------- ADDING APT SOURCES -------------------"
    printf "Adding following sources:\n$APT_SOURCES_LIST"
    cat $CONFIG_FILE | grep -E "^deb .* > .*\.list" | sudo awk -F '>' '{gsub(/[[:space:]]*/,"",$2); print $1 > "/etc/apt/sources.list.d/"$2}'
    echo ""
    info "----------------- END OF ADDING APT SOURCES -------------------"
  fi

  info "----------------- UPDATING APT REPOSITORY -------------------"
  sudo apt update
  sudo apt autoremove -y
  info "----------------- END OF UPDATING APT REPOSITORY -------------------"

  APT_LIST=$(cat $CONFIG_FILE | grep -E "apt " | awk -F'#' '{ print $1}' | sed 's/^apt //g' | tr ' ', ',')
  if [ -n "$APT_LIST" ]; then
    info "----------------- INSTALLING APT PACKAGES -------------------"
    for package in $APT_LIST; do
      arr=(${package//,/ })
      sudo apt install "${arr[@]}" -y
    done
    info "----------------- END OF APT PACKAGES INSTALLATION -------------------"
  fi

  DEB_LIST=$(cat $CONFIG_FILE | grep -E "debian " | awk -F'#' '{ print $1}' | sed 's/^debian //g')
  if [ -n "$DEB_LIST" ]; then
    info "----------------- INSTALLING DIRECT DEB PACKAGES -------------------"
    for package in $DEB_LIST; do
      echo "Installing ${package}"
      curl -L "$package" -o "/tmp/debPackage.deb"
      chmod +x /tmp/debPackage.deb
      sudo apt install -y /tmp/debPackage.deb
      rm /tmp/debPackage.deb
    done
    info "----------------- END OF DIRECT DEB PACKAGES INSTALLATION -------------------"
  fi
fi

DNF_LIST=$(cat $CONFIG_FILE | grep -E "dnf " | awk -F'#' '{ print $1}' | sed 's/^dnf //g' | tr ' ', ',')
if [ -n "$DNF_LIST" ]; then
  info "----------------- INSTALLING DNF PACKAGES -------------------"
  which dnf &>/dev/null
  if [ $? -ne 0 ]; then
    error "UNABLE TO FIND DNF PACKAGE MANAGER. SKIPPING INSTALLATION OF ALL DNF PACKAGES."
  else
    for package in $DNF_LIST; do
      arr=(${package//,/ })
      sudo dnf install "${arr[@]}" -y
    done
  fi
  info "----------------- END OF DNF PACKAGES INSTALLATION -------------------"
fi

FLATPAK_LIST=$(cat $CONFIG_FILE | grep -E "flatpak " | awk -F'#' '{ print $1}' | sed 's/^flatpak //g' | tr ' ', ',')
if [ -n "$FLATPAK_LIST" ]; then
  info "----------------- INSTALLING FLATPAK PACKAGES -------------------"
  which flatpak &>/dev/null
  if [ $? -ne 0 ]; then
    sudo apt install flatpak -y
  fi

  for package in $FLATPAK_LIST; do
    arr=(${package//,/ })
    flatpak install flathub "${arr[@]}" -y
  done
  info "----------------- END OF FLATPAK PACKAGES INSTALLATION -------------------"
fi

SNAP_LIST=$(cat $CONFIG_FILE | grep -E "snap " | awk -F'#' '{ print $1}' | sed 's/^snap //g' | tr ' ', ',')
if [ -n "$SNAP_LIST" ]; then
  info "----------------- INSTALLING SNAP PACKAGES -------------------"
  which snap &>/dev/null
  if [ $? -ne 0 ]; then
    sudo apt install snapd -y
  fi


  for package in $SNAP_LIST; do
    arr=(${package//,/ })
    sudo snap install "${arr[@]}"
  done
  info "----------------- END OF SNAP PACKAGES INSTALLATION -------------------"
fi

APP_IMAGE_LIST=$(cat $CONFIG_FILE | grep -E "appimage " | awk -F'#' '{ print $1 }' | sed 's/^appimage //g' | tr ' ', ',')
if [ -n "$APP_IMAGE_LIST" ]; then
  info "----------------- INSTALLING APP IMAGES -------------------"
  for image in $APP_IMAGE_LIST; do
    arr=(${image//,/ })
    echo "${arr[0]} => ${arr[1]}"
    install_app_image "${arr[0]}" "${arr[1]}"
  done
  info "----------------- END OF APP IMAGES INSTALLATION -------------------"
fi

COMMAND_LIST=$(cat $CONFIG_FILE | grep -E "^command " | awk -F'#' '{ print $1}' | sed -e "s/^command //" | tr ' ', ',')
if [ -n "$COMMAND_LIST" ]; then
  info "----------------- RUNNING COMMANDS -------------------"

  for script in $COMMAND_LIST; do
    merged=${script//,/ }
    echo "Going to run command: $merged"
    ($merged)
  done
  info "----------------- END OF RUNNING COMMANDS -------------------"
fi

SCRIPT_LIST=$(cat $CONFIG_FILE | grep -E "^script " | awk -F'#' '{ print $1}' | sed -e "s/^script //")
if [ -n "$SCRIPT_LIST" ]; then
  info "----------------- RUNNING SCRIPTS -------------------"
  for script in $SCRIPT_LIST; do
    echo "Going to run: $script script."
    wget -q -O - "$script" | sudo bash
  done
  info "----------------- END OF RUNNING SCRIPTS -------------------"
fi
