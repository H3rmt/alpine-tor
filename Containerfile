FROM alpine:latest@sha256:3f4d6b32e26703c6082839234f43769d5046b3ac7c910033911d1e71d8cd630a

RUN apk add --no-cache tor tini util-linux shadow lyrebird --repository https://dl-cdn.alpinelinux.org/alpine/edge/community \
 && rm -f /etc/tor/torrc

COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY --chmod=755 start.sh /start.sh

VOLUME [ "/var/lib/tor" ]

RUN groupmod -g 3000 tor && usermod -u 3000 -g tor tor
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
CMD ["/start.sh"]
