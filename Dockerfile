FROM cowrie/cowrie:latest

USER root

# Install Python requests for the forwarder
RUN pip install --no-cache-dir requests

# Copy our forwarder and config
COPY forwarder.py   /cowrie/forwarder.py
COPY cowrie.cfg     /cowrie/etc/cowrie.cfg
COPY entrypoint.sh  /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Cowrie SSH honeypot on 2222
EXPOSE 2222

ENTRYPOINT ["/entrypoint.sh"]
