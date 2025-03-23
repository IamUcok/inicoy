#!/bin/bash

USERNAME="kepolu"     # Ganti username sesuai keinginan
PASSWORD="yaanjeng123"   # Ganti password sesuai keinginan

echo "[+] Memeriksa apakah Docker sudah terinstall..."
if ! command -v docker &> /dev/null; then
    echo "[!] Docker tidak ditemukan! Menginstall Docker..."
    curl -fsSL https://get.docker.com | bash
    sudo systemctl start docker
    sudo systemctl enable docker
fi

echo "[+] Menarik image Squid Proxy dari Docker Hub..."
docker pull ubuntu/squid

echo "[+] Membuat direktori konfigurasi Squid..."
mkdir -p ~/squid

echo "[+] Menginstall htpasswd untuk autentikasi..."
sudo apt-get install -y apache2-utils

echo "[+] Membuat file username/password..."
htpasswd -bc ~/squid/passwd $USERNAME $PASSWORD

echo "[+] Menulis konfigurasi Squid dengan autentikasi..."
cat <<EOF > ~/squid/squid.conf
http_port 3128
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic realm "Proxy Auth"
acl authenticated proxy_auth REQUIRED
http_access allow authenticated
EOF

echo "[+] Menjalankan Squid Proxy di Docker..."
docker run -d --name squid-proxy \
  -p 3128:3128 \
  -v ~/squid/squid.conf:/etc/squid/squid.conf \
  -v ~/squid/passwd:/etc/squid/passwd \
  ubuntu/squid

echo "[✔] Instalasi selesai! Squid berjalan di port 3128 dengan autentikasi"
echo "[✔] Gunakan Username: $USERNAME | Password: $PASSWORD"
echo "[✔] Cek status dengan: docker ps"
echo "[✔] Test proxy dengan: curl -x http://$USERNAME:$PASSWORD@$(curl -s ifconfig.me):3128 -L https://www.google.com"
