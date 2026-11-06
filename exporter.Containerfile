FROM python:alpine@sha256:a0f2e268f2ce8f3709611a90054ec6a8ae31f6251f5896b8648b9bb99835e30a

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
