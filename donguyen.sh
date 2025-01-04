#!/bin/bash
echo "SCRIPT AUTO INSTALL WINDOWS by HIDESSH"
echo
echo "Pilih OS yang ingin anda install"
echo "[1] Windows 2019(Default)"
echo "[2] Windows 2016"
echo "[3] Windows 2012"
echo "[4] Windows 10"
echo "[5] Chat Ryan Untuk Add OS lain"

read -p "Pilih [1]: " PILIHOS

case "$PILIHOS" in
    1|"") PILIHOS="http://drive.muavps.net/file/Windows2019.img";;
    2) PILIHOS="https://file.nixpoin.com/windows2016.gz";;
    3) PILIHOS="https://file.nixpoin.com/windows2012v2.gz";;
    4) PILIHOS="https://file.nixpoin.com/win10.gz";;
    5) read -p "[?] Masukkan Link GZ mu : " PILIHOS;;
    *) echo "[!] Pilihan salah"; exit;;
esac

echo "[*] Password yang saya buat sudah masuk wordlist bruteforce, silahkan masukkan password yang lebih aman!"
read -p "[?] Masukkan password untuk akun Administrator Rdp anda(minimal 12 karakter) : " PASSADMIN

IP4=$(curl -4 -s icanhazip.com)
GW=$(ip route | awk '/default/ { print $3 }')

# (Lanjutkan dengan script yang sama seperti sebelumnya dengan perbaikan di atas)
