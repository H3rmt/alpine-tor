# Alpine Tor

Run a Tor relay, bridge, or proxy in a small Alpine Linux container.

The project publishes two images:

| Image                               | Purpose                          |
| ----------------------------------- | -------------------------------- |
| `ghcr.io/h3rmt/alpine-tor`          | Tor only                         |
| `ghcr.io/h3rmt/alpine-tor-exporter` | Tor plus the Prometheus exporter |

Both images:

- use Tini as PID 1
- generate a Tor configuration from environment variables by default
- run Tor as an unprovileged `tor` user.

## Quick start

Change the host-side ports and relay settings to suit your deployment. Relay ports must be published and reachable from the public internet.

### Tor relay

```yaml
services:
  middle:
    image: ghcr.io/h3rmt/alpine-tor:latest
    restart: unless-stopped
    environment:
      mode: middle
      ORPort: 9001
      ContactInfo: "email@domain"
      AccountingStart: "week 1 01:00"
      AccountingMax: "2 TBytes"
    volumes:
      - ./data:/var/lib/tor
    ports:
      - "9001:9001/tcp"
```

### Bridge with Prometheus exporter

The exporter image uses `ControlPort` to communicate with Tor and `PrometheusExporterPort` for the Prometheus HTTP endpoint. Tor's optional native metrics listener uses the separate `MetricsPort` and `MetricsPortPolicy` setting.

```yaml
services:
  bridge:
    image: ghcr.io/h3rmt/alpine-tor-exporter:latest
    restart: unless-stopped
    environment:
      mode: bridge
      ORPort: 9001
      PTPort: 8000
      ContactInfo: "your-contact-information"
      AccountingStart: "week 1 01:00"
      AccountingMax: "2 TBytes"
      # ControlPort: 9030 # (default)
      # PrometheusExporterPort: 9090 # (default)
      MetricsPort: 9091
      MetricsPortPolicy: accept *
    volumes:
      - ./data:/var/lib/tor
    ports:
      - "9001:9001/tcp"
      - "8000:8000/tcp"
      - "127.0.0.1:9090:9090/tcp"
      - "127.0.0.1:9091:9091/tcp"
```

The exporter image can also be used with `mode: middle` or another supported mode. The exporter must have both `ControlPort` and `PrometheusExporterPort` set. The `ControlPort` is used internally by the exporter and does not need to be published to the host.

## Configuration

### Generated `torrc`

If `/etc/tor/torrc` does not exist when the container starts, the entrypoint
creates it using the environment variables listed below. The generated file
is recreated on each start.

### Custom `torrc`

To provide a complete custom configuration, mount a file at `/etc/tor/torrc`:

```yaml
services:
  tor:
    image: ghcr.io/h3rmt/alpine-tor:latest
    environment:
      mode: middle # ignored when a custom torrc is mounted
    volumes:
      - ./torrc:/etc/tor/torrc:ro
      - ./data:/var/lib/tor
    # Publish the ORPort, DirPort, SOCKSPort, or other listener ports declared
    # by the mounted torrc as needed.
```

The entrypoint detects the existing file and leaves it unchanged. The file must be readable by the container's `tor` user, for example with mode `0644`.
Publish any listener ports declared by the custom file with Compose `ports:` entries; the example above intentionally does not publish any ports.

When a custom file is used, the generated-configuration environment variables are ignored. For the exporter image, the custom file must still configure a working Tor `ControlPort`. If Tor's native `MetricsPort` is enabled as well, it must use a different port from `PrometheusExporterPort`.

## Supported modes

| Mode     | Generated configuration                   | Status    |
| -------- | ----------------------------------------- | --------- |
| `middle` | ORPort and non-exit relay                 | Supported |
| `bridge` | ORPort, bridge relay, and obfs4 transport | Supported |
| `exit`   | ORPort, exit relay, and DirPort           | Untested  |
| `proxy`  | SOCKSPort                                 | Untested  |

## Environment variables

### Relay and mode settings

| Variable      | Description                                                                       |
| ------------- | --------------------------------------------------------------------------------- |
| `mode`        | `middle`, `bridge`, `exit`, or `proxy`. Required when generating a configuration. |
| `ContactInfo` | Administrative contact information for the relay or bridge.                       |
| `Nickname`    | Tor nickname; 1–19 alphanumeric characters.                                       |
| `ORPort`      | Port advertised for Tor relay connections.                                        |
| `PTPort`      | obfs4 transport port; used by `bridge` mode.                                      |
| `SOCKSPort`   | SOCKS port; used by `proxy` mode.                                                 |
| `DirPort`     | Directory port; used by `exit` and `middle` modes.                                |

### Optional Tor settings

| Variable                 | Description                                                                      |
| ------------------------ | -------------------------------------------------------------------------------- |
| `DNSPort`                | UDP port for anonymous DNS resolution.                                           |
| `MyFamily`               | Fingerprints of relays operated by the same group.                               |
| `HiddenServiceDir`       | Directory for a hidden service.                                                  |
| `HiddenServicePort`      | Virtual-to-real port mapping for a hidden service.                               |
| `ExitNodes`              | Nodes, fingerprints, countries, or address patterns for exits.                   |
| `AccountingMax`          | Maximum traffic allowed in an accounting period.                                 |
| `AccountingStart`        | Length and start of accounting periods.                                          |
| `MaxAdvertisedBandwidth` | Upper limit for advertised relay bandwidth.                                      |
| `RelayBandwidthRate`     | Relay bandwidth rate.                                                            |
| `RelayBandwidthBurst`    | Short-term relay bandwidth burst limit.                                          |
| `MetricsPort`            | Optional native Tor metrics port. Do not share it with `PrometheusExporterPort`. |
| `MetricsPortPolicy`      | Access policy for the standard image's native metrics port.                      |
| `ControlPort`            | Tor control port; required by the exporter image.                                |
| `PrometheusExporterPort` | Prometheus exporter HTTP port; required by the exporter image.                   |

These settings correspond to Tor's server options. See the [Tor manual](https://man.archlinux.org/man/tor.1#SERVER_OPTIONS) for complete reference.
