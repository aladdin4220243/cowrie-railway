#!/bin/bash
set -e

echo "==> Starting Cowrie SSH honeypot on port 2222..."
cd /cowrie

# Generate RSA key if not present
if [ ! -f etc/ssh_host_rsa_key ]; then
    ssh-keygen -t rsa -b 2048 -f etc/ssh_host_rsa_key -N "" -q
    echo "==> RSA key generated"
fi

# Start Cowrie correctly (bin/cowrie is a shell script, not Python)
bin/cowrie start
echo "==> Cowrie started"

sleep 8

echo "==> Starting forwarder → ${INGESTION_URL:-NOT_SET}"
python /cowrie/forwarder.py &

# Keep container alive
tail -f var/log/cowrie/cowrie.json
