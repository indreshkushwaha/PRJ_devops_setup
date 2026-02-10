#!/usr/bin/env bash
# Create a 1-day self-signed cert so nginx can start before you run certbot.
# Run as root (or with sudo). After running certbot, reload nginx.

set -e
CERT_DIR="/etc/letsencrypt/live/ai.devroad.online"
mkdir -p "$CERT_DIR"
openssl req -x509 -nodes -days 1 -newkey rsa:2048 \
  -keyout "$CERT_DIR/privkey.pem" \
  -out    "$CERT_DIR/fullchain.pem" \
  -subj "/CN=ai.devroad.online"
echo "Created self-signed cert in $CERT_DIR. Start nginx, then run certbot to get a real cert."
