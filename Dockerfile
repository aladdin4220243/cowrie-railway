FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    git libssl-dev libffi-dev build-essential openssh-client \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/cowrie/cowrie.git /cowrie
WORKDIR /cowrie

RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir requests

RUN ssh-keygen -t rsa -b 2048 -f /cowrie/etc/ssh_host_rsa_key -N "" -q && \
    ssh-keygen -t dsa -f /cowrie/etc/ssh_host_dsa_key -N "" -q

COPY cowrie.cfg    /cowrie/etc/cowrie.cfg
COPY forwarder.py  /cowrie/forwarder.py
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && \
    mkdir -p /cowrie/var/log/cowrie /cowrie/var/lib/cowrie/downloads

EXPOSE 2222

ENTRYPOINT ["/entrypoint.sh"]
