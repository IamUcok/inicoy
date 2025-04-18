#!/bin/bash

# === KONFIGURASI ===
PORT=3128
USERNAME="vodkaace"
PASSWORD="indonesia"
PASSWD_FILE="/etc/squid/passwd"
SQUID_CONF="/etc/squid/squid.conf"
HASIL_FILE="hasil.txt"

# === DAPATKAN IP PUBLIK ===
echo "[+] Mendapatkan IP publik..."
PUBLIC_IP=$(curl -s ifconfig.me)
if [ -z "$PUBLIC_IP" ]; then
    echo "[!] Gagal mendapatkan IP publik."
    exit 1
fi
echo "[+] IP publik: $PUBLIC_IP"

# === INSTALL PAKET YANG DIBUTUHKAN ===
echo "[+] Menginstall Squid dan Apache2-utils..."
sudo apt update
sudo apt install -y squid apache2-utils

# === SETUP USER AUTHENTIKASI ===
echo "[+] Menyiapkan user autentikasi..."
if [ ! -f "$PASSWD_FILE" ]; then
    sudo htpasswd -cb "$PASSWD_FILE" "$USERNAME" "$PASSWORD"
else
    sudo htpasswd -b "$PASSWD_FILE" "$USERNAME" "$PASSWORD"
fi

# === BACKUP KONFIGURASI LAMA ===
echo "[+] Backup konfigurasi Squid lama..."
sudo cp "$SQUID_CONF" "$SQUID_CONF.bak.$(date +%s)"

# === BUAT KONFIGURASI BARU ===
echo "[+] Menulis konfigurasi Squid baru..."
sudo tee "$SQUID_CONF" > /dev/null <<EOF
auth_param basic program /usr/lib/squid/basic_ncsa_auth $PASSWD_FILE
auth_param basic realm Private Proxy
acl authenticated proxy_auth REQUIRED
acl localhost src
http_access deny localhost
http_access allow authenticated

http_port 0.0.0.0:3128

access_log /var/log/squid/access.log
cache_log /var/log/squid/cache.log
cache_store_log none
logfile_rotate 0
buffered_logs on
EOF

# === SET LIMIT FILE DESCRIPTOR SYSTEMD ===
echo "[+] Mengatur limit file descriptor Squid..."
sudo mkdir -p /etc/systemd/system/squid.service.d
sudo tee /etc/systemd/system/squid.service.d/override.conf > /dev/null <<EOF
[Service]
LimitNOFILE=65535
EOF

# === RESTART SQUID DENGAN ANIMASI LOADING ===
echo "[+] Restarting Squid"
echo -n "Loading"
loading_animation() {
    local pid=$1
    local delay=0.1
    local spin='|/-\'
    while ps -p $pid > /dev/null; do
        for i in $(seq 0 3); do
            echo -ne "\rLoading ${spin:$i:1}"
            sleep $delay
        done
    done
    echo -ne "\r[+] Restart Squid selesai!     \n"
}

(
    sudo systemctl daemon-reexec
    sudo systemctl daemon-reload
    sudo systemctl restart squid
) &
loading_animation $!

# === CEK LIMIT FILE DESCRIPTOR ===
echo "[+] Limit file descriptor saat ini:"
cat /proc/$(pidof squid)/limits | grep "Max open files"

# === SIMPAN & TAMPILKAN HASIL ===
HASIL="http://$USERNAME:$PASSWORD@$PUBLIC_IP:$PORT"
echo "$HASIL" > "$HASIL_FILE"

echo ""
echo "✅ Setup selesai! Proxy siap digunakan."
echo "📄 Disimpan di: $HASIL_FILE"
echo ""
echo "[+] Detail Proxy:"
echo "$HASIL"
