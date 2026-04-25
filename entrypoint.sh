#!/bin/bash
set -e

echo "==> Starting Cowrie SSH honeypot on port 2222..."
cd /cowrie

# Generate RSA key if not present
if [ ! -f etc/ssh_host_rsa_key ]; then
    ssh-keygen -t rsa -b 2048 -f etc/ssh_host_rsa_key -N "" -q
    echo "==> RSA key generated"
fi

# Start Cowrie using the correct method
python bin/cowrie start
echo "==> Cowrie started"

echo "==> Waiting 8s for Cowrie to initialise..."
sleep 8

echo "==> Starting forwarder → ${INGESTION_URL:-NOT_SET}"
python /cowrie/forwarder.py &
FORWARDER_PID=$!
echo "==> Forwarder started (PID $FORWARDER_PID)"

# Keep container alive — tail the Cowrie log
tail -f var/log/cowrie/cowrie.json &

# Wait for forwarder to exit (shouldn't happen)
wait $FORWARDER_PID
