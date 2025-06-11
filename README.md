## Bridge compose.yml
```yaml
services:
  bridge:
    image: h3rmt/alpine-tor:latest
    restart: unless-stopped
    container_name: bridge
    user: "0:0"
    environment:
      - mode=bridge
      - ORPort=9001
      - PTPort=8000
      - ContactInfo=---
      - AccountingStart="week 1 01:00"
      - AccountingMax="2 TBytes"
    volumes:
      - ./data:/var/lib/tor
    network_mode: host
```

## Middle compose.yml
```yaml
services:
  middle:
    image: h3rmt/alpine-tor:latest
    restart: unless-stopped
    container_name: middle
    user: "0:0"
    environment:
      - mode=middle
      - ORPort=9001
      - ContactInfo=---
      - AccountingStart="week 1 01:00"
      - AccountingMax="2 TBytes"
    volumes:
      - ./data:/var/lib/tor
    network_mode: host
```


## Middle+exporter compose.yml
### Exporter from https://github.com/H3rmt/tor-exporter, metrics in README `Exported metrics` 
```yaml
services:
  middle:
    image: h3rmt/alpine-tor:latest
    restart: unless-stopped
    container_name: middle
    user: "0:0"
    environment:
      - mode=middle
      - ORPort=9001
      - ContactInfo=---
      - AccountingStart="week 1 01:00"
      - AccountingMax="2 TBytes"
      - ControlPort=9030
    volumes:
      - ./data:/var/lib/tor
    network_mode: host
```

## Exit compose.yml
```yaml
services:
  exit:
    image: h3rmt/alpine-tor:latest
    restart: unless-stopped
    container_name: exit
    user: "0:0"
    environment:
      - mode=exit
      - ORPort=9001
      - DirPort=---
      - ContactInfo=---
      - AccountingStart="week 1 01:00"
      - AccountingMax="2 TBytes"
    volumes:
      - ./data:/var/lib/tor
    network_mode: host
```
## Support (https://man.archlinux.org/man/tor.1#SERVER_OPTIONS):
- ContactInfo: Administrative contact information for this relay or bridge.
- Nickname: Nicknames must be between 1 and 19 characters inclusive, and must contain only the characters [a-zA-Z0-9].
- ORPort: Advertise this port to listen for connections from Tor clients and servers.
- PTPort: obfs4 Port
- SOCKSPort: Open this port to listen for connections from SOCKS-speaking applications.
- DNSPort: Open this port to listen for UDP DNS requests, and resolve them anonymously.
- MyFamily: Declare that this Tor relay is controlled or administered by a group or organization identical or similar to that of the other relays, defined by their (possibly $-prefixed) identity fingerprints.
- HiddenServiceDir: Store data files for a hidden service in DIRECTORY.
- HiddenServicePort: Configure a virtual port VIRTPORT for a hidden service.
- ExitNodes: A list of identity fingerprints, country codes, and address patterns of nodes to use as exit node
- AccountingMax: Limits the max number of bytes sent and received within a set time period using a given calculation rule.
- AccountingStart: Specify how long accounting periods last.
- MaxAdvertisedBandwidth: If set, we will not advertise more than this amount of bandwidth for our BandwidthRate.
- RelayBandwidthRate: limit how much relayed traffic you will allow (must be at least 20 kilobytes per second)
- RelayBandwidthBurst: pool of bytes used to fulfill requests during short periods of traffic above BandwidthRate
- MetricsPort: If set, open this port to listen for an HTTP GET request to "/metrics".
- MetricsPortPolicy: Set an entrance policy for the MetricsPort, to limit who can access it.
- ControlPort: If set, Tor will accept connections on this port and allow those connections to control the Tor process using the Tor Control Protocol
