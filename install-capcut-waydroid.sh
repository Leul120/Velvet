#!/usr/bin/env bash
# Install Waydroid + CapCut on Ubuntu 26.04 (resolute / Python 3.14).
# Run in a normal terminal so sudo can prompt for your password:
#   bash ~/velvet/install-capcut-waydroid.sh
set -euo pipefail

echo "==> [1/5] Pointing Waydroid repo at resolute (matches Python 3.14)..."
# Fix previous noble setup if present
if [ -f /etc/apt/sources.list.d/waydroid.list ]; then
  sudo sed -i 's/ noble / resolute /g' /etc/apt/sources.list.d/waydroid.list
  echo "Updated existing waydroid.list:"
  cat /etc/apt/sources.list.d/waydroid.list
else
  curl -s https://repo.waydro.id | sudo bash -s resolute
fi

echo "==> [2/5] Installing Waydroid..."
sudo apt update
sudo apt install -y waydroid

echo "==> [3/5] Loading binder kernel modules (if available)..."
sudo modprobe binder_linux devices="binder,hwbinder,vndbinder" 2>/dev/null || true
sudo modprobe ashmem_linux 2>/dev/null || true

echo "==> [4/5] Initializing Waydroid with Google Apps (Play Store)..."
sudo waydroid init -f -s GAPPS

echo "==> [5/5] Starting Waydroid container..."
sudo systemctl enable --now waydroid-container

echo
echo "Waydroid is installed. Next steps:"
echo "  1. Start a session:  waydroid session start"
echo "  2. Open full UI:     waydroid show-full-ui"
echo "  3. In Play Store, sign in with Google and install CapCut."
echo "  4. Later launches:   waydroid app launch com.lemon.lvoverseas"
echo
echo "If Play Store apps won't install, register the device ID at:"
echo "  https://www.google.com/android/uncertified/"
echo "  Get ID with:  sudo waydroid shell -- sqlite3 /data/data/com.google.android.gsf/databases/gservices.db \"select value from main where name='android_id';\""
echo
echo "Done."
