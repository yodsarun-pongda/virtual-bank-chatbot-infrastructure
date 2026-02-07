#!/bin/sh
set -eu

if [ -f ./.env ]; then
  set -a
  . ./.env
  set +a
fi

if [ -z "${DOMAIN:-}" ] || [ -z "${CERTBOT_EMAIL:-}" ]; then
  echo "DOMAIN and CERTBOT_EMAIL must be set in .env"
  exit 1
fi

staging_arg=""
if [ "${CERTBOT_STAGING:-0}" = "1" ]; then
  staging_arg="--staging"
fi

# Create a dummy cert so nginx can start

docker compose run --rm --entrypoint \
  "sh -c 'mkdir -p /etc/letsencrypt/live/${DOMAIN} && openssl req -x509 -nodes -newkey rsa:2048 -days 1 -keyout /etc/letsencrypt/live/${DOMAIN}/privkey.pem -out /etc/letsencrypt/live/${DOMAIN}/fullchain.pem -subj \"/CN=${DOMAIN}\"'" \
  certbot

# Start nginx with the dummy cert
docker compose up -d nginx

# Remove dummy cert

docker compose run --rm --entrypoint \
  "sh -c 'rm -rf /etc/letsencrypt/live/${DOMAIN} /etc/letsencrypt/archive/${DOMAIN} /etc/letsencrypt/renewal/${DOMAIN}.conf'" \
  certbot

# Request real cert

docker compose run --rm --entrypoint \
  "certbot certonly --webroot -w /var/www/certbot --email ${CERTBOT_EMAIL} --agree-tos --no-eff-email ${staging_arg} -d ${DOMAIN}" \
  certbot

# Reload nginx to pick up the real cert
docker compose restart nginx
