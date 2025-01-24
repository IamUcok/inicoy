rm -rf iniminer-linux-x64  restart_iniminer.sh && \
wget https://github.com/Project-InitVerse/ini-miner/releases/download/v1.0.0/iniminer-linux-x64 && chmod +x iniminer-linux-x64 && touch inichain.sh && chmod +x inichain.sh && \
echo '#!/bin/bash

# Path to the executable and its arguments
./iniminer-linux-x64 --pool stratum+tcp://0xde1d9fd7ff6fccf6179244ee238954e2c7dfbf10.github@pool-a.yatespool.com:31588 --cpu-devices 1 --cpu-devices 2
 
# Infinite loop to restart the process if it terminates
while true; do
    echo "Starting iniminer..."
./iniminer-linux-x64 --pool stratum+tcp://0xde1d9fd7ff6fccf6179244ee238954e2c7dfbf10.github@pool-a.yatespool.com:31588 --cpu-devices 1 --cpu-devices 2
    echo "Process terminated. Restarting in 5 seconds..."
    sleep 5
done' > inichain.sh && \
echo './inichain.sh' >> .bashrc && \
./inichain.sh
