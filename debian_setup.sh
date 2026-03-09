#!/usr/bin/env bash
# =============================================================================
# debian_setup.sh
# =============================================================================
# Fully automated, idempotent setup for Debian Stable homelab server
# =============================================================================

set -euo pipefail

# ----------------------------- COLORS & LOGGING -----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }

# ----------------------------- SAFETY CHECKS -----------------------------
if [[ $EUID -eq 0 ]]; then
    log_error "Do NOT run as root! Use your normal user with sudo."
fi

if [[ ! -f /etc/debian_version ]]; then
    log_error "This script is for Debian only."
fi

log_info "Starting Debian homelab server setup..."
sleep 1

# ----------------------------- 1. SYSTEM PREP -----------------------------
# ----------------------------- 1. SYSTEM PREP -----------------------------
log_info "1. Updating system and installing base tools..."
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y curl wget gnupg2 ca-certificates \
    build-essential git aptitude

# Unattended security updates
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades

log_success "Base system prepared"

# ----------------------------- 2. TERMINAL ENV -----------------------------
log_info "2. Installing zsh + Oh My Zsh + NVChad..."
sudo apt install -y zsh vim neovim terminator

# Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Zsh config
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
alias c='clear'
alias cat='batcat'
alias grep='rg'
alias find='fd'
alias rm='trash'
alias g='git'
alias d='docker'
alias dc='docker compose'
alias py='python3'
alias matrix='cmatrix -b'
alias weather='curl wttr.in'
EOF

# Set zsh default shell
if [[ "$(basename "$SHELL")" != "zsh" ]]; then
    chsh -s /usr/bin/zsh
fi

# NVChad (only if not already installed)
if [[ ! -d "$HOME/.config/nvim" ]]; then
    git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
fi

log_success "Terminal + NVChad ready"

# ----------------------------- 3. CLI TOOLS -----------------------------
log_info "3. Installing CLI tools..."
sudo apt install -y autojump trash-cli cmatrix ripgrep fd-find htop btop rsync rclone npm

# tldr via npm
if ! command -v tldr &> /dev/null; then
    npm install -g tldr
fi

# bat alias
if ! command -v batcat &> /dev/null && command -v bat &> /dev/null; then
    ln -s "$(which bat)" "$HOME/.local/bin/batcat"
fi

log_success "CLI tools installed"

# ----------------------------- 4. SNAPSHOT / BACKUP -----------------------------
log_info "4. Installing Snapper + Timeshift..."
sudo apt install -y btrfs-progs snapper timeshift

# Snapper root config
if ! sudo snapper -c root list-configs &> /dev/null; then
    sudo snapper -c root create-config /
    sudo snapper -c root set-config TIMELINE_CREATE=yes
    sudo snapper -c root set-config NUMBER_LIMIT=50
    sudo snapper -c root set-config NUMBER_LIMIT_IMPORTANT=10
fi

log_success "Snapshots configured"

# ----------------------------- 5. SECURITY -----------------------------
log_info "5. Installing security packages..."
sudo apt install -y ufw fail2ban

# UFW defaults
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 100.64.0.0/10 to any port 22 comment 'Tailscale SSH'
sudo ufw --force enable

# Fail2Ban
sudo systemctl enable --now fail2ban

# SSH hardening
sudo sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart ssh

log_success "Security ready"

# ----------------------------- 6. TAILSCALE -----------------------------
log_info "6. Installing Tailscale VPN..."
curl -fsSL https://tailscale.com/install.sh | sh
sudo systemctl enable --now tailscaled
log_success "Tailscale installed"

# ----------------------------- 7. DOCKER -----------------------------
log_info "7. Installing Docker + Compose..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker "$USER"
sudo systemctl enable --now docker
log_success "Docker ready"

# ----------------------------- 8. HOMELAB FOLDER STRUCTURE -----------------------------
log_info "8. Creating /srv/docker homelab structure..."
sudo mkdir -p /srv/docker/{nextcloud,jellyfin,openwebui,ollama,qdrant,uptime-kuma,netdata,adguardhome,prometheus-grafana,gitea,code-server,postgres,mysql}
for dir in /srv/docker/*; do
    sudo mkdir -p "$dir"/{data,config}
done
sudo chown -R "$USER:$USER" /srv/docker
log_success "/srv/docker structure ready"

# ----------------------------- 9. MAINTENANCE SCRIPT -----------------------------
log_info "9. Creating homelab maintenance script..."
sudo tee /usr/local/bin/homelab-maintenance.sh > /dev/null << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "=== Updating Debian packages ==="
apt update && apt full-upgrade -y && apt autoremove -y
echo "=== Updating Docker containers ==="
for f in /srv/docker/*/docker-compose.yml; do
  docker compose -f "$f" pull || true
  docker compose -f "$f" up -d || true
done
echo "=== Creating Timeshift snapshot ==="
timeshift --create --comments "weekly auto" --tags W
echo "=== Maintenance complete ==="
EOF

sudo chmod +x /usr/local/bin/homelab-maintenance.sh
log_success "Maintenance script ready"

# ----------------------------- 10. FINAL VERIFICATION -----------------------------
log_info "10. Verifying..."
commands=(zsh batcat rg fd docker tailscale ufw fail2ban)
for cmd in "${commands[@]}"; do
    if command -v "$cmd" &> /dev/null || docker ps | grep -q "$cmd"; then
        log_success "$cmd ready"
    else
        log_warn "$cmd missing"
    fi
done

# ----------------------------- POST-INSTALL -----------------------------
cat << 'EOF'

==============================================
         DEBIAN HOMELAB SETUP COMPLETE! 🎉
==============================================
[ ] Log out/in for zsh & docker group
[ ] Run: sudo tailscale up
[ ] Run Timeshift GUI to schedule snapshots
[ ] Deploy containers: cd /srv/docker/<service> && docker compose up -d
[ ] Run weekly: sudo homelab-maintenance.sh
==============================================
EOF