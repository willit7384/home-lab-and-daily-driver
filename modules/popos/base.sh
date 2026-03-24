#!/usr/bin/env bash
set -e

echo "[*] Updating Pop!_OS base system..."
sudo apt update && sudo apt upgrade -y

echo "[*] Installing base utilities..."
sudo apt install -y \
    zsh git curl wget unzip tar jq htop \
    ripgrep fd-find fzf bat tmux neovim \
    build-essential software-properties-common

echo "[*] Setting Zsh as default shell..."
chsh -s /usr/bin/zsh $USER

echo "[✔] Base module complete."