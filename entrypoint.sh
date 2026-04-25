#!/bin/bash
set -e

cd /cowrie

echo "==> Starting Cowrie..."

# توليد مفتاح RSA إذا لم يكن موجودًا
if [ ! -f etc/ssh_host_rsa_key ]; then
    ssh-keygen -t rsa -b 2048 -f etc/ssh_host_rsa_key -N "" -q
    echo "==> RSA key generated"
fi

# تشغيل Cowrie باستخدام twistd مباشرة
twistd -n --pidfile= --rundir=/cowrie cowrie

# forwarder.py سيعمل في الخلفية
# python /cowrie/forwarder.py & (إذا أردت تفعيله لاحقًا)
