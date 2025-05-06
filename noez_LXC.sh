#!/bin/bash
set -e

# Fungsi untuk error handling
trap 'echo "❌ Error di baris $LINENO. Cek kembali koneksi atau scriptnya."; exit 1' ERR

echo "🔐 Mengganti password root..."
echo "root:Amirin846385!" | chpasswd
echo "✅ Password root berhasil diganti."

echo "🔧 Reset Machine ID..."
#echo 'PS1="\u@$(curl -s ifconfig.me):\w\$ "' >> .bashrc
rm -f /etc/machine-id /var/lib/dbus/machine-id
systemd-machine-id-setup
ln -s /etc/machine-id /var/lib/dbus/machine-id
hostnamectl set-hostname vps-$(tr -dc a-z0-9 </dev/urandom | head -c6)
echo "✅ Machine ID reset selesai."

#echo "💾 Membuat swapfile 2GB..."
#if ! wget -O swapfile2gb.sh https://raw.githubusercontent.com/IamUcok/inicoy/refs/heads/main/swapfile2gb.sh; then
#    echo "⚠️ Gagal mendownload swapfile. Lanjutkan ke langkah berikutnya."
#else
#    chmod +x swapfile2gb.sh
#    if ! ./swapfile2gb.sh; then
#        echo "⚠️ Gagal membuat swapfile. Lanjutkan ke langkah berikutnya."
#    else
#        echo "✅ Swapfile berhasil dibuat."
#    fi
#fi

#echo "🛡️  Membuka semua koneksi firewall..."
#ufw allow from any to any
#echo "✅ Firewall diatur."

#echo "🗑️ Menghapus konfigurasi auto-upgrade..."
#rm -rf /etc/apt/apt.conf.d/20auto-upgrades
#rm -rf /var/lib/ubuntu-advantage/apt-esm/etc/apt/sources.list.d/ubuntu-esm-apps.sources
#echo "✅ Auto-upgrade config dihapus."

echo "📦 Update dan Upgrade sistem..."
apt autoremove unattended-upgrades -y
apt update
#apt upgrade -y
echo "✅ Update dan upgrade selesai."

echo "📦 Install aplikasi tambahan...python3-pip npm docker.io nodejs "
apt-get install -y ccze curl tcpdump sudo htop net-tools xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils xrdp firefox-esr
echo "✅ Aplikasi tambahan terinstall."

echo "🖥️ Membuat file .xsession untuk XRDP..."
touch .xsession
chmod +x .xsession
echo 'unset DBUS_SESSION_BUS_ADDRESS
unset SESSION_MANAGER
xfce4-session' > .xsession
echo "✅ .xsession disiapkan."

echo "💎 Download dan install UpRock Mining App..."
wget -O uprock.deb https://app-download.uprock.com/UpRock-Mining-v0.0.8.deb
apt install ./uprock.deb -y
echo "✅ UpRock Mining App terinstall."

echo "🛠️ Membuat ulang startwm.sh untuk XRDP..."
rm -f /etc/xrdp/startwm.sh
touch /etc/xrdp/startwm.sh
echo '#!/bin/sh
startxfce4' > /etc/xrdp/startwm.sh
chmod +x /etc/xrdp/startwm.sh
echo "✅ startwm.sh berhasil disiapkan."

#echo "🌐 Download dan install Google Chrome..."
#wget -O google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
#apt install ./google-chrome.deb -y
#echo "✅ Google Chrome terinstall."

#echo "🔌 Install Mysteriumnetwork Node..."
#sudo -E bash -c "$(curl -s https://raw.githubusercontent.com/IamUcok/inicoy/refs/heads/main/mysteriumnetwork.sh)"
#echo "✅ Mysteriumnetwork Node berhasil diinstall."

echo "💎 Download HTOP Config File..."
mkdir /root/.config
mkdir /root/.config/htop
wget -O /root/.config/htop/htoprc https://raw.githubusercontent.com/IamUcok/inicoy/refs/heads/main/htoprc
echo "✅ Download HTOP Config File Selesai."

echo "💎 Recreate Shortcut Uprock..."
rm -rf /usr/share/applications/uprock-mining.desktop
touch /usr/share/applications/uprock-mining.desktop
echo "[Desktop Entry]
Type=Application
Name=UpRock Mining
Exec=nohup uprock-mining > /dev/null 2>&1 &
Icon=uprock-mining
Categories=Utility;Network;
Terminal=false
Version=0.0.8
StartupNotify=false" >> /usr/share/applications/uprock-mining.desktop
echo "✅ Recreate Shortcut Uprock Selesai."

echo "🧹 Membersihkan APT cache Dan File DEB..."
apt remove xfce4-power-manager -y
apt autoremove -y
apt clean
apt autoclean
rm -rf *.deb *.sh
echo "✅ APT cache Dan File DEB dibersihkan."

echo "🎉 Semua proses selesai dengan sukses!"

#echo "🌍 Mengambil IP Publik..."
#ip=$(dig -4 +short +tries=1 +timeout=2 myip.opendns.com @resolver1.opendns.com)
#
#if [ -n "$ip" ]; then
#    echo "✅ Setup selesai! Akses server kamu di: http://${ip}:4449"
#else
#    echo "⚠️  Tidak bisa mendapatkan IP Publik."
#fi
