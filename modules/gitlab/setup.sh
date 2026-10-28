#!/usr/bin/env bash
# Run once on erebor before the first nixos-rebuild:
#   sudo bash modules/gitlab/setup.sh
set -euo pipefail

mkdir -p /var/secrets/gitlab
chmod 700 /var/secrets/gitlab

openssl rand -hex 64 > /var/secrets/gitlab/db-password
openssl rand -hex 64 > /var/secrets/gitlab/secret
openssl rand -hex 64 > /var/secrets/gitlab/otp-secret
openssl rand -hex 64 > /var/secrets/gitlab/db-secret
openssl genpkey -algorithm RSA -out /var/secrets/gitlab/jws-key

read -rsp "GitLab root password (min 8 chars): " password
echo
printf '%s' "$password" > /var/secrets/gitlab/root-password

chmod 600 /var/secrets/gitlab/*
echo "Written: /var/secrets/gitlab/{db-password,secret,otp-secret,db-secret,jws-key,root-password}"
echo "GitLab will be available at http://erebor.local/gitlab after deploy."
echo "First startup takes several minutes while it initialises the database."
