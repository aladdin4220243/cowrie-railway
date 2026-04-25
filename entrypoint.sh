[honeypot]
hostname = svr04
log_path = var/log/cowrie
download_path = var/lib/cowrie/downloads
share_path = share/cowrie
state_path = var/lib/cowrie
etc_path = etc
contents_path = share/cowrie/contents
close_timeout = 30
interactive_timeout = 180

[ssh]
enabled = true
listen_endpoints = tcp:2222:interface=0.0.0.0
version = SSH-2.0-OpenSSH_6.0p1 Debian-4+deb7u2
rsa_public_key = etc/ssh_host_rsa_key.pub
rsa_private_key = etc/ssh_host_rsa_key
public_key_auth = false

[telnet]
enabled = false

[output_jsonlog]
enabled = true
logfile = ${honeypot:log_path}/cowrie.json

[llm]
enabled = false
