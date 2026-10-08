#!/bin/sh
# Accept TCP $PORT only from $ALLOW. Other ports, including SSH, are unchanged.
# Docker published ports are enforced in DOCKER-USER. A local process is enforced in INPUT.

set -eu

ENV_FILE=/etc/node-exporter-firewall.env
if [ ! -r "$ENV_FILE" ]; then
  echo "missing $ENV_FILE" >&2
  exit 1
fi

ALLOW=$(awk -F= '/^ALLOW=/{print substr($0, index($0, "=") + 1)}' "$ENV_FILE")
PORT=$(awk -F= '/^PORT=/{print substr($0, index($0, "=") + 1)}' "$ENV_FILE")

case "$ALLOW" in
  *.*.*) ;;
  *)
    echo "ALLOW must be an IPv4 address" >&2
    exit 1
    ;;
esac
case "$PORT" in
  ''|*[!0-9]*)
    echo "PORT must be numeric" >&2
    exit 1
    ;;
esac

if ! command -v iptables >/dev/null 2>&1; then
  echo "iptables is required so TCP ${PORT} is not left open" >&2
  exit 1
fi

iptables -N NODE_EXPORTER 2>/dev/null || true
iptables -F NODE_EXPORTER
iptables -A NODE_EXPORTER -i lo -p tcp --dport "$PORT" -j RETURN
iptables -A NODE_EXPORTER -p tcp --dport "$PORT" -s "$ALLOW" -j RETURN
iptables -A NODE_EXPORTER -p tcp --dport "$PORT" -j DROP

if ! iptables -C INPUT -j NODE_EXPORTER 2>/dev/null; then
  iptables -I INPUT 1 -j NODE_EXPORTER
fi

iptables -N DOCKER-USER 2>/dev/null || true
if ! iptables -C DOCKER-USER -j NODE_EXPORTER 2>/dev/null; then
  iptables -I DOCKER-USER 1 -j NODE_EXPORTER
fi

if command -v ip6tables >/dev/null 2>&1 && ip6tables -L INPUT >/dev/null 2>&1; then
  if ! ip6tables -C INPUT -p tcp --dport "$PORT" -j DROP 2>/dev/null; then
    ip6tables -I INPUT 1 -p tcp --dport "$PORT" -j DROP
  fi
fi
