#!/usr/bin/env bash

# everything you see here came from the Pre-req section of the dev guide:
# http://dev.chromium.org/chromium-os/developer-guide#TOC-Prerequisites

set -e
set -x
## Vagrant runs this script as root, so be aware
echo "=== HELLO FROM $0 ==="
if test "$USER" == "root"
then
  su - vagrant -c "$0"
  exit 0
fi

echo '=== USER INFO ==='
id -a

if test -d chromiumos
then
  echo "You already have a chromiumos directory, which I will not modify." >&2
  exit 0
fi

echo '=== UPDATE APT ==='
sudo apt-get update

echo '=== INSTALL GIT ==='
sudo apt-get install -y git-core gitk git-gui subversion curl

echo '=== INSTALL DEPOT TOOLS ==='
cd $HOME
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
## http://dev.chromium.org/developers/how-tos/install-depot-tools specifically
## says to put depot_tools at the end of the path
echo "PATH=\$PATH:\$HOME/depot_tools" >> $HOME/.bashrc
PATH=$PATH:$HOME/depot_tools

echo '=== FIX UP SUDO ==='
##http://www.chromium.org/tips-and-tricks-for-chromium-os-developers#TOC-Making-sudo-a-little-more-permissive
cat<<SUDO1 | sudo tee /etc/sudoers.d/relax_requirements
Defaults !tty_tickets # Entering your password in one shell affects all shells
Defaults timestamp_timeout=180 # Minutes between re-requesting your password
SUDO1
sudo chmod 0440 /etc/sudoers.d/relax_requirements

echo '=== GENERATE CHROMIUM SSH KEY ==='
ssh-keygen -t rsa -b 1024 -C "$USER@$HOSTNAME" -f $HOME/.ssh/chromium -N ''

echo '=== INSTALL KEYCHAIN ==='
sudo apt-get install -y keychain

echo '=== FIX UMASK ==='
echo 'umask 022' >> $HOME/.bashrc

echo '=== CREATE ChromiumOS DIR ==='
mkdir -p $HOME/chromiumos

echo '=== GERRIT KNOWN HOSTS ==='
cat >> $HOME/.ssh/known_hosts<<SSH1
[gerrit.chromium.org]:29418 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQCfRn+J+e9mU0c4bxFD8v2rhhd3O9WPk435xEtG9FD8a8fOnIubJcpObvQJhfSgYkxVUQOKk97V8b2eGjf72AGBhDQVJMiaLQc8ZGomeNlK/7cWjkJFDoIKQHilHQidz/pgZc/Pu+7Tl2emVGd6425QRK1h47CYtT9IUPt3Jtdv4w==
SSH1

echo '=== INSTALLING CHROMIUMOS ==='
echo '=== You might want to grab a coffee ==='
cd $HOME/chromiumos
repo init -u https://git.chromium.org/git/chromiumos/manifest.git --repo-url https://git.chromium.org/git/external/repo.git
repo sync
