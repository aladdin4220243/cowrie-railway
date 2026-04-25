"""
forwarder.py — Tails Cowrie's cowrie.json and POSTs each event
to the Ingestion API.

Required env vars:
  INGESTION_URL   e.g. https://ingestion-production-c968.up.railway.app
  HMAC_SECRET     shared secret (must match Ingestion service)

Optional:
  POLL_INTERVAL   seconds between polls (default: 1.0)
  LOG_FILE        path to cowrie JSON log (default: /cowrie/var/log/cowrie/cowrie.json)
"""

import os, json, time, hmac, hashlib, logging, requests
from pathlib import Path

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [forwarder] %(message)s",
)
log = logging.getLogger(__name__)

INGESTION_URL  = os.environ.get("INGESTION_URL", "").rstrip("/")
HMAC_SECRET    = os.environ.get("HMAC_SECRET", "dev_secret").encode()
POLL_INTERVAL  = float(os.environ.get("POLL_INTERVAL", "1.0"))
LOG_FILE       = os.environ.get("LOG_FILE", "/cowrie/var/log/cowrie/cowrie.json")
ENDPOINT       = f"{INGESTION_URL}/ingest/event"

if not INGESTION_URL:
    raise RuntimeError("INGESTION_URL env var is not set")

log.info("Forwarding to: %s", ENDPOINT)


def sign(body: bytes) -> str:
    return "sha256=" + hmac.new(HMAC_SECRET, body, hashlib.sha256).hexdigest()


# Map Cowrie eventid → Ingestion type
EVENT_MAP = {
    "cowrie.login.failed":          "authentication_failed",
    "cowrie.login.success":         "authentication_success",
    "cowrie.session.connect":       "connection_new",
    "cowrie.session.closed":        "connection_closed",
    "cowrie.command.input":         "command_input",
    "cowrie.command.failed":        "command_failed",
    "cowrie.session.file_download": "file_download",
    "cowrie.session.file_upload":   "file_upload",
}


def send(raw_line: str) -> None:
    try:
        ev = json.loads(raw_line.strip())
    except json.JSONDecodeError:
        return

    eventid = ev.get("eventid", "")
    if not eventid:
        return  # skip non-event lines

    payload = {
        "type":       EVENT_MAP.get(eventid, eventid),
        "source_ip":  ev.get("src_ip", ""),
        "username":   ev.get("username", ""),
        "password":   ev.get("password", ""),
        "session":    ev.get("session", ""),
        "sensor":     ev.get("sensor", "cowrie-railway"),
        "timestamp":  ev.get("timestamp", ""),
        "protocol":   "ssh",
        "command":    ev.get("input", ""),
    }

    body = json.dumps(payload).encode()
    headers = {
        "Content-Type":     "application/json",
        "X-HMAC-Signature": sign(body),
        "X-HMAC-Timestamp": str(int(time.time())),
    }

    try:
        r = requests.post(ENDPOINT, data=body, headers=headers, timeout=5)
        r.raise_for_status()
        log.info("sent %-30s ← %s", payload["type"], payload.get("source_ip"))
    except requests.RequestException as e:
        log.warning("send failed: %s", e)


def tail():
    path = Path(LOG_FILE)
    log.info("Waiting for log file: %s", LOG_FILE)

    while not path.exists():
        time.sleep(2)

    log.info("Tailing %s", LOG_FILE)
    with open(path) as f:
        f.seek(0, 2)                          # seek to end
        last_ino = path.stat().st_ino

        while True:
            line = f.readline()
            if line:
                send(line)
                continue

            time.sleep(POLL_INTERVAL)

            try:
                cur_ino = path.stat().st_ino
                if cur_ino != last_ino:       # log rotation
                    log.info("Log rotated, reopening")
                    f = open(path)
                    last_ino = cur_ino
            except FileNotFoundError:
                log.warning("Log file gone, waiting...")
                while not path.exists():
                    time.sleep(2)
                f = open(path)
                last_ino = path.stat().st_ino


if __name__ == "__main__":
    tail()
