#!/bin/bash
set -e

cd /cowrie

echo "==> Starting Cowrie..."

# توليد مفتاح RSA في المكان الصحيح
if [ ! -f etc/ssh_host_rsa_key ]; then
    mkdir -p etc
    ssh-keygen -t rsa -b 2048 -f etc/ssh_host_rsa_key -N "" -q
    echo "==> RSA key generated at etc/ssh_host_rsa_key"
else
    echo "==> RSA key already exists"
fi

# التحقق من وجود المفاتيح
ls -la etc/*.key 2>/dev/null || echo "WARNING: No keys found!"

# تشغيل Cowrie
twistd -n --pidfile= --rundir=/cowrie cowrie
