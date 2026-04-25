#!/bin/bash
set -e

echo "==> Starting Cowrie SSH honeypot on port 2222..."
cd /cowrie

# Generate SSH keys if not present
if [ ! -f etc/ssh_host_rsa_key ]; then
    ssh-keygen -t rsa -b 2048 -f etc/ssh_host_rsa_key -N "" -q
fi
if [ ! -f etc/ssh_host_dsa_key ]; then
    ssh-keygen -t dsa -f etc/ssh_host_dsa_key -N "" -q
fi

# Start Cowrie in background
python -m twisted.scripts.twistd -n -y bin/cowrie.tac \
    --pidfile /cowrie/var/run/cowrie.pid \
    --logfile /cowrie/var/log/cowrie/twistd.log &

COWRIE_PID=$!
echo "==> Cowrie started (PID $COWRIE_PID)"

echo "==> Waiting 5s for Cowrie to initialise..."
sleep 5

echo "==> Starting forwarder → ${INGESTION_URL:-NOT_SET}"
python /cowrie/forwarder.py &
FORWARDER_PID=$!

echo "==> Both running. Cowrie=$COWRIE_PID Forwarder=$FORWARDER_PID"

# Exit if either dies (Railway will restart)
wait -n
echo "==> A process exited. Restarting container..."
exit 1
