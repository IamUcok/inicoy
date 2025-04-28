#!/bin/bash
set -e

# Fungsi error handling
trap 'echo "❌ Error terjadi di baris $LINENO. Cek script atau koneksi internet kamu!"; exit 1' ERR

echo "🔧 Reset Machine ID..."
sudo rm -f /etc/machine-id /var/lib/dbus/machine-id
sudo systemd-machine-id-setup
sudo ln -s /etc/machine-id /var/lib/dbus/machine-id
echo "✅ Machine ID reset selesai."

echo "🔧 Setup swapfile..."
wget https://raw.githubusercontent.com/IamUcok/inicoy/refs/heads/main/swapfile2gb.sh
chmod +x swapfile2gb.sh
./swapfile2gb.sh
echo "✅ Swapfile selesai dibuat."

echo "🛡️  Setting firewall dan hapus auto-upgrade..."
ufw allow from any to any
rm -rf /etc/apt/apt.conf.d/20auto-upgrades
rm -rf /var/lib/ubuntu-advantage/apt-esm/etc/apt/sources.list.d/ubuntu-esm-apps.sources
echo "✅ Firewall dibuka dan auto-upgrade dihapus."

echo "📦 Update dan Upgrade System..."
apt update
apt upgrade -y
echo "✅ System update dan upgrade selesai."

echo "📦 Install aplikasi penting..."
apt-get install -y ccze curl tcpdump python3-pip htop nodejs npm net-tools docker.io xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils xrdp
apt autoremove -y
echo "✅ Semua aplikasi penting sudah diinstall."

echo "🖥️ Setup session XRDP..."
touch .xsession
chmod +x .xsession
echo 'unset DBUS_SESSION_BUS_ADDRESS
unset SESSION_MANAGER
xfce4-session' > .xsession
echo "✅ Session XRDP berhasil disiapkan."

echo "💎 Install UpRock Mining App..."
wget https://edge.uprock.com/v1/app-download/UpRock-Mining-v0.0.9.deb
apt install ./UpRock-Mining-v0.0.9.deb -y
echo "✅ UpRock Mining App berhasil diinstall."

echo "🛠️ Setting startwm.sh untuk XRDP..."
rm -rf /etc/xrdp/startwm.sh
touch /etc/xrdp/startwm.sh
echo '#!/bin/sh
startxfce4' > /etc/xrdp/startwm.sh
chmod +x /etc/xrdp/startwm.sh
echo "✅ XRDP startwm.sh selesai diatur."

echo "🌐 Install Google Chrome..."
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt install ./google-chrome-stable_current_amd64.deb -y
echo "✅ Google Chrome selesai diinstall."

echo "🐳 Jalankan Docker container: Packetstream..."
docker run -d --restart=always -e CID=6XLM --name Packetstream packetstream/psclient:latest
echo "✅ Docker Packetstream berjalan."

echo "🐳 Jalankan Docker container: Repocket..."
docker run --name Repocket -e RP_EMAIL=iamspa@gmail.com -e RP_API_KEY=dfb2468d-bc6d-4474-a5cd-eb2b0a876a93 -d --restart=always repocket/repocket
echo "✅ Docker Repocket berjalan."

echo "🐳 Jalankan Docker container: Traffmonetizer..."
docker run -i --name Traffmonetizer --restart=always traffmonetizer/cli_v2:latest start accept --token f9kaSMNVm5vuSVSXVwgN8YXPjNLiiSEmBy9Ro2PICms=
echo "✅ Docker Traffmonetizer berjalan."

echo "🔌 Install Mysteriumnetwork Node..."
sudo -E bash -c "$(curl -s https://raw.githubusercontent.com/IamUcok/inicoy/refs/heads/main/mysteriumnetwork.sh)"
echo "✅ Mysteriumnetwork Node berhasil diinstall."

echo "🧹 Bersihkan APT cache..."
apt clean
apt autoclean
echo "✅ APT cache dibersihkan."

echo "🌍 Mengambil IP Publik..."
ip=$(dig -4 +short +tries=1 +timeout=2 myip.opendns.com @resolver1.opendns.com)

if [ -n "$ip" ]; then
    echo "✅ Setup selesai! Akses server kamu di: http://${ip}:4449"
else
    echo "⚠️  Tidak bisa mendapatkan IP Publik."
fi

echo "🎉 Semua proses selesai tanpa error!"
