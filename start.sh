#!/bin/bash
set -e

cd ~/calendar

# Fetch latest changes without merging
git fetch

# Get current branch name
CURRENT_BRANCH=$(git branch --show-current)

# Check if local branch is behind remote
BEHIND_COUNT=$(git rev-list --count HEAD..origin/$CURRENT_BRANCH 2>/dev/null || echo "0")

if [ "$BEHIND_COUNT" != "0" ]; then
    echo "Changes detected ($BEHIND_COUNT commits behind), pulling and building..."
    git pull
    pnpm install
    pnpm build
else
    echo "Already up to date, skipping build."
fi

pkill -f "pnpm preview" || true
pnpm preview --host --port 4173 &

until curl -s http://localhost:4173 >/dev/null; do
    echo "Waiting for Svelte app..."
    sleep 2
done

/usr/bin/chromium --noerrdialogs --disable-infobars --kiosk http://localhost:4173
