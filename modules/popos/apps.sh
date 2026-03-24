#!/usr/bin/env bash
set -e

echo "[*] Installing workstation apps..."

# VS Code
sudo apt install -y wget gpg apt-transport-https

wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
 | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
echo \
 "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] \
  https://packages.microsoft.com/repos/code stable main" \
 | sudo tee /etc/apt/sources.list.d/vscode.list

sudo apt update
sudo apt install -y code

# Evolution
sudo apt install -y evolution

# Teams for Linux (flatpak)
flatpak install -y flathub com.github.IsmaelMartinez.teams_for_linux

# GitHub Desktop
wget https://github.com/shiftkey/desktop/releases/download/release-3.2.1-linux1/github-desktop-3.2.1-linux1.deb
sudo apt install -y ./github-desktop-*.deb
rm github-desktop-*.deb

echo "[✔] Apps module complete."