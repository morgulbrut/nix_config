#!/usr/bin/env bash
# Run once on erebor before the first nixos-rebuild:
#   sudo bash modules/pihole/setup.sh
set -euo pipefail

mkdir -p /var/secrets
chmod 700 /var/secrets

read -rsp "Pi-hole web password: " password
echo
printf 'FTLCONF_webserver_api_password=%s\n' "$password" > /var/secrets/pihole.env
chmod 600 /var/secrets/pihole.env
echo "Written: /var/secrets/pihole.env"
echo "After deploy, point LAN clients at erebor's IP as their DNS server."
