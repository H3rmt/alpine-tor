FROM golang:alpine AS go-build

# Build /go/bin/obfs4proxy
RUN apk --no-cache add --update git \
 && git clone https://gitlab.com/yawning/obfs4.git \
 && ls -la \
 && cd obfs4 \
 && ls -la \
 && `go build -o /usr/bin/obfs4proxy ./obfs4proxy`

FROM alpine:latest 

RUN apk add tor --update-cache --repository http://dl-4.alpinelinux.org/alpine/edge/community

COPY --from=go-build /usr/bin/obfs4proxy /usr/local/bin/obfs4proxy

COPY torrc /etc/tor/torrc

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/bin/sh" , "entrypoint.sh" ]
