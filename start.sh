#!/bin/bash
export DISPLAY=:0
export XAUTHORITY=/home/orangepi/.Xauthority
cd ~/calendar

# Kill any previous instances
pkill -f "vite preview" 2>/dev/null || true
pkill -f "chromium.*4173" 2>/dev/null || true
sleep 1

# Wait briefly for network to come up (best-effort, non-fatal)
for i in $(seq 1 15); do
    if timeout 3 git ls-remote --exit-code origin &>/dev/null; then
        break
    fi
    echo "Waiting for network..."
    sleep 2
done

# Fetch latest changes without merging (best-effort: never block the kiosk on this)
if timeout 20 git fetch; then
    CURRENT_BRANCH=$(git branch --show-current)
    BEHIND_COUNT=$(git rev-list --count HEAD..origin/$CURRENT_BRANCH 2>/dev/null || echo "0")

    if [ "$BEHIND_COUNT" != "0" ]; then
        echo "Changes detected ($BEHIND_COUNT commits behind), pulling and building..."
        if git pull && pnpm install && pnpm build; then
            echo "Update complete."
        else
            echo "Update failed, falling back to existing build."
        fi
    else
        echo "Already up to date, skipping build."
    fi
else
    echo "git fetch failed or timed out, skipping update check."
fi

pnpm preview --host --port 4173 &

for i in $(seq 1 30); do
    if curl -s http://localhost:4173 >/dev/null; then
        break
    fi
    echo "Waiting for Svelte app..."
    sleep 2
done

/usr/bin/chromium --noerrdialogs --disable-infobars --kiosk --incognito http://localhost:4173
