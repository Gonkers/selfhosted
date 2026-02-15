#!/bin/bash
set -e

# Start Unbound in the background, keeping stdout/stderr on fd 1 and 2
echo "Starting Unbound..."
/usr/local/sbin/unbound -d -v -c /usr/local/etc/unbound/unbound.conf &
UNBOUND_PID=$!

# Give Unbound a moment to bind port 5300 before starting AdGuard
sleep 2

# Start AdGuard Home in the foreground
echo "Starting AdGuard Home..."
/opt/adguardhome/AdGuardHome \
    --no-check-update \
    -c /opt/adguardhome/conf/AdGuardHome.yaml \
    -w /opt/adguardhome/work &
ADGUARD_PID=$!

# Shut down both processes gracefully on SIGTERM/SIGINT
trap 'echo "Shutting down..."; kill $ADGUARD_PID $UNBOUND_PID 2>/dev/null; wait $ADGUARD_PID $UNBOUND_PID 2>/dev/null' SIGTERM SIGINT

# Wait for either process to exit; if one dies, stop the other
wait -n $UNBOUND_PID $ADGUARD_PID
EXIT_CODE=$?
echo "A process exited with code $EXIT_CODE, shutting down..."
kill $ADGUARD_PID $UNBOUND_PID 2>/dev/null
wait
exit $EXIT_CODE
