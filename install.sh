#!/bin/bash

set -e

# ─────────────────────────────────────────────
#  Calendar Display — Installer
#  github.com/jpgtzg/calendar
# ─────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

print_step() { echo -e "\n${CYAN}${BOLD}==> $1${RESET}"; }
print_ok()   { echo -e "${GREEN}✔ $1${RESET}"; }
print_warn() { echo -e "${YELLOW}⚠ $1${RESET}"; }
print_err()  { echo -e "${RED}✘ $1${RESET}"; }

# ─── Banner ───────────────────────────────────
echo -e "${BOLD}"
echo "  ╔════════════════════════════════════════╗"
echo "  ║      Calendar Display — Installer      ║"
echo "  ║        github.com/jpgtzg/calendar       ║"
echo "  ╚════════════════════════════════════════╝"
echo -e "${RESET}"

# ─── OS check ─────────────────────────────────
print_step "Checking system"

ARCH=$(uname -m)
OS=$(uname -s)

if [ "$OS" != "Linux" ]; then
    print_err "This installer is designed for Linux (Armbian / Debian-based)."
    exit 1
fi

if [[ "$ARCH" != "aarch64" && "$ARCH" != "armv7l" ]]; then
    print_warn "Architecture is $ARCH — this is designed for ARM (Orange Pi / Raspberry Pi)."
    read -r -p "Continue anyway? [y/N] " CONTINUE </dev/tty
    [[ "$CONTINUE" =~ ^[Yy]$ ]] || exit 1
fi

print_ok "Running on $OS $ARCH"

# ─── Dependencies ─────────────────────────────
print_step "Installing Node.js 20"

if command -v node &>/dev/null && [[ $(node -v) == v20* ]]; then
    print_ok "Node.js $(node -v) already installed"
else
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
    print_ok "Node.js installed: $(node -v)"
fi

print_step "Installing pnpm"

if command -v pnpm &>/dev/null; then
    print_ok "pnpm $(pnpm -v) already installed"
else
    curl -fsSL https://get.pnpm.io/install.sh | sh -
    # Load pnpm into current shell
    export PNPM_HOME="$HOME/.local/share/pnpm"
    export PATH="$PNPM_HOME:$PATH"
    print_ok "pnpm installed: $(pnpm -v)"
fi

# ─── Clone repo ───────────────────────────────
print_step "Cloning repository"

INSTALL_DIR="$HOME/calendar"

if [ -d "$INSTALL_DIR/.git" ]; then
    print_warn "Repo already exists at $INSTALL_DIR — pulling latest..."
    git -C "$INSTALL_DIR" pull
else
    git clone https://github.com/jpgtzg/calendar.git "$INSTALL_DIR"
    print_ok "Cloned into $INSTALL_DIR"
fi

cd "$INSTALL_DIR"

# ─── Environment variables ────────────────────
print_step "Configuring environment"

echo -e "${YELLOW}You'll need an Unsplash Access Key and your iCalendar URL.${RESET}"
echo -e "Get an Unsplash key at: ${CYAN}https://unsplash.com/developers${RESET}"
echo ""

read -r -p "  Unsplash Access Key: " UNSPLASH_KEY </dev/tty
read -r -p "  iCalendar URL:       " ICAL_URL </dev/tty
read -r -p "  Image reload time in seconds [180]: " RELOAD_TIME </dev/tty
RELOAD_TIME=${RELOAD_TIME:-180}

cat > "$INSTALL_DIR/.env" <<EOF
UNSPLASH_ACCESS_KEY=$UNSPLASH_KEY
ICALENDAR_URL=$ICAL_URL
IMAGE_RELOAD_TIME_SECONDS=$RELOAD_TIME
EOF

print_ok ".env written"

# ─── Install & build ──────────────────────────
print_step "Installing dependencies"
pnpm install
print_ok "Dependencies installed"

print_step "Building app"
pnpm build
print_ok "Build complete"

# ─── Permissions ──────────────────────────────
chmod +x "$INSTALL_DIR/start.sh" "$INSTALL_DIR/uninstall.sh"
print_ok "start.sh and uninstall.sh are executable"

# ─── Autostart ────────────────────────────────
print_step "Setting up autostart"

mkdir -p "$HOME/.config/autostart"

cat > "$HOME/.config/autostart/kiosk.desktop" <<EOF
[Desktop Entry]
Type=Application
Exec=bash -c "DISPLAY=:0 XAUTHORITY=/home/$(whoami)/.Xauthority $INSTALL_DIR/start.sh"
Hidden=false
X-GNOME-Autostart-enabled=true
Name=Kiosk Mode
Comment=Start Chromium in kiosk mode
EOF

print_ok "Autostart entry created at ~/.config/autostart/kiosk.desktop"

# ─── Done ─────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}  Installation complete! 🎉${RESET}"
echo ""
echo -e "  To start now:  ${CYAN}DISPLAY=:0 $INSTALL_DIR/start.sh${RESET}"
echo -e "  Or just reboot and it will start automatically."
echo ""
echo -e "  To uninstall later: ${CYAN}$INSTALL_DIR/uninstall.sh${RESET}"
echo ""

read -r -p "Reboot now? [y/N] " REBOOT </dev/tty
if [[ "$REBOOT" =~ ^[Yy]$ ]]; then
    sudo reboot
fi
