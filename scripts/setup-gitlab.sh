#!/usr/bin/env bash
set -euo pipefail

# One-time setup for GitLab secrets consumed by modules/gitlab/system.nix.
# Safe to re-run: existing files are never overwritten.
# Must be run as root (or with sudo).

DIR=/var/secrets/gitlab

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo $0" >&2
  exit 1
fi

mkdir -p "$DIR"
chmod 700 "$DIR"

rand_hex() { cat /dev/urandom | tr -dc '0-9a-f' | head -c 128; }

gen() {
  local file="$DIR/$1"
  if [[ -e "$file" ]]; then
    echo "  skip  $file (already exists)"
  else
    shift
    "$@" > "$file"
    chmod 600 "$file"
    echo "  wrote $file"
  fi
}

gen db-password          rand_hex
gen secret               rand_hex
gen otp-secret           rand_hex
gen db-secret            rand_hex
gen ar-primary-key       rand_hex
gen ar-deterministic-key rand_hex
gen ar-salt              rand_hex
gen jws-key              nix-shell -p openssl --run \
  'openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048'

# Root password: prompt so it's never left as a placeholder.
if [[ ! -e "$DIR/root-password" ]]; then
  read -rsp "GitLab initial root password: " pw; echo
  printf '%s' "$pw" > "$DIR/root-password"
  chmod 600 "$DIR/root-password"
  echo "  wrote $DIR/root-password"
else
  echo "  skip  $DIR/root-password (already exists)"
fi

echo "Done. GitLab secrets are in $DIR"
