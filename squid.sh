#!/bin/bash

set -e

echo "===> Membuat direktori konfigurasi..."
mkdir -p ~/squid-docker/{conf,passwords,logs}
cd ~/squid-docker

echo "===> Install apache2-utils, curl, dan docker-compose..."
sudo apt update
sudo apt install -y apache2-utils docker-compose curl logrotate

echo "===> Membuat user 'omyoh' dengan password 'cupubanget'..."
htpasswd -cb passwords/squid_passwd omyoh cupubanget

echo "===> Membuat file konfigurasi squid.conf..."
cat <<EOF > conf/squid.conf
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/squid_passwd
auth_param basic realm Squid Proxy Auth

# ACL untuk autentikasi
acl authenticated proxy_auth REQUIRED
http_access allow authenticated

# Mengizinkan akses dari semua IP (terautentikasi)
http_access allow all

# Menolak semua akses lainnya
http_access deny all

http_port 0.0.0.0:3128

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

echo "===> Membuat konfigurasi logrotate untuk squid..."
sudo cat <<EOF > /etc/logrotate.d/squid
/var/log/squid/access.log {
    hourly                 # Rotasi log setiap jam
    missingok              # Tidak masalah jika file log hilang
    rotate 5               # Simpan hanya 5 log terakhir (5 jam)
    nocreate               # Jangan membuat file log baru (Squid sudah mengatur file lognya)
    notifempty             # Jangan rotasi kalau file log kosong
    sharedscripts          # Eksekusi script setelah rotasi selesai
    postrotate
        # Restart Squid setelah rotasi
        /etc/init.d/squid reload > /dev/null
    endscript
}
EOF

echo "===> Menjalankan Squid proxy container..."
docker-compose down || true
docker-compose up -d

# Ambil IP publik
IP_ADDRESS=$(curl -s ifconfig.me)

echo "✅ Selesai! Squid proxy aktif dengan autentikasi dan tanpa caching."
echo "Gunakan URL berikut untuk proxy:"
echo "http://omyoh:cupubanget@$IP_ADDRESS:3128"
