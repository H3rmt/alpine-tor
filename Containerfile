FROM alpine:latest@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6

RUN apk add --no-cache tor tini util-linux shadow lyrebird --repository https://dl-cdn.alpinelinux.org/alpine/edge/community \
 && rm -f /etc/tor/torrc

COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY --chmod=755 start.sh /start.sh

VOLUME [ "/var/lib/tor" ]

RUN groupmod -g 3000 tor && usermod -u 3000 -g tor tor
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
CMD ["/start.sh"]
