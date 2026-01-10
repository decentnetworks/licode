#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/configure-licode.sh \
  --public-ip <ip> \
  --domain <domain> \
  --turn-host <host> \
  --turn-username <user> \
  --turn-password <pass> \
  [--turn-port <port>] \
  [--stun-host <host>] \
  [--stun-port <port>] \
  [--config <path>] \
  [--no-workingnow]

Updates Licode config with public IP, domain, and TURN/STUN settings.
By default it updates licode_config.js and, if present, licode_config.js.workingnow.
USAGE
}

PUBLIC_IP=""
DOMAIN=""
TURN_HOST=""
TURN_PORT="5349"
TURN_USER=""
TURN_PASS=""
STUN_HOST=""
STUN_PORT=""
CONFIG_PATH=""
NO_WORKINGNOW="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --public-ip) PUBLIC_IP="$2"; shift 2 ;;
    --domain) DOMAIN="$2"; shift 2 ;;
    --turn-host) TURN_HOST="$2"; shift 2 ;;
    --turn-port) TURN_PORT="$2"; shift 2 ;;
    --turn-username) TURN_USER="$2"; shift 2 ;;
    --turn-password) TURN_PASS="$2"; shift 2 ;;
    --stun-host) STUN_HOST="$2"; shift 2 ;;
    --stun-port) STUN_PORT="$2"; shift 2 ;;
    --config) CONFIG_PATH="$2"; shift 2 ;;
    --no-workingnow) NO_WORKINGNOW="true"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$PUBLIC_IP" || -z "$DOMAIN" || -z "$TURN_HOST" || -z "$TURN_USER" || -z "$TURN_PASS" ]]; then
  echo "Missing required arguments." >&2
  usage
  exit 1
fi

if [[ -z "$STUN_HOST" ]]; then
  STUN_HOST="$TURN_HOST"
fi
if [[ -z "$STUN_PORT" ]]; then
  STUN_PORT="$TURN_PORT"
fi

if [[ ! "$TURN_PORT" =~ ^[0-9]+$ || ! "$STUN_PORT" =~ ^[0-9]+$ ]]; then
  echo "TURN/STUN ports must be numeric." >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -z "$CONFIG_PATH" ]]; then
  CONFIG_PATH="$ROOT_DIR/licode_config.js"
fi

TARGETS=("$CONFIG_PATH")
WORKINGNOW_PATH="$ROOT_DIR/licode_config.js.workingnow"
if [[ "$NO_WORKINGNOW" == "false" && -f "$WORKINGNOW_PATH" ]]; then
  TARGETS+=("$WORKINGNOW_PATH")
fi

timestamp="$(date +%Y%m%d%H%M%S)"

for cfg in "${TARGETS[@]}"; do
  if [[ ! -f "$cfg" ]]; then
    echo "Config not found: $cfg" >&2
    exit 1
  fi
  cp "$cfg" "${cfg}.bak-${timestamp}"

  python3 - "$PUBLIC_IP" "$DOMAIN" "$STUN_HOST" "$STUN_PORT" "$TURN_HOST" "$TURN_PORT" "$TURN_USER" "$TURN_PASS" "$cfg" <<'PY'
import re
import sys
from pathlib import Path

ip, domain, stun_host, stun_port, turn_host, turn_port, turn_user, turn_pass, path = sys.argv[1:]
text = Path(path).read_text()

def sub(pattern, repl):
    global text
    text, _ = re.subn(pattern, repl, text)

sub(r"(config\.erizoController\.publicIP\s*=\s*)'[^']*'",
    r"\g<1>'{}'".format(ip))
sub(r"(config\.erizoAgent\.publicIP\s*=\s*)'[^']*'",
    r"\g<1>'{}'".format(ip))
sub(r"(config\.erizoController\.hostname\s*=\s*)'[^']*'",
    r"\g<1>'{}'".format(domain))
sub(r"(config\.erizoController\.port\s*=\s*)\d+",
    r"\g<1>443")
sub(r"(config\.erizoController\.ssl\s*=\s*)\w+",
    r"\g<1>true")

sub(r"(config\.erizo\.stunserver\s*=\s*)'[^']*'",
    r"\g<1>'{}'".format(stun_host))
sub(r"(config\.erizo\.stunport\s*=\s*)\d+",
    r"\g<1>{}".format(stun_port))
sub(r"(config\.erizo\.turnserver\s*=\s*)'[^']*'",
    r"\g<1>'{}'".format(turn_host))
sub(r"(config\.erizo\.turnport\s*=\s*)\d+",
    r"\g<1>{}".format(turn_port))
sub(r"(config\.erizo\.turnusername\s*=\s*)'[^']*'",
    r"\g<1>'{}'".format(turn_user))
sub(r"(config\.erizo\.turnpass\s*=\s*)'[^']*'",
    r"\g<1>'{}'".format(turn_pass))

sub(r"(\{'url':\s*'stun:)[^']*('})",
    r"\g<1>{}:{}\2".format(stun_host, stun_port))
sub(r"(\{'url':\s*'turn:)[^']*(')",
    r"\g<1>{}:{}\2".format(turn_host, turn_port))
sub(r"('username'\s*:\s*)'[^']*'",
    r"\g<1>'{}'".format(turn_user))
sub(r"('credential'\s*:\s*)'[^']*'",
    r"\g<1>'{}'".format(turn_pass))

Path(path).write_text(text)
print(f"Updated {path}")
PY
done

echo "Done. Backups created with suffix .bak-${timestamp}."
