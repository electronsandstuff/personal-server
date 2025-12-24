#!/bin/bash

domains=(grafana.chris-pierce.com nootflix.com transit.chris-pierce.com)
rsa_key_size=4096
data_path="./certbot_data"
email="contact@chris-pierce.com" # Adding a valid address is strongly recommended
staging=1 # Set to 1 if you're testing your setup to avoid hitting request limits

if [ -d "$data_path" ]; then
  read -p "Existing data found for $domains. Continue and replace existing certificate? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi


if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  mkdir -p "$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
  echo
fi

echo "### Creating dummy certificate for $domains ..."
path="/etc/letsencrypt/live/$domains"
mkdir -p "$data_path/conf/live/$domains"
docker compose -f docker-compose.yaml run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
    -keyout '$path/privkey.pem' \
    -out '$path/fullchain.pem' \
    -subj '/CN=localhost'" certbot
echo


echo "### Starting nginx ..."
docker compose -f docker-compose.yaml up --force-recreate -d grafana
docker compose -f docker-compose.yaml up --force-recreate -d nginx
echo

echo "### Deleting dummy certificate for $domains ..."
docker compose -f docker-compose.yaml run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/$domains && \
  rm -Rf /etc/letsencrypt/archive/$domains && \
  rm -Rf /etc/letsencrypt/renewal/$domains.conf" certbot
echo


echo "### Requesting Let's Encrypt certificate for $domains ..."
#Join $domains to -d args
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

# Select appropriate email arg
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

# Enable staging mode if needed
if [ $staging != "0" ]; then staging_arg="--staging"; fi

docker compose -f docker-compose.yaml run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal" certbot
echo

echo "### Fixing certificate directory name ..."
docker compose -f docker-compose.yaml run --rm --entrypoint "\
  sh -c 'if [ -d /etc/letsencrypt/live/grafana.chris-pierce.com-0001 ]; then \
    echo \"Renaming directories...\"; \
    rm -rf /etc/letsencrypt/live/grafana.chris-pierce.com && \
    mv /etc/letsencrypt/live/grafana.chris-pierce.com-0001 /etc/letsencrypt/live/grafana.chris-pierce.com && \
    rm -rf /etc/letsencrypt/archive/grafana.chris-pierce.com && \
    mv /etc/letsencrypt/archive/grafana.chris-pierce.com-0001 /etc/letsencrypt/archive/grafana.chris-pierce.com && \
    rm -f /etc/letsencrypt/renewal/grafana.chris-pierce.com.conf && \
    mv /etc/letsencrypt/renewal/grafana.chris-pierce.com-0001.conf /etc/letsencrypt/renewal/grafana.chris-pierce.com.conf && \
    sed -i \"s/grafana.chris-pierce.com-0001/grafana.chris-pierce.com/g\" /etc/letsencrypt/renewal/grafana.chris-pierce.com.conf && \
    echo \"Fixing symlinks...\"; \
    cd /etc/letsencrypt/live/grafana.chris-pierce.com && \
    ln -sf ../../archive/grafana.chris-pierce.com/cert1.pem cert.pem && \
    ln -sf ../../archive/grafana.chris-pierce.com/chain1.pem chain.pem && \
    ln -sf ../../archive/grafana.chris-pierce.com/fullchain1.pem fullchain.pem && \
    ln -sf ../../archive/grafana.chris-pierce.com/privkey1.pem privkey.pem && \
    echo \"Certificate directory fixed successfully\"; \
  fi'" certbot
echo

echo "### Reloading nginx ..."
docker compose -f docker-compose.yaml exec nginx nginx -s reload
