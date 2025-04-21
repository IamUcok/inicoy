#!/bin/bash

set -e

# Path direktori berdasarkan lokasi skrip ini dijalankan
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF_DIR="$SCRIPT_DIR/conf"
PASSWD_DIR="$SCRIPT_DIR/passwords"
LOG_DIR="$SCRIPT_DIR/logs"
PASSWD_FILE="$PASSWD_DIR/squid_passwd"

echo "===> Membuat direktori konfigurasi..."
mkdir -p "$CONF_DIR" "$PASSWD_DIR" "$LOG_DIR"

echo "===> Install apache2-utils, curl, dan docker-compose..."
sudo apt update
sudo apt install -y apache2-utils docker-compose curl logrotate

if [ -f "$PASSWD_FILE" ]; then
    echo "✅ File $PASSWD_FILE sudah ada, skip pembuatan user."
else
    echo "===> Membuat user 'omyoh' dengan password 'cupubanget'..."
    htpasswd -cb "$PASSWD_FILE" omyoh cupubanget
fi

echo "===> Membuat file konfigurasi squid.conf..."
cat <<EOF > "$CONF_DIR/squid.conf"
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/squid_passwd
auth_param basic realm Squid Proxy Auth

acl authenticated proxy_auth REQUIRED
http_access allow authenticated
http_access allow all
http_access deny all

http_port 0.0.0.0:3128

cache deny all
cache_mem 0 MB
maximum_object_size 0 KB
maximum_object_size_in_memory 0 KB
cache_dir null /tmp

access_log /var/log/squid/access.log
EOF

echo "===> Membuat file docker-compose.yml..."
cat <<EOF > "$SCRIPT_DIR/docker-compose.yml"
version: '3.8'

services:
  squid:
    image: sameersbn/squid:latest
    container_name: squid-auth
    restart: always
    ports:
      - "3128:3128"
    ulimits:
      nofile:
        soft: 65536
        hard: 65536
    volumes:
      - ./conf/squid.conf:/etc/squid/squid.conf
      - ./passwords/squid_passwd:/etc/squid/squid_passwd
      - squid-logs:/var/log/squid

volumes:
  squid-logs:
EOF

echo "===> Membuat konfigurasi logrotate untuk squid..."
sudo tee /etc/logrotate.d/squid > /dev/null <<EOF
/var/log/squid/access.log {
    hourly
    missingok
    rotate 5
    nocreate
    notifempty
    sharedscripts
    postrotate
        /etc/init.d/squid reload > /dev/null
    endscript
}
EOF

echo "===> Menjalankan Squid proxy container..."
cd "$SCRIPT_DIR"
docker-compose down || true
docker-compose up -d

IP_ADDRESS=$(curl -s ifconfig.me)

echo "✅ Selesai! Squid proxy aktif dengan autentikasi dan tanpa caching."
echo "Gunakan URL berikut untuk proxy:"
echo "http://omyoh:cupubanget@$IP_ADDRESS:3128"
