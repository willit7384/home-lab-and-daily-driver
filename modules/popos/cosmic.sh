#!/usr/bin/env bash
set -e

echo "[*] Configuring Pop!_OS COSMIC environment..."

# Enable System76-power for NVIDIA/Intel switching
sudo apt install -y system76-power

# GPU switching works automatically under COSMIC
system76-power graphics hybrid || true

echo "[✔] COSMIC module complete."