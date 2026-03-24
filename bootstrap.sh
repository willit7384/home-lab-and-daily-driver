#!/usr/bin/env bash

echo "Select setup:"
echo "[p] Pop!_OS daily driver"
echo "[a] Arch daily driver"
echo "[d] Debian server"
read -p "Choice: " choice

case $choice in
    p|P) bash popos_setup.sh ;;
    a|A) bash arch_setup.sh ;;
    d|D) bash debian_setup.sh ;;
    *) echo "Invalid choice"; exit 1 ;;
esac