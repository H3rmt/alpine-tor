#!/bin/sh
set -e

echo "Running tor -f $TOR_CONFIG"
exec tor -f "$TOR_CONFIG"
