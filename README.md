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
- Optional: Display for dedicated calendar display

## How It Works (Important)

- The file `start.sh`:
  - Fetches the latest changes from GitHub
  - Installs dependencies if needed
  - Builds the Svelte application
  - Starts the preview server
  - Launches Chromium in kiosk mode

- `start.sh` is executed automatically by the desktop environment using **XDG autostart**.

## Installation

### 1. Prepare Your Orange Pi Zero 2W

1. Flash Armbian or compatible Linux distribution to your microSD card
2. Boot the Orange Pi and complete initial setup
3. Update the system:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

### 2. Install Node.js and pnpm

```bash
# Install Node.js (using NodeSource repository)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install pnpm
curl -fsSL https://get.pnpm.io/install.sh | sh -
source ~/.bashrc

# Verify installations
node --version
pnpm --version
```

### 3. Clone and Setup the Project

```bash
# Clone the repository 
cd ~
git clone https://github.com/jpgtzg/calendar.git calendar

# Navigate to project directory
cd calendar

# Install dependencies
pnpm install
```

### 4. Configure Environment Variables

Create a `.env` file in the project root:

```bash
# Create .env file
nano .env
```

Add the following environment variables:

```env
UNSPLASH_ACCESS_KEY=your_unsplash_access_key_here
ICALENDAR_URL=your_icalendar_url_here
IMAGE_RELOAD_TIME_SECONDS=180
```

**Environment Variable Descriptions:**
- `UNSPLASH_ACCESS_KEY`: Your Unsplash API access key (required)
- `ICALENDAR_URL`: URL to your iCalendar feed (required)
- `IMAGE_RELOAD_TIME_SECONDS`: Time in seconds between image refreshes (optional, defaults to 180 seconds / 3 minutes)

**Getting an Unsplash Access Key:**
1. Go to [Unsplash Developers](https://unsplash.com/developers)
2. Create a new application
3. Copy your Access Key

**Getting an iCalendar URL:**
- Google Calendar: Settings → Calendar → Integrate calendar → Public URL to iCal format
- Other calendar services: Check their documentation for iCal export URLs

### 5. Make the startup script executable

```bash
chmod +x start.sh
```

### 6. Enable desktop autostart (required)

Create the autostart file:

```bash
mkdir -p ~/.config/autostart
nano ~/.config/autostart/kiosk.desktop
```

Paste:

```ini
[Desktop Entry]
Type=Application
Exec=/home/orangepi/calendar/start.sh
Hidden=false
X-GNOME-Autostart-enabled=true
Name=Kiosk Mode
```

### 7. Running the Application

- No manual commands are needed.
- Reboot the system
- Log into the desktop session
- The calendar will start automatically in kiosk mode

```bash
sudo reboot
```

## License

Personal use project - customize as needed.

## Contributors

- [@jpgtzg](https://github.com/jpgtzg)