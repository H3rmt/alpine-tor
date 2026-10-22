FROM python:alpine@sha256:d44b1254cb92329418d164b22b20d86bbd3869d48e80e09e476531a409a728bb

RUN apk add --no-cache tor tini util-linux shadow lyrebird netcat-openbsd --repository https://dl-cdn.alpinelinux.org/alpine/edge/community \
 && rm -f /etc/tor/torrc

ENV EXPORTER_VERSION=v0.3.3
RUN wget "https://raw.githubusercontent.com/H3rmt/tor-exporter/${EXPORTER_VERSION}/prometheus-tor-exporter.py" -O /prometheus-tor-exporter.py
RUN pip install --no-cache-dir stem prometheus_client retrying

COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY --chmod=755 start-exporter.sh /start.sh

VOLUME [ "/var/lib/tor" ]
ENV ControlPort=9030
ENV PrometheusExporterPort=9090

RUN groupmod -g 3000 tor && usermod -u 3000 -g tor tor
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
CMD ["/start.sh"]
