echo "Starting exporter with ControlPort:$ControlPort on 0.0.0.0:9099 in 10 secs"
(sleep 10 && python /prometheus-tor-exporter.py -m=tcp -a=127.0.0.1 -c=$ControlPort -b=0.0.0.0 -p=9099)&

echo "Running tor -f /etc/tor/torrc"
tor -f /etc/tor/torrc