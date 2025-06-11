echo "Starting exporter with ControlPort:$ControlPort on 0.0.0.0:$MetricsPort in 10 secs"
(sleep 10 && python /prometheus-tor-exporter.py -m=tcp -a=127.0.0.1 -c=$ControlPort -b=0.0.0.0 -p=$MetricsPort)&

echo "Running tor -f /etc/tor/torrc"
tor -f /etc/tor/torrc