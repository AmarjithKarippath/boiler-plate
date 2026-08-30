#!/usr/bin/env bash
set -euo pipefail

domains=(olama.so www.olama.so)
email="${EMAIL:-admin@olama.so}"
staging="${STAGING:-0}"
data_path="./certbot"

if [ -f "$data_path/conf/renewal/${domains[0]}.conf" ] && [ "${FORCE:-0}" != "1" ]; then
  echo "Let's Encrypt certificate already exists for ${domains[0]}."
  echo "Re-run with FORCE=1 to replace it."
  exit 0
fi

echo "### Starting nginx so the ACME challenge can be served ..."
docker compose up -d nginx

echo "### Requesting Let's Encrypt certificate for ${domains[*]} ..."

domain_args=()
for domain in "${domains[@]}"; do
  domain_args+=(-d "$domain")
done

staging_arg=()
if [ "$staging" = "1" ]; then
  staging_arg=(--staging)
fi

# Remove dummy/self-signed files so Certbot can write a real lineage.
# nginx keeps running with the certs it already loaded.
rm -rf "$data_path/conf/live/${domains[0]}"
rm -rf "$data_path/conf/archive/${domains[0]}"
rm -rf "$data_path/conf/renewal/${domains[0]}.conf"

docker compose --profile certbot run --rm --no-deps certbot certonly \
  --webroot \
  --webroot-path=/var/www/certbot \
  --email "$email" \
  --agree-tos \
  --no-eff-email \
  --force-renewal \
  "${staging_arg[@]}" \
  "${domain_args[@]}"

docker compose exec nginx nginx -s reload

echo "### Done. Visit https://${domains[0]}"
