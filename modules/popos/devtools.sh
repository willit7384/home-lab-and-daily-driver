#!/usr/bin/env bash
set -e

echo "[*] Installing development tools..."

sudo apt install -y python3 python3-pip python3-venv
sudo apt install -y perl cpanminus
sudo apt install -y nodejs npm

echo "[*] Installing fnm (Node version manager)..."
curl -fsSL https://fnm.vercel.app/install | bash

echo "[✔] Devtools module complete."