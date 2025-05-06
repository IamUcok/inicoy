#!/bin/bash
set -e

# Fungsi error handling
trap 'echo "❌ Error terjadi di baris $LINENO. Cek script atau koneksi internet kamu!"; exit 1' ERR

echo "🔐 Mengganti password root..."
echo "root:Amirin846385!" | chpasswd
echo "✅ Password root berhasil diganti."

echo "🔧 Reset Machine ID..."
echo 'PS1="\u@$(curl -s ifconfig.me):\w\$ "' >> ~/.bashrc && source ~/.bashrc
rm -f /etc/machine-id /var/lib/dbus/machine-id
systemd-machine-id-setup
ln -s /etc/machine-id /var/lib/dbus/machine-id
hostnamectl set-hostname vps-$(tr -dc a-z0-9 </dev/urandom | head -c6)
echo "✅ Machine ID reset selesai."

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

#echo "🛡️  Membuka semua koneksi firewall..."
#ufw allow from any to any
#rm -rf /etc/apt/apt.conf.d/20auto-upgrades
#rm -rf /var/lib/ubuntu-advantage/apt-esm/etc/apt/sources.list.d/ubuntu-esm-apps.sources
#echo "✅ Firewall dibuka dan auto-upgrade dihapus."

echo "📦 Update dan Upgrade sistem..."
apt autoremove unattended-upgrades -y
apt update
#apt upgrade -y
echo "✅ Update dan upgrade selesai."

echo "📦 Install aplikasi penting...python3-pip npm nodejs "
apt-get install -y ccze curl tcpdump sudo htop docker.io net-tools xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils xrdp firefox-esr
echo "✅ Semua aplikasi penting sudah diinstall."

echo "🖥️ Setup session XRDP..."
touch .xsession
chmod +x .xsession
echo 'unset DBUS_SESSION_BUS_ADDRESS
unset SESSION_MANAGER
xfce4-session' > .xsession
echo "✅ Session XRDP berhasil disiapkan."

echo "💎 Install UpRock Mining App..."
wget -O uprock.deb https://app-download.uprock.com/UpRock-Mining-v0.0.8.deb
apt install ./uprock.deb -y
echo "✅ UpRock Mining App berhasil diinstall."

echo "🛠️ Setting startwm.sh untuk XRDP..."
rm -f /etc/xrdp/startwm.sh
touch /etc/xrdp/startwm.sh
echo '#!/bin/sh
startxfce4' > /etc/xrdp/startwm.sh
chmod +x /etc/xrdp/startwm.sh
echo "✅ XRDP startwm.sh selesai diatur."

#echo "🌐 Install Google Chrome..."
#wget -O google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
#apt install ./google-chrome.deb -y
#echo "✅ Google Chrome selesai diinstall."

echo "🐳 Jalankan Docker container: Packetstream..."
docker run -d --restart=always -e CID=6XLM --name Packetstream packetstream/psclient:latest
echo "✅ Docker Packetstream berjalan."

echo "🐳 Jalankan Docker container: Repocket..."
docker run --name Repocket -e RP_EMAIL=iamspa@gmail.com -e RP_API_KEY=dfb2468d-bc6d-4474-a5cd-eb2b0a876a93 -d --restart=always repocket/repocket
echo "✅ Docker Repocket berjalan."

#echo "🔌 Install Mysteriumnetwork Node..."
#sudo -E bash -c "$(curl -s https://raw.githubusercontent.com/IamUcok/inicoy/refs/heads/main/mysteriumnetwork.sh)"
#echo "✅ Mysteriumnetwork Node berhasil diinstall."

echo "💎 Download HTOP Config File..."
mkdir /root/.config
mkdir /root/.config/htop
wget -O /root/.config/htop/htoprc https://raw.githubusercontent.com/IamUcok/inicoy/refs/heads/main/htoprc
echo "✅ Download HTOP Config File Selesai."

echo "🧹 Membersihkan APT cache Dan File DEB..."
apt remove xfce4-power-manager -y
apt autoremove -y
apt clean
apt autoclean
rm -rf *.deb *.sh
echo "✅ APT cache Dan File DEB dibersihkan."

#echo "🌍 Mengambil IP Publik..."
#ip=$(dig -4 +short +tries=1 +timeout=2 myip.opendns.com @resolver1.opendns.com)

#if [ -n "$ip" ]; then
#    echo "✅ Setup selesai! Akses server kamu di: http://${ip}:4449"
#else
#    echo "⚠️  Tidak bisa mendapatkan IP Publik."
#fi

echo "🐳 Jalankan Docker container: Traffmonetizer..."
docker run -i --name Traffmonetizer --restart=always traffmonetizer/cli_v2:latest start accept --token f9kaSMNVm5vuSVSXVwgN8YXPjNLiiSEmBy9Ro2PICms=

