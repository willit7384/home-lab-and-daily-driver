#!/usr/bin/env bash
set -e

echo "[*] Starting Pop!_OS Workstation Bootstrap..."

MODULES=(
  base
  devtools
  languages
  docker
  k8s
  virtualization
  cosmic
  apps
  dotfiles
)

for m in "${MODULES[@]}"; do
    echo "[*] Running module: $m"
    source "modules/popos/$m.sh"
    echo
done

echo "[✔] Bootstrap complete! Please reboot."