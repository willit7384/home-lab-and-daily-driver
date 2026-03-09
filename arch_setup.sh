#!/usr/bin/env bash
# =============================================================================
# arch_setup.sh
# Fully automated Arch Linux daily driver setup
# Features: Hyprland, Steam, Dolphin, RetroArch, NVChad, Snapper, Timeshift, Fail2Ban, terminal tools
# Requirements: fresh Arch install (base + linux + linux-firmware + Btrfs root)
# Author: Senior Linux Systems Engineer
# Version: 1.1 (March 2026)
# =============================================================================

set -euo pipefail

# ---------------- COLORS & LOGGING ----------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }

# ---------------- SAFETY CHECKS ----------------
if [[ $EUID -eq 0 ]]; then log_error "Do NOT run as root. Run as normal user with sudo."; fi
if ! command -v pacman &> /dev/null; then log_error "This script is for Arch Linux only."; fi

log_info "Starting Arch daily driver setup..."
sleep 1

# ---------------- 1. SYSTEM UPDATE ----------------
log_info "Updating system..."
sudo pacman -Syu --noconfirm --needed base-devel git curl wget
log_success "System updated"

# ---------------- 2. INSTALL PARU ----------------
log_info "Installing paru AUR helper..."
if ! command -v paru &> /dev/null; then
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru
    makepkg -si --noconfirm
    cd ~; rm -rf /tmp/paru
    log_success "paru installed"
else
    log_info "paru already installed"
fi

# ---------------- 3. INSTALL CORE PACKAGES ----------------
PACKAGES=(
    zsh zsh-autosuggestions zsh-syntax-highlighting terminator tmux neovim vim tldr autojump trash-cli cmatrix bat eza ripgrep fd htop btop nodejs npm python python-pip docker docker-compose steam dolphin-emu retroarch snapper timeshift ufw fail2ban firefox code
    blueman cups
)
sudo pacman -S --noconfirm --needed "${PACKAGES[@]}"

log_success "Core packages installed"

# ---------------- 4. ZSH + OH-MY-ZSH + NVChad ----------------
log_info "Configuring terminal..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# NVChad
if [[ ! -d "$HOME/.config/nvim" ]]; then
    git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
fi

cat > "$HOME/.zshrc" << 'EOF'
export PATH="$HOME/.local/bin:$PATH"
ZSH=/usr/share/oh-my-zsh
ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting autojump)
source $ZSH/oh-my-zsh.sh
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases
EOF

cat > "$HOME/.zsh_aliases" << 'EOF'
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons'
alias cat='bat --paging=never'
alias rm='trash'
alias g='git'
alias d='docker'
alias dc='docker compose'
alias py='python'
alias matrix='cmatrix -b'
alias weather='curl wttr.in'
EOF

chsh -s /usr/bin/zsh || true
log_success "ZSH, Oh My Zsh, NVChad configured"

# ---------------- 5. DOCKER ----------------
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"

# ---------------- 6. FIREWALL + SECURITY ----------------
sudo systemctl enable --now ufw fail2ban
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22 comment 'SSH'
sudo ufw --force enable

log_success "Firewall and Fail2Ban enabled"

# ---------------- 7. BTRFS SNAPSHOTS ----------------
sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer

log_success "Snapper enabled for Btrfs snapshots"

# ---------------- 8. HYPRLAND ----------------
log_info "Installing Hyprland..."
paru -S --noconfirm hyprland waybar swaybg grim slurp nwg-look
log_success "Hyprland installed"

# ---------------- 9. SERVICES ----------------
sudo systemctl enable --now tailscaled

log_success "All services enabled"

# ---------------- 10. FINAL CHECK ----------------
commands=(zsh tmux nvim docker tailscale snapper ufw fail2ban steam dolphin-emu retroarch hyprland)
for cmd in "${commands[@]}"; do
    if command -v "$cmd" &> /dev/null || docker ps | grep -q "$cmd"; then
        log_success "$cmd ready"
    else
        log_warn "$cmd missing"
    fi
done

cat << 'EOF'

=========================
ARCH SETUP COMPLETE! 🎉
Reboot or log out/in to activate zsh and Docker group.
Run 'snapper list' and 'timeshift-gtk' to manage snapshots.
Enjoy your new daily driver setup with Hyprland, NVChad, Steam, Dolphin, and RetroArch!
EOF