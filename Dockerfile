#!/bin/bash
set -e

echo "==> Starting Cowrie SSH honeypot on port 2222..."
cd /cowrie

# Start Cowrie using twistd directly
twistd -n --pidfile= -y bin/cowrie.tac &
COWRIE_PID=$!
echo "==> Cowrie started (PID $COWRIE_PID)"

echo "==> Waiting 5s for Cowrie to initialise..."
sleep 5

echo "==> Starting forwarder → ${INGESTION_URL:-NOT_SET}"
python /cowrie/forwarder.py &
FORWARDER_PID=$!

echo "==> Both running. Cowrie=$COWRIE_PID Forwarder=$FORWARDER_PID"

wait -n
echo "==> A process exited. Restarting container..."
exit 1
