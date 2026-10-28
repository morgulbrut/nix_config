#!/usr/bin/env bash
set -euo pipefail

# One-time setup for Pi-hole secrets consumed by modules/pihole/system.nix.
# Safe to re-run: existing file is never overwritten.
# Must be run as root (or with sudo).

FILE=/var/secrets/pihole.env

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo $0" >&2
  exit 1
fi

if [[ -e "$FILE" ]]; then
  echo "  skip  $FILE (already exists)"
else
  read -rsp "Pi-hole web UI password: " pw; echo
  printf 'FTLCONF_webserver_api_password=%s\n' "$pw" > "$FILE"
  chmod 600 "$FILE"
  echo "  wrote $FILE"
fi

echo "Done. Pi-hole secrets are in $FILE"
