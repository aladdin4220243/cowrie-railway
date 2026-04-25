FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    git libssl-dev libffi-dev build-essential openssh-client \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/cowrie/cowrie.git /cowrie
WORKDIR /cowrie

RUN pip install --no-cache-dir -e . && \
    pip install --no-cache-dir requests

RUN mkdir -p /cowrie/etc /cowrie/var/log/cowrie /cowrie/var/lib/cowrie/downloads

COPY cowrie.cfg    /cowrie/etc/cowrie.cfg
COPY forwarder.py  /cowrie/forwarder.py
COPY entrypoint.sh /entrypoint.sh

# إنشاء user غير root
RUN useradd -m cowrie && \
    chown -R cowrie:cowrie /cowrie && \
    chmod +x /entrypoint.sh

USER cowrie

EXPOSE 2222
ENTRYPOINT ["/entrypoint.sh"]
