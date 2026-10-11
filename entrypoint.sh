#!/bin/sh
set -e

printf '%s\n' 'Starting h3rmt/alpine-tor'
printf 'Alpine version: %s\n' "$(cat /etc/alpine-release)"

# Report the executable version at startup so the image's actual installed
# Tor version is visible in container logs (including for the exporter image).
tor_version=$(tor --version | awk 'NR == 1 { print $3 }' | sed 's/[.]$//')
printf 'Tor version: %s\n' "$tor_version"
printf 'Lyrebird version: '
lyrebird -version

generate_tor_config() {
  rm -f /etc/tor/torrc
  echo "Log notice stdout" >> /etc/tor/torrc
  echo "Log notice file /var/log/tor/log" >> /etc/tor/torrc
  echo "DataDirectory /var/lib/tor" >> /etc/tor/torrc

  echo "ContactInfo $ContactInfo" >> /etc/tor/torrc
  echo "Nickname $Nickname" >> /etc/tor/torrc

  echo "Searching for environment variable 'mode'"
  # Set required values depending on set mode
  if [ "$mode" = "exit" ]
  then
    echo "Starting up as exit node (not tested...)"

    echo "ORPort $ORPort" >> /etc/tor/torrc
    echo "ExitRelay 1" >> /etc/tor/torrc
    echo "SocksPort 0" >> /etc/tor/torrc
    echo "DirPort $DirPort" >> /etc/tor/torrc
  elif [ "$mode" = "middle" ]
  then
    echo "Starting up as middle / guard node"

    echo "ORPort $ORPort" >> /etc/tor/torrc
    echo "ExitRelay 0" >> /etc/tor/torrc
    echo "SocksPort 0" >> /etc/tor/torrc
    echo "DirPort $DirPort" >> /etc/tor/torrc
  elif [ "$mode" = "bridge" ]
  then
    echo "Starting up as bridge node"

    echo "ORPort $ORPort" >> /etc/tor/torrc
    echo "BridgeRelay 1" >> /etc/tor/torrc
    echo "ExtORPort auto" >> /etc/tor/torrc
    echo "ServerTransportListenAddr obfs4 0.0.0.0:$PTPort" >> /etc/tor/torrc
    echo "ServerTransportPlugin obfs4 exec /usr/bin/lyrebird" >> /etc/tor/torrc
  elif [ "$mode" = "proxy" ]
  then
    echo "Starting up as proxy"

    echo "SOCKSPort 0.0.0.0:$SOCKSPort" >> /etc/tor/torrc
  else
    echo "No valid mode set. Please refer to the Readme.md on how to run. Exiting."
    exit 1
  fi
  # Additional optional values
  if [ -n "$DNSPort" ]; then
    echo "DNSPort $DNSPort" >> /etc/tor/torrc
  fi
  if [ -n "$MyFamily" ]; then
    echo "MyFamily $MyFamily" >> /etc/tor/torrc
  fi
  if [ -n "$HiddenServiceDir" ]; then
    echo "HiddenServiceDir $HiddenServiceDir" >> /etc/tor/torrc
  fi
  if [ -n "$HiddenServicePort" ]; then
    echo "HiddenServicePort $HiddenServicePort" >> /etc/tor/torrc
  fi
  if [ -n "$ExitNodes" ]; then
    echo "ExitNodes $ExitNodes" >> /etc/tor/torrc
  fi
  if [ -n "$AccountingMax" ]; then
    echo "AccountingMax $AccountingMax" >> /etc/tor/torrc
  fi
  if [ -n "$AccountingStart" ]; then
    echo "AccountingStart $AccountingStart" >> /etc/tor/torrc
  fi
  if [ -n "$MaxAdvertisedBandwidth" ]; then
    echo "MaxAdvertisedBandwidth $MaxAdvertisedBandwidth" >> /etc/tor/torrc
  fi
  if [ -n "$RelayBandwidthRate" ]; then
    echo "RelayBandwidthRate $RelayBandwidthRate" >> /etc/tor/torrc
  fi
  if [ -n "$RelayBandwidthBurst" ]; then
    echo "RelayBandwidthBurst $RelayBandwidthBurst" >> /etc/tor/torrc
  fi
  if [ -n "$MetricsPort" ]; then
    echo "MetricsPort 0.0.0.0:$MetricsPort" >> /etc/tor/torrc
  fi
  if [ -n "$MetricsPortPolicy" ]; then
    echo "MetricsPortPolicy $MetricsPortPolicy" >> /etc/tor/torrc
  fi
  if [ -n "$ControlPort" ]; then
    echo "ControlPort $ControlPort" >> /etc/tor/torrc
  fi
}

if [ -f /etc/tor/torrc ]; then
  echo "Using existing /etc/tor/torrc"
else
  generate_tor_config
fi

# Bind-mounted data directories are commonly owned by root on the host. Make
# them writable by Tor before dropping privileges.
chown -R tor:tor /var/lib/tor /var/log/tor

exec setpriv --reuid=tor --regid=tor --init-groups "$@"
