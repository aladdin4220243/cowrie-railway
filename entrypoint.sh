#!/bin/bash
set -e

cd /cowrie

echo "==> Starting Cowrie..."

mkdir -p etc var/log/cowrie var/lib/cowrie/downloads

if [ ! -f etc/ssh_host_rsa_key ]; then
    ssh-keygen -t rsa -b 2048 -f etc/ssh_host_rsa_key -N "" -q
    echo "==> RSA key generated"
fi

chmod 600 etc/ssh_host_rsa_key

echo "==> Starting forwarder..."
python /cowrie/forwarder.py &

twistd -n --pidfile= --rundir=/cowrie cowrie
