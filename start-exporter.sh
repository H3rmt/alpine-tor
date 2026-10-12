#!/bin/sh
set -e

echo "Running tor -f $TOR_CONFIG"
tor -f "$TOR_CONFIG" &
tor_pid=$!

cleanup() {
  kill "$tor_pid" 2>/dev/null || true
  kill "$exporter_pid" 2>/dev/null || true
  wait "$tor_pid" 2>/dev/null || true
  wait "$exporter_pid" 2>/dev/null || true
}

trap cleanup INT TERM EXIT

until nc -z 127.0.0.1 "$ControlPort"; do
  if ! kill -0 "$tor_pid" 2>/dev/null; then
    echo "Tor exited before becoming ready"
    exit 1
  fi

  sleep 1
done

python /prometheus-tor-exporter.py \
  -m=tcp \
  -a=127.0.0.1 \
  -c="$ControlPort" \
  -b=0.0.0.0 \
  -p="$PrometheusExporterPort" &
exporter_pid=$!

while kill -0 "$tor_pid" 2>/dev/null && kill -0 "$exporter_pid" 2>/dev/null; do
  sleep 5
done

echo "Tor or exporter exited"
exit 1
