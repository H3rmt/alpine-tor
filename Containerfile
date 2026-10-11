FROM golang:alpine@sha256:3ad57304ad93bbec8548a0437ad9e06a455660655d9af011d58b993f6f615648 AS go-build

# Build /go/bin/obfs4proxy
RUN apk add --no-cache git \
 && git clone https://gitlab.com/yawning/obfs4.git \
 && cd obfs4 \
 && go build -o /usr/bin/obfs4proxy ./obfs4proxy

FROM alpine:latest@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b

RUN apk add --update-cache --repository http://dl-4.alpinelinux.org/alpine/edge/community tor tini util-linux shadow && rm -f /etc/tor/torrc

COPY --from=go-build /usr/bin/obfs4proxy /usr/local/bin/obfs4proxy

COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY --chmod=755 start.sh /start.sh

VOLUME [ "/var/lib/tor" ]

RUN groupmod -g 3000 tor && usermod -u 3000 -g tor tor
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
CMD ["/start.sh"]
