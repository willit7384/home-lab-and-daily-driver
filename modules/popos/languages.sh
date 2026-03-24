#!/usr/bin/env bash
set -e

echo "[*] Installing pyenv dependencies..."
sudo apt install -y \
    zlib1g-dev libssl-dev libbz2-dev libreadline-dev \
    libsqlite3-dev tk-dev libffi-dev liblzma-dev

echo "[*] Installing pyenv..."
if [ ! -d "$HOME/.pyenv" ]; then
  curl https://pyenv.run | bash
fi

echo "[*] Installing Perl Carton..."
sudo cpanm Carton

echo "[*] Installing latest Node via FNM..."
source ~/.zshrc
fnm install --lts
fnm default $(fnm ls | tail -1)

echo "[✔] Languages module complete."