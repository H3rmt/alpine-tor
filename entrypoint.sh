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

torrc_path=/etc/tor/torrc
if [ "$(id -u)" -ne 0 ] && [ ! -f "$torrc_path" ]; then
  torrc_path=/tmp/torrc
fi

generate_tor_config() {
  rm -f "$torrc_path"
  echo "Log notice stdout" >> "$torrc_path"
  echo "DataDirectory /var/lib/tor" >> "$torrc_path"

  echo "ContactInfo $ContactInfo" >> "$torrc_path"
  echo "Nickname $Nickname" >> "$torrc_path"

  echo "Searching for environment variable 'mode'"
  # Set required values depending on set mode
  if [ "$mode" = "exit" ]
  then
    echo "Starting up as exit node (not tested...)"

    echo "ORPort $ORPort" >> "$torrc_path"
    echo "ExitRelay 1" >> "$torrc_path"
    echo "SocksPort 0" >> "$torrc_path"
    echo "DirPort $DirPort" >> "$torrc_path"
  elif [ "$mode" = "middle" ]
  then
    echo "Starting up as middle / guard node"

    echo "ORPort $ORPort" >> "$torrc_path"
    echo "ExitRelay 0" >> "$torrc_path"
    echo "SocksPort 0" >> "$torrc_path"
    echo "DirPort $DirPort" >> "$torrc_path"
  elif [ "$mode" = "bridge" ]
  then
    echo "Starting up as bridge node"

    echo "ORPort $ORPort" >> "$torrc_path"
    echo "BridgeRelay 1" >> "$torrc_path"
    echo "ExtORPort auto" >> "$torrc_path"
    echo "ServerTransportListenAddr obfs4 0.0.0.0:$PTPort" >> "$torrc_path"
    echo "ServerTransportPlugin obfs4 exec /usr/bin/lyrebird" >> "$torrc_path"
  elif [ "$mode" = "proxy" ]
  then
    echo "Starting up as proxy"

    echo "SOCKSPort 0.0.0.0:$SOCKSPort" >> "$torrc_path"
  else
    echo "No valid mode set. Please refer to the Readme.md on how to run. Exiting."
    exit 1
  fi
  # Additional optional values
  if [ -n "$DNSPort" ]; then
    echo "DNSPort $DNSPort" >> "$torrc_path"
  fi
  if [ -n "$MyFamily" ]; then
    echo "MyFamily $MyFamily" >> "$torrc_path"
  fi
  if [ -n "$HiddenServiceDir" ]; then
    echo "HiddenServiceDir $HiddenServiceDir" >> "$torrc_path"
  fi
  if [ -n "$HiddenServicePort" ]; then
    echo "HiddenServicePort $HiddenServicePort" >> "$torrc_path"
  fi
  if [ -n "$ExitNodes" ]; then
    echo "ExitNodes $ExitNodes" >> "$torrc_path"
  fi
  if [ -n "$AccountingMax" ]; then
    echo "AccountingMax $AccountingMax" >> "$torrc_path"
  fi
  if [ -n "$AccountingStart" ]; then
    echo "AccountingStart $AccountingStart" >> "$torrc_path"
  fi
  if [ -n "$MaxAdvertisedBandwidth" ]; then
    echo "MaxAdvertisedBandwidth $MaxAdvertisedBandwidth" >> "$torrc_path"
  fi
  if [ -n "$RelayBandwidthRate" ]; then
    echo "RelayBandwidthRate $RelayBandwidthRate" >> "$torrc_path"
  fi
  if [ -n "$RelayBandwidthBurst" ]; then
    echo "RelayBandwidthBurst $RelayBandwidthBurst" >> "$torrc_path"
  fi
  if [ -n "$MetricsPort" ]; then
    echo "MetricsPort 0.0.0.0:$MetricsPort" >> "$torrc_path"
  fi
  if [ -n "$MetricsPortPolicy" ]; then
    echo "MetricsPortPolicy $MetricsPortPolicy" >> "$torrc_path"
  fi
  if [ -n "$ControlPort" ]; then
    echo "ControlPort $ControlPort" >> "$torrc_path"
  fi
}

if [ -f "$torrc_path" ]; then
  echo "Using existing /etc/tor/torrc"
else
  generate_tor_config
fi

export TOR_CONFIG="$torrc_path"

# When the container is started as a non-root user (for example with Podman
# and --user UID:GID), that user already owns the bind-mounted directories.
# Keep that identity instead of attempting to switch to the image's tor user.
if [ "$(id -u)" -eq 0 ]; then
  # Docker starts the entrypoint as root and then drops to the image's tor
  # user. Set ownership and restrict access before dropping privileges.
  chown -R tor:tor /var/lib/tor /var/log/tor
  chmod -R u+rwX,go-rwx /var/lib/tor /var/log/tor
  exec setpriv --reuid=tor --regid=tor --init-groups "$@"
fi

# With Podman --user UID:GID, the bind mounts are already owned by the
# supplied user. Restrict access without attempting a chown as non-root.
chmod -R u+rwX,go-rwx /var/lib/tor /var/log/tor
exec "$@"
