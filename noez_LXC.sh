#!/bin/bash
set -e

# Fungsi untuk error handling
trap 'echo "❌ Error di baris $LINENO. Cek kembali koneksi atau scriptnya."; exit 1' ERR

echo "🔧 Membuat symlink machine-id..."
sudo ln -sf /etc/machine-id /var/lib/dbus/machine-id
echo "✅ Machine ID symlink selesai."

echo "💾 Membuat swapfile 2GB..."
if ! wget -O swapfile2gb.sh https://raw.githubusercontent.com/IamUcok/inicoy/refs/heads/main/swapfile2gb.sh; then
    echo "⚠️ Gagal mendownload swapfile. Lanjutkan ke langkah berikutnya."
else
    chmod +x swapfile2gb.sh
    if ! ./swapfile2gb.sh; then
        echo "⚠️ Gagal membuat swapfile. Lanjutkan ke langkah berikutnya."
    else
        echo "✅ Swapfile berhasil dibuat."
    fi
fi

echo "🛡️  Membuka semua koneksi firewall..."
ufw allow from any to any
echo "✅ Firewall diatur."

echo "🗑️ Menghapus konfigurasi auto-upgrade..."
rm -rf /etc/apt/apt.conf.d/20auto-upgrades
rm -rf /var/lib/ubuntu-advantage/apt-esm/etc/apt/sources.list.d/ubuntu-esm-apps.sources
echo "✅ Auto-upgrade config dihapus."

echo "📦 Update dan Upgrade sistem..."
apt update
apt upgrade -y
echo "✅ Update dan upgrade selesai."

echo "📦 Install aplikasi tambahan..."
apt-get install -y ccze curl tcpdump python3-pip htop nodejs npm net-tools docker.io xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils xrdp
apt autoremove -y
echo "✅ Aplikasi tambahan terinstall."

echo "🖥️ Membuat file .xsession untuk XRDP..."
touch .xsession
chmod +x .xsession
echo 'unset DBUS_SESSION_BUS_ADDRESS
unset SESSION_MANAGER
xfce4-session' > .xsession
echo "✅ .xsession disiapkan."

echo "💻 Install ulang XRDP..."
apt install xrdp -y
echo "✅ XRDP diinstall ulang."

echo "💎 Download dan install UpRock Mining App..."
wget -O uprock.deb https://edge.uprock.com/v1/app-download/UpRock-Mining-v0.0.9.deb
apt install ./uprock.deb -y
echo "✅ UpRock Mining App terinstall."

echo "🛠️ Membuat ulang startwm.sh untuk XRDP..."
rm -f /etc/xrdp/startwm.sh
touch /etc/xrdp/startwm.sh
echo '#!/bin/sh
startxfce4' > /etc/xrdp/startwm.sh
chmod +x /etc/xrdp/startwm.sh
echo "✅ startwm.sh berhasil disiapkan."

echo "🌐 Download dan install Google Chrome..."
wget -O google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt install ./google-chrome.deb -y
echo "✅ Google Chrome terinstall."

echo "🔌 Install Mysteriumnetwork Node..."
sudo -E bash -c "$(curl -s https://raw.githubusercontent.com/IamUcok/inicoy/refs/heads/main/mysteriumnetwork.sh)"
echo "✅ Mysteriumnetwork Node berhasil diinstall."

echo "🧹 Membersihkan APT cache..."
apt clean
apt autoclean
echo "✅ APT cache dibersihkan."

echo "🎉 Semua proses selesai dengan sukses!"

echo "🌍 Mengambil IP Publik..."
ip=$(dig -4 +short +tries=1 +timeout=2 myip.opendns.com @resolver1.opendns.com)

if [ -n "$ip" ]; then
    echo "✅ Setup selesai! Akses server kamu di: http://${ip}:4449"
else
    echo "⚠️  Tidak bisa mendapatkan IP Publik."
fi
