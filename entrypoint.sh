#!/bin/bash
set -e

echo "==> Starting Cowrie..."
cd /cowrie

if [ ! -f etc/ssh_host_rsa_key ]; then
    ssh-keygen -t rsa -b 2048 -f etc/ssh_host_rsa_key -N "" -q
    echo "==> RSA key generated"
fi

# تشغيل twistd مباشرة بدل cowrie start
twistd -n --pidfile= cowrie &
COWRIE_PID=$!
echo "==> Cowrie started (PID $COWRIE_PID)"

sleep 8

echo "==> Starting forwarder → ${INGESTION_URL:-NOT_SET}"
python /cowrie/forwarder.py &

wait $COWRIE_PID
