# Personal Calendar Display

A beautiful calendar application designed to run on an Orange Pi Zero 2W for personal use. Features a full-screen Unsplash image display that transitions to an interactive calendar view, with automatic inactivity timeout returning to the image view.

## Features

- **Full-screen Image Display**: Random travel images from Unsplash refresh every 3 minutes
- **Interactive Calendar**: Click the image to view your calendar with iCalendar integration
- **Auto-return**: Automatically returns to image view after 30 seconds of inactivity
- **ScheduleX Calendar**: Full-featured calendar with day and week views
- **Responsive Design**: Optimized for display on a dedicated screen

## Hardware Requirements

- Orange Pi Zero 2W (or compatible ARM-based single-board computer)
- MicroSD card (minimum 16GB recommended)
- Power supply (5V/2A recommended)
- Display connected to the board

## Installation

### One-liner (recommended)

On a fresh Orange Pi running Armbian or a Debian-based distro, just run:

```bash
curl -fsSL https://raw.githubusercontent.com/jpgtzg/calendar/main/install.sh | bash
```

The installer will:
1. Install Node.js 20 and pnpm if needed
2. Clone the repo into `~/calendar`
3. Prompt you for your Unsplash key, iCalendar URL, and image reload time
4. Build the app
5. Set up XDG autostart so the calendar launches automatically on boot
6. Offer to reboot when done

You'll need:
- An **Unsplash Access Key** — get one at [unsplash.com/developers](https://unsplash.com/developers)
- An **iCalendar URL** — in Google Calendar: Settings → Calendar → Integrate calendar → Public URL to iCal format

### Manual installation

If you prefer to set things up yourself:

```bash
# 1. Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# 2. Install pnpm
curl -fsSL https://get.pnpm.io/install.sh | sh -
source ~/.bashrc

# 3. Clone the repo
git clone https://github.com/jpgtzg/calendar.git ~/calendar
cd ~/calendar

# 4. Create your .env file
nano .env
```

Add to `.env`:

```env
UNSPLASH_ACCESS_KEY=your_unsplash_access_key_here
ICALENDAR_URL=your_icalendar_url_here
IMAGE_RELOAD_TIME_SECONDS=180
```

```bash
# 5. Install dependencies and build
pnpm install
pnpm build

# 6. Make start.sh executable
chmod +x start.sh

# 7. Create the autostart entry
mkdir -p ~/.config/autostart
nano ~/.config/autostart/kiosk.desktop
```

Paste the following (replace `orangepi` with your username if different):

```ini
[Desktop Entry]
Type=Application
Exec=bash -c "DISPLAY=:0 XAUTHORITY=/home/orangepi/.Xauthority /home/orangepi/calendar/start.sh"
Hidden=false
X-GNOME-Autostart-enabled=true
Name=Kiosk Mode
Comment=Start Chromium in kiosk mode
```

```bash
# 8. Reboot
sudo reboot
```

## How It Works

`start.sh` runs on every boot via XDG autostart and:

1. Fetches the latest changes from GitHub
2. Rebuilds the app only if there are new commits
3. Kills any leftover preview server or Chromium instances
4. Starts the Vite preview server
5. Launches Chromium in kiosk mode pointing at `localhost:4173`

## Troubleshooting

**Blank screen after boot**

SSH into the Pi and check if everything is running:

```bash
pgrep -a chromium       # is Chromium running?
ss -tlnp | grep 4173    # is the preview server up?
```

If nothing is running, trigger the script manually:

```bash
DISPLAY=:0 XAUTHORITY=/home/orangepi/.Xauthority ~/calendar/start.sh
```

**Port 4173 already in use**

A previous instance is still running. Kill it and restart:

```bash
pkill -f "vite preview"
DISPLAY=:0 ~/calendar/start.sh
```

**Git conflict on start.sh**

Always edit `start.sh` on your dev machine and push — never edit it directly on the Pi. If a conflict occurs:

```bash
cd ~/calendar
git stash
git pull
chmod +x start.sh
```

**GPU errors in logs**

Lines like `GPU process exiting` or `swiftshader-webgl` are normal on Orange Pi — it falls back to software rendering automatically and the app works fine.

## License

Personal use project — customize as needed.

## Contributors

- [@jpgtzg](https://github.com/jpgtzg)
