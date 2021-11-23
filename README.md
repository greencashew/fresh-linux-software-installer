# Fresh OS quick start

Useful bash scripts which allows for quick OS preparation with software, settings and gnome configurations.

Quicken migration from old to new linux machine.

## Software installation

Directory: `/software`

Store all installation details into single or few configuration files.

Currently available commands:

```bash
# Add GPG keyring
# wget -O - https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor | sudo tee /usr/share/keyrings/docker-archive-keyring.gpg
gpg https://download.docker.com/linux/ubuntu/gpg docker-archive-keyring.gpg

# Add PPA repository
# sudo add-apt-repository ppa:appimagelauncher-team/stable -y
ppa:appimagelauncher-team/stable 

# Get public key form keyserver
#sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
key:BBEBDCB318AD50EC6865090613B00F1FD2C19886 

# Add apt source list
# sudo print "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu hirsute stable" > /etc/apt/sources.list.d/docker.list
deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu hirsute stable > docker.list

# Install evolution
# sudo apt install evolution -y
apt evolution

# Install debian package directly
# sudo apt install -y /tmp/keybase_amd64.deb
debian https://prerelease.keybase.io/keybase_amd64.deb

# Install dnf package
# sudo dnf install htop -y
dnf htop

# Install flatpak package
# flatpak install flathub org.signal.Signal -y
flatpak org.signal.Signal

# Install Snap package
# sudo snap install kubectl --classic
snap kubectl --classic

# AppImage installation to $HOME/Apps directory
# $HOME/Apps/ledger-live.AppImage
appimage https://download-live.ledger.com/releases/latest/download/linux ledger-live.AppImage

# Run external script from url
# wget -q -O - https://raw.githubusercontent.com/LedgerHQ/udev-rules/master/add_udev_rules.sh | sudo bash
script https://raw.githubusercontent.com/LedgerHQ/udev-rules/master/add_udev_rules.sh

# Run command
# mkdir /home/janek/test
command mkdir /home/janek/test
```

How to run? (Run in rootless mode.)

```bash
# Read installation commands from software.list by default.
./installation.sh


# Read installation commands from filename.
./installation.sh filename
```

## Gnome settings

Directory: `/gnome`

Automatically setup gnome settings without need of going through UI.

```bash
cd gnome

# Set settings from /gsettings directory if available
./gsettings-install.sh 
```

**WARNING**: gnome settings could highly differ between versions.

Extensions:

```bash
cd gnome

# Install extensions from apt sources (given under ./extensions-install.sh file)
./extensions-install.sh
```

## Dotfiles

Another useful tool for migrating between OS are dotfiles. I'm not going to share them as it contains my private
configurations.

## Extras

Tested on:

- **Pop!_OS 21.04**
- Gnome **3.38.5**
- apt **2.3.11 (amd64)**
- dnf **4.5.2**
- snap **2.52.1**
- Flatpak **1.11.2**

## License

MIT