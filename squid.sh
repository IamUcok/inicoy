#!/bin/bash

# === KONFIGURASI ===
PORT=3128
USERNAME="vodkaace"
PASSWORD="indonesia"
PASSWD_FILE="/etc/squid/passwd"
SQUID_CONF="/etc/squid/squid.conf"
HASIL_FILE="hasil.txt"

# === DAPATKAN IP PUBLIK ===
PUBLIC_IP=$(curl -s ifconfig.me)
if [ -z "$PUBLIC_IP" ]; then
    echo "[!] Gagal mendapatkan IP publik."
    exit 1
fi
echo "[+] IP publik yang didapat: $PUBLIC_IP"

# === CARI IP DI INTERFACE LOKAL ===
INTERFACE=$(ip -4 addr show | grep -B 1 "$PUBLIC_IP" | head -n 1 | awk '{print $2}' | sed 's/://')
if [ -z "$INTERFACE" ]; then
    echo "[!] Tidak dapat menemukan interface dengan IP $PUBLIC_IP."
    exit 1
fi
echo "[+] IP publik $PUBLIC_IP ditemukan pada interface: $INTERFACE"

# === INSTALL PAKET ===
sudo apt update
sudo apt install squid apache2-utils -y

# === SETUP USER AUTH ===
if [ ! -f "$PASSWD_FILE" ]; then
    sudo htpasswd -cb "$PASSWD_FILE" "$USERNAME" "$PASSWORD"
else
    sudo htpasswd -b "$PASSWD_FILE" "$USERNAME" "$PASSWORD"
fi

# === BACKUP KONFIG LAMA ===
sudo cp "$SQUID_CONF" "$SQUID_CONF.bak.$(date +%s)"

# === TULIS KONFIG BARU ===
sudo tee "$SQUID_CONF" > /dev/null <<EOF
auth_param basic program /usr/lib/squid/basic_ncsa_auth $PASSWD_FILE
auth_param basic realm Private Proxy
acl authenticated proxy_auth REQUIRED
http_access allow authenticated

http_port $PORT
tcp_outgoing_address $PUBLIC_IP

access_log /var/log/squid/access.log
cache_log /var/log/squid/cache.log
cache_store_log none
logfile_rotate 0
buffered_logs on
dns_v4_first on
EOF

# === SETUP LIMIT SYSTEMD ===
sudo mkdir -p /etc/systemd/system/squid.service.d
cat <<EOF | sudo tee /etc/systemd/system/squid.service.d/override.conf
[Service]
LimitNOFILE=65535
EOF

# === RESTART SQUID DENGAN ANIMASI ===
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
    echo -ne "\r[+] Restart Squid Done     \n"
}

(
    sudo systemctl daemon-reexec
    sudo systemctl daemon-reload
    sudo systemctl restart squid
) &
loading_animation $!

# === TAMPILKAN LIMIT FILE DESCRIPTOR ===
echo "Cek limit file descriptor Squid:"
cat /proc/$(pidof squid)/limits | grep "Max open files"

# === SIMPAN HASIL ===
HASIL="http://$USERNAME:$PASSWORD@$PUBLIC_IP:$PORT"
echo "$HASIL" > "$HASIL_FILE"

# === OUTPUT KONFIGURASI PALING BAWAH ===
echo ""
echo "? Setup selesai! Proxy siap digunakan."
echo "?? Hasil disimpan di: $HASIL_FILE"
echo ""
echo "[+] Konfigurasi selesai. Berikut detail proxy kamu:"
echo "$HASIL"
