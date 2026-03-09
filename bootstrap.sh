#!/usr/bin/env bash
echo "Select setup:"
read -p "[a] Arch daily driver / [d] Debian server: " choice
case $choice in
    a|A) bash arch_setup.sh ;;
    d|D) bash debian_setup.sh ;;
    *) echo "Invalid choice"; exit 1 ;;
esac