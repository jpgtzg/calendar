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
```

**Getting an Unsplash Access Key:**
1. Go to [Unsplash Developers](https://unsplash.com/developers)
2. Create a new application
3. Copy your Access Key

**Getting an iCalendar URL:**
- Google Calendar: Settings → Calendar → Integrate calendar → Public URL to iCal format
- Other calendar services: Check their documentation for iCal export URLs

### 5. Build the Application

```bash
# Build for production
pnpm run build
```

### 6. Install Production Dependencies

The build process creates a production-ready application. You may need to install a production adapter:

```bash
# Install adapter for Node.js (if not already installed)
pnpm add -D @sveltejs/adapter-node
```

Update `svelte.config.js` to use the Node adapter if needed.

## Running the Application

### Development Mode

```bash
pnpm run dev
```

The application will be available at `http://localhost:5173`

### Production Mode

```bash
# Build first
pnpm run build

# Preview production build
pnpm run preview
```

### Running as a System Service (Recommended)

Create a systemd service file for automatic startup:

```bash
sudo nano /etc/systemd/system/calendar.service
```

Add the following content (adjust paths as needed):

```ini
[Unit]
Description=Personal Calendar Application
After=network.target

[Service]
Type=simple
User=your_username
WorkingDirectory=/home/your_username/calendar
Environment="NODE_ENV=production"
EnvironmentFile=/home/your_username/calendar/.env
ExecStart=/usr/bin/node node_modules/.bin/svelte-kit preview --host 0.0.0.0 --port 3000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start the service:

```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable service to start on boot
sudo systemctl enable calendar.service

# Start the service
sudo systemctl start calendar.service

# Check status
sudo systemctl status calendar.service
```

### Accessing the Application

Once running, access the calendar at:
- Local network: `http://<orange-pi-ip-address>:3000`
- Localhost: `http://localhost:3000`

To find your Orange Pi's IP address:
```bash
hostname -I
```

## Configuration

### Changing the Inactivity Timeout

Edit `src/routes/calendar/+page.svelte` and modify:
```typescript
const INACTIVITY_TIMEOUT = 30000; // 30 seconds (in milliseconds)
```

### Changing the Image Refresh Interval

Edit `src/routes/+page.svelte` and modify:
```typescript
const interval = setInterval(() => location.reload(), 1000 * 60 * 3); // 3 minutes
```

### Changing the Calendar Timezone

Edit `src/routes/calendar/+page.svelte` and modify:
```typescript
timezone: 'America/Mexico_City', // Change to your timezone
```

## Development

### Project Structure

```
calendar/
├── src/
│   ├── routes/
│   │   ├── +page.svelte          # Main image display page
│   │   ├── calendar/
│   │   │   └── +page.svelte      # Calendar view
│   │   └── api/
│   │       ├── img/              # Unsplash image API
│   │       └── ical/             # iCalendar fetch API
│   └── lib/
│       └── components/           # UI components
├── .env                          # Environment variables (create this)
└── package.json
```

### Available Scripts

- `pnpm run dev` - Start development server
- `pnpm run build` - Build for production
- `pnpm run preview` - Preview production build
- `pnpm run check` - Type check
- `pnpm run lint` - Lint code

## Troubleshooting

### Service won't start
- Check service logs: `sudo journalctl -u calendar.service -f`
- Verify Node.js path: `which node`
- Check file permissions on the project directory

### Images not loading
- Verify `UNSPLASH_ACCESS_KEY` is set correctly in `.env`
- Check network connectivity: `ping api.unsplash.com`

### Calendar events not showing
- Verify `ICALENDAR_URL` is set correctly in `.env`
- Test the URL directly: `curl $ICALENDAR_URL`
- Check browser console for errors

### Port already in use
- Change the port in the systemd service file
- Or find and kill the process: `sudo lsof -i :3000`

## License

Personal use project - customize as needed.

## Contributors

- [@jpgtzg](https://github.com/jpgtzg)