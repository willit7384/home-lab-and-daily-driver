#!/usr/bin/env bash
set -e

echo "[*] Updating system..."
sudo apt update -y

# ------------------------------------------------------------
# FASTFETCH (APT)
# ------------------------------------------------------------
echo "[*] Installing fastfetch..."
sudo apt install -y fastfetch

# ------------------------------------------------------------
# TEAMS FOR LINUX (Flatpak)
# ------------------------------------------------------------
echo "[*] Installing Teams for Linux via Flatpak..."
flatpak install -y flathub com.github.IsmaelMartinez.teams_for_linux

# ------------------------------------------------------------
# DOCKER DESKTOP (Deb package)
# ------------------------------------------------------------
echo "[*] Installing Docker Desktop..."

# Remove old versions
sudo apt remove -y docker docker-engine docker.io containerd runc || true

# Install dependencies
sudo apt install -y ca-certificates curl gnupg

# Docker Desktop download
curl -LO https://desktop.docker.com/linux/main/amd64/docker-desktop.deb

# Install Docker Desktop
sudo apt install -y ./docker-desktop.deb

# Cleanup
rm docker-desktop.deb

# Enable Docker
sudo systemctl enable --now docker || true

# ------------------------------------------------------------
# BITWARDEN (Flatpak)
# ------------------------------------------------------------
echo "[*] Installing Bitwarden via Flatpak..."
flatpak install -y flathub com.bitwarden.desktop

echo "[✔] All requested tools installed successfully!"