#!/bin/sh
set -eu

# Periodically reload nginx to pick up renewed certificates
(
  while :; do
    sleep 6h
    nginx -s reload
  done
) &
