 #!/bin/sh
echo "Running h3rmt/alpine-tor"
echo -e "Alpine Version: \c" && cat /etc/alpine-release
echo -e "Tor Version: \c" && tor --version
echo -e "OBFS4Proxy Version: \c" && obfs4proxy -version

echo "ContactInfo $ContactInfo" >> /etc/tor/torrc
echo "Nickname $Nickname" >> /etc/tor/torrc

echo "Searching for environment variable 'mode'"
# Set required values depending on set mode
if [ "$mode" = "exit" ]
then
   echo "Starting up as exit node"

   echo "ExitRelay 1" >> /etc/tor/torrc
   echo "DirPort $DirPort" >> /etc/tor/torrc
   # echo "DirPortFrontPage /path/to/html/file" >> /etc/tor/torrc
elif [ "$mode" = "middle" ]
then
   echo "Starting up as middle / guard node"

   echo "ORPort $ORPort" >> /etc/tor/torrc
   echo "ExitRelay 0" >> /etc/tor/torrc
   echo "SocksPort 0" >> /etc/tor/torrc
   echo "ControlSocket 0" >> /etc/tor/torrc
elif [ "$mode" = "bridge" ]
then
  echo "Starting up as bridge node"

  echo "ORPort $ORPort" >> /etc/tor/torrc
  echo "BridgeRelay 1" >> /etc/tor/torrc
  echo "ServerTransportListenAddr obfs4 0.0.0.0:$PTPort" >> /etc/tor/torrc
  echo "ServerTransportPlugin obfs4 exec /usr/local/bin/obfs4proxy" >> /etc/tor/torrc
elif [ "$mode" = "proxy" ]
then
  echo "Starting up as proxy"

  echo "SOCKSPort 0.0.0.0:$SOCKSPort" >> /etc/tor/torrc
else
   echo "No mode set. Please refer to the Readme.md on how to run. Exiting."
   exit;
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
  echo "MetricsPort $MetricsPort" >> /etc/tor/torrc
fi
if [ -n "$MetricsPortPolicy" ]; then
  echo "MetricsPortPolicy $MetricsPortPolicy" >> /etc/tor/torrc
fi
if [ -n "$ControlPort" ]; then
  echo "ControlPort $ControlPort" >> /etc/tor/torrc
fi

# Startup
echo "Running tor -f /etc/tor/torrc"
tor -f /etc/tor/torrc
