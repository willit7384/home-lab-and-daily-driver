# home-lab-and-daily-driver

# Home Lab & Daily Driver Setup

A fully automated, idempotent setup for a personal home lab (Debian server) and Arch daily driver laptop. Includes consistent dev environment, containers, monitoring, private AI stack, and terminal productivity tools.

---

## **Repo Structure**

```text
home-lab-and-daily-driver/
├── bootstrap.sh        # Entry point script; auto-detects Arch vs Debian
├── arch_setup.sh       # Arch daily driver setup script
├── debian_setup.sh     # Debian server setup script
├── docker/             # Example Docker Compose setups for services
├── dotfiles/           # Zsh, aliases, tmux, NVChad, etc.
└── README.md           # This file
```

---

## **1. Prepare Fresh Machine**

### Arch Laptop

1. Install **fresh Arch** with **Btrfs root** and optional `/boot` partition.
2. Ensure **network connection** and a user with **sudo privileges**.
3. Optional: leave Windows on SATA drive; Linux on NVMe.

### Debian Server

1. Install **Debian Stable** (13 Trixie or newer).
2. Ensure **sudo privileges** and network.
3. Optional: external drive ready for backups.

---

## **2. Run Bootstrap Script**

From the fresh machine:

```bash
curl -fsSL https://raw.githubusercontent.com/willit7384/home-lab-and-daily-driver/main/bootstrap.sh | bash
```

* You will choose:

  * `a` → Arch daily driver
  * `d` → Debian server
* Script automatically installs everything: packages, terminal setup, Docker, Tailscale, monitoring, and optional tools (Snapper, Timeshift, NVChad, Hyprland, Cosmic, etc.)

---

## **3. Post-Install Steps**

### Arch Laptop

* Reboot or log out/in for **zsh, Docker group, Hyprland**.
* Snapper & Timeshift:

  ```bash
  snapper list
  timeshift-gtk
  ```
* Test:

  * Steam, Dolphin, RetroArch
  * Firefox, VSCode, Neovim/NVChad
  * Hyprland or Cosmic desktop
* Optional: enable **Bluetooth, printing**, and extra productivity tools.

### Debian Server

* Reboot or log out/in for **zsh, Docker group**.
* Join Tailscale network:

  ```bash
  sudo tailscale up
  ```
* Docker services check:

  ```bash
  docker ps
  ```
* Portainer dashboard: `http://YOUR-TAILSCALE-IP:9000`
* Run weekly maintenance:

  ```bash
  sudo /usr/local/bin/homelab-maintenance.sh
  ```

---

## **4. Sync Dotfiles Across Machines**

```bash
cd ~
git --git-dir=~/.dotfiles/ --work-tree=$HOME pull
```

* Keeps aliases, zsh configuration, tmux, NVChad, and other settings in sync.

---

## **5. Verify Snapshots & Backups**

* **Arch**: `snapper list` / `timeshift-gtk`
* **Debian**: optional Snapper; Timeshift for snapshots
* Ensure **Btrfs subvolumes** are set before creating snapshots.

---

## **6. Weekly Maintenance**

### Arch Laptop

```bash
paru -Syu && timeshift --create --tags W
```

### Debian Server

```bash
sudo homelab-maintenance.sh
```

* Updates packages, Docker containers, and creates system snapshots.

---

## **7. Optional Services**

* Docker Compose examples for:

  * Nextcloud + PostgreSQL
  * Jellyfin
  * Open WebUI / Ollama / Qdrant
  * AdGuard Home
  * Uptime Kuma
  * Prometheus + Grafana

* Modify `/srv/docker/` folders as needed.

---

## **8. Tips & Notes**

* Scripts are **idempotent**: safe to rerun any time.
* Use **NVChad** for coding in Neovim (optional VSCode).
* Steam, Dolphin, RetroArch, Firefox, Bluetooth, printing, and Cosmic desktop included for Arch daily driver.
* Ensure **snapshots** before major changes.

---

✅ **You now have a secure, fully containerized Debian home lab server and a consistent Arch daily driver.**

---