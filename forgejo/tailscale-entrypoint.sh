#!/bin/sh
set -eu

set -a
. /run/secrets/env
set +a

containerboot &

until tailscale status >/dev/null 2>&1; do
	sleep 1
done

tailscale serve --service=svc:git --https=443 http://127.0.0.1:3000

wait
