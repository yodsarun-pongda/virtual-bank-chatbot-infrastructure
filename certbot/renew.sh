#!/bin/sh
set -eu

while :; do
  certbot renew --webroot -w /var/www/certbot --quiet --no-self-upgrade || true
  sleep 12h
done
