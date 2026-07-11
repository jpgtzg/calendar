#!/bin/bash

set -e

# ─────────────────────────────────────────────
#  Calendar Display — Uninstaller
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

# ─── Banner ───────────────────────────────────
echo -e "${BOLD}"
echo "  ╔════════════════════════════════════════╗"
echo "  ║      Calendar Display — Uninstaller    ║"
echo "  ║        github.com/jpgtzg/calendar       ║"
echo "  ╚════════════════════════════════════════╝"
echo -e "${RESET}"

print_warn "This will remove the calendar app, autostart entry, Node.js, and pnpm."
read -r -p "Are you sure? [y/N] " CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

# ─── Kill running instances ───────────────────
print_step "Stopping running processes"

pkill -f "vite preview" 2>/dev/null && print_ok "Killed vite preview" || print_ok "vite preview was not running"
pkill -f "chromium.*4173" 2>/dev/null && print_ok "Killed Chromium" || print_ok "Chromium was not running"

# ─── Autostart ────────────────────────────────
print_step "Removing autostart entry"

if [ -f "$HOME/.config/autostart/kiosk.desktop" ]; then
    rm -f "$HOME/.config/autostart/kiosk.desktop"
    print_ok "Removed kiosk.desktop"
else
    print_ok "No autostart entry found"
fi

# ─── App directory ────────────────────────────
print_step "Removing ~/calendar"

if [ -d "$HOME/calendar" ]; then
    rm -rf "$HOME/calendar"
    print_ok "Removed ~/calendar"
else
    print_ok "~/calendar not found, skipping"
fi

# ─── pnpm ─────────────────────────────────────
print_step "Removing pnpm"

if command -v pnpm &>/dev/null; then
    PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"
    rm -rf "$PNPM_HOME"
    # Remove pnpm lines from shell config files
    sed -i '/pnpm/d' "$HOME/.bashrc" 2>/dev/null || true
    sed -i '/pnpm/d' "$HOME/.zshrc" 2>/dev/null || true
    sed -i '/PNPM_HOME/d' "$HOME/.bashrc" 2>/dev/null || true
    sed -i '/PNPM_HOME/d' "$HOME/.zshrc" 2>/dev/null || true
    print_ok "Removed pnpm"
else
    print_ok "pnpm not found, skipping"
fi

# ─── Node.js ──────────────────────────────────
print_step "Removing Node.js"

if command -v node &>/dev/null; then
    sudo apt-get remove -y nodejs
    sudo apt-get autoremove -y
    # Remove NodeSource repo if present
    sudo rm -f /etc/apt/sources.list.d/nodesource.list
    sudo apt-get update -qq
    print_ok "Removed Node.js"
else
    print_ok "Node.js not found, skipping"
fi

# ─── Done ─────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}  Uninstall complete. 🧹${RESET}"
echo ""
echo -e "  To reinstall, run:"
echo -e "  ${CYAN}curl -fsSL https://raw.githubusercontent.com/jpgtzg/calendar/main/install.sh | bash${RESET}"
echo ""

read -r -p "Reboot now? [y/N] " REBOOT
if [[ "$REBOOT" =~ ^[Yy]$ ]]; then
    sudo reboot
fi
