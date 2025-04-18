#!/bin/bash

set -e

echo "===> Membuat direktori konfigurasi..."
mkdir -p ~/squid-docker/{conf,passwords}
cd ~/squid-docker

echo "===> Install apache2-utils dan docker-compose..."
sudo apt update
sudo apt install -y apache2-utils docker-compose

echo "===> Membuat user 'omyoh' dengan password 'cupubanget'..."
htpasswd -cb passwords/squid_passwd omyoh cupubanget

echo "===> Membuat file konfigurasi squid.conf..."
cat <<EOF > conf/squid.conf
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/squid_passwd
auth_param basic realm Squid Proxy Auth

# ACL untuk autentikasi
acl authenticated proxy_auth REQUIRED
http_access allow authenticated

# Menolak akses dari localhost
acl localhost src 127.0.0.1
http_access deny localhost

# Mengizinkan akses dari semua IP (selain localhost), tetapi harus terautentikasi
http_access allow all

# Menolak semua akses lainnya
http_access deny all

http_port 3128

# Nonaktifkan caching
cache deny all
cache_mem 0 MB
maximum_object_size 0 KB
maximum_object_size_in_memory 0 KB
cache_dir null /tmp

access_log /var/log/squid/access.log
EOF

echo "===> Membuat file docker-compose.yml..."
cat <<EOF > docker-compose.yml
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

echo "===> Menjalankan Squid proxy container..."
docker-compose down || true
docker-compose up -d

# Ambil IP lokal untuk akses proxy
IP_ADDRESS=$(hostname -I | awk '{print $1}')

echo "✅ Selesai! Squid berjalan di port 3128 tanpa cache dan dengan autentikasi."
echo "Gunakan proxy dengan URL:"
echo "http://omyoh:cupubanget@$IP_ADDRESS:3128"
