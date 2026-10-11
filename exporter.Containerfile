FROM golang:alpine@sha256:3ad57304ad93bbec8548a0437ad9e06a455660655d9af011d58b993f6f615648 AS go-build

# Build /go/bin/obfs4proxy
RUN apk add --no-cache git \
 && git clone https://gitlab.com/yawning/obfs4.git \
 && cd obfs4 \
 && go build -o /usr/bin/obfs4proxy ./obfs4proxy

FROM python:alpine@sha256:26730869004e2b9c4b9ad09cab8625e81d256d1ce97e72df5520e806b1709f92

RUN apk add --update-cache --repository http://dl-4.alpinelinux.org/alpine/edge/community tor tini util-linux shadow netcat-openbsd  && rm -f /etc/tor/torrc

ENV EXPORTER_VERSION=v0.3.3
RUN wget "https://raw.githubusercontent.com/H3rmt/tor-exporter/${EXPORTER_VERSION}/prometheus-tor-exporter.py" -O /prometheus-tor-exporter.py
RUN pip install --no-cache-dir stem prometheus_client retrying

COPY --from=go-build /usr/bin/obfs4proxy /usr/local/bin/obfs4proxy

COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY --chmod=755 start-exporter.sh /start.sh

VOLUME [ "/var/lib/tor" ]
ENV ControlPort=9030
ENV PrometheusExporterPort=9090

RUN groupmod -g 3000 tor && usermod -u 3000 -g tor tor
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
CMD ["/start.sh"]
