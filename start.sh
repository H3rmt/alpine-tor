#!/bin/sh
set -e

echo "Running tor -f /etc/tor/torrc"
exec tor -f /etc/tor/torrc
