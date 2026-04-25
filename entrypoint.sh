#!/bin/bash
set -e

echo "==> Starting Cowrie SSH honeypot on port 2222..."
cd /cowrie
bin/cowrie start

echo "==> Waiting 5s for Cowrie to initialise..."
sleep 5

echo "==> Starting forwarder → ${INGESTION_URL}"
exec python /cowrie/forwarder.py
