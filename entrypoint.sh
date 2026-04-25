#!/bin/bash
set -e

cd /cowrie

echo "==> Starting Cowrie..."

echo "==> Starting forwarder..."
python /cowrie/forwarder.py &

twistd -n --pidfile= --rundir=/cowrie cowrie
