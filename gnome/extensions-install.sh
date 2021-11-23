#!/usr/bin/env bash

function install {
  which ${2:-$1} &> /dev/null
  if [ $? -ne 0 ]; then
    echo "Installing: ${1}..."
    sudo apt install -y $1
  else
    echo "Already installed: ${1}"
  fi
}

install gnome-shell-pomodoro gnome-pomodoro

busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting…")'