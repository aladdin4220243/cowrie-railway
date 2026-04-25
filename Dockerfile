FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    git libssl-dev libffi-dev build-essential openssh-client \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/cowrie/cowrie.git /cowrie
WORKDIR /cowrie

RUN pip install --no-cache-dir -e . && \
    pip install --no-cache-dir requests

# إنشاء الـ fake filesystem
RUN mkdir -p /cowrie/share/cowrie/contents/etc && \
    cp -r honeyfs/* /cowrie/share/cowrie/contents/ 2>/dev/null || true

# تسجيل الـ twisted plugin يدوياً
RUN cp src/twisted/plugins/cowrie_plugin.py \
    /usr/local/lib/python3.11/site-packages/twisted/plugins/

RUN mkdir -p /cowrie/etc /cowrie/var/log/cowrie /cowrie/var/lib/cowrie/downloads

COPY cowrie.cfg    /cowrie/etc/cowrie.cfg
COPY forwarder.py  /cowrie/forwarder.py
COPY entrypoint.sh /entrypoint.sh

RUN useradd -m cowrie && \
    chown -R cowrie:cowrie /cowrie && \
    chmod +x /entrypoint.sh

USER cowrie

EXPOSE 2222
ENTRYPOINT ["/entrypoint.sh"]
