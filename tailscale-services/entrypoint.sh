#!/bin/sh
set -e

# Start tailscaled in the background
echo "🟢 Running 'containerboot'"
containerboot &

sleep 2

echo "🟢 Setting Tailscale Serve configuration"
tailscale serve set-config --all /services.json

echo "🟢 Advertising Jellyfin service over Tailscale"
# tailscale serve advertise svc:jellyfin
tailscale serve advertise svc:movies

wait
