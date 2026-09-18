FROM golang:alpine@sha256:4cb7ac979db5fcc41cae44b2227ba5ab8a51e8807f40d9ba4dee20a0ad960b5b AS go-build

# Build /go/bin/obfs4proxy
RUN apk --no-cache add --update git \
 && git clone https://gitlab.com/yawning/obfs4.git \
 && cd obfs4 \
 && go build -o /usr/bin/obfs4proxy ./obfs4proxy

FROM alpine:latest@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b 
RUN apk add tor --update-cache --repository http://dl-4.alpinelinux.org/alpine/edge/community

COPY --from=go-build /usr/bin/obfs4proxy /usr/local/bin/obfs4proxy

COPY entrypoint.sh /entrypoint.sh
COPY start.sh /start.sh
RUN chmod +x /entrypoint.sh /start.sh

ENTRYPOINT [ "/bin/sh" , "entrypoint.sh" ]
