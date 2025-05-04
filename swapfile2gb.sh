#!/bin/bash

SWAP1="/swapfile"
SWAP2="/swapfile2"
TARGET_MB=4096

# Hitung total swap aktif saat ini
TOTAL_MB=$(swapon --show=SIZE --noheadings | awk '{sum+=$1} END {print int(sum)}')

if [ "$TOTAL_MB" -lt "$TARGET_MB" ]; then
    ADD_MB=$((TARGET_MB - TOTAL_MB))
    echo "Total swap cuma ${TOTAL_MB}MB. Menambah ${ADD_MB}MB ke $SWAP2..."
    
    sudo fallocate -l "${ADD_MB}M" "$SWAP2"
    sudo chmod 600 "$SWAP2"
    sudo mkswap "$SWAP2"
    sudo swapon "$SWAP2"
    
    # Tambahkan ke /etc/fstab kalau belum ada
    if ! grep -q "$SWAP2" /etc/fstab; then
        echo "$SWAP2 none swap sw 0 0" | sudo tee -a /etc/fstab
    fi

    echo "Swap tambahan ${ADD_MB}MB ditambahkan."
else
    echo "Total swap sudah ${TOTAL_MB}MB atau lebih. Tidak perlu tambah."
fi
