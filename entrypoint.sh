#!/bin/bash
set -e

echo "==> Starting Cowrie SSH honeypot on port 2222..."
cd /cowrie

# Generate RSA key only (DSA not supported in newer OpenSSH)
if [ ! -f etc/ssh_host_rsa_key ]; then
    ssh-keygen -t rsa -b 2048 -f etc/ssh_host_rsa_key -N "" -q
    echo "==> RSA key generated"
fi

# Start Cowrie using twistd
twistd -n --pidfile= -y bin/cowrie.tac &
COWRIE_PID=$!
echo "==> Cowrie started (PID $COWRIE_PID)"

echo "==> Waiting 5s..."
sleep 5

echo "==> Starting forwarder → ${INGESTION_URL:-NOT_SET}"
python /cowrie/forwarder.py &
FORWARDER_PID=$!

echo "==> Both running. Cowrie=$COWRIE_PID Forwarder=$FORWARDER_PID"
wait -n
exit 1
