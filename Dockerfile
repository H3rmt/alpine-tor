FROM golang:alpine@sha256:f6751d823c26342f9506c03797d2527668d095b0a15f1862cddb4d927a7a4ced AS go-build

# Build /go/bin/obfs4proxy
RUN apk --no-cache add --update git \
 && git clone https://gitlab.com/yawning/obfs4.git \
 && cd obfs4 \
 && go build -o /usr/bin/obfs4proxy ./obfs4proxy

FROM alpine:latest@sha256:4b7ce07002c69e8f3d704a9c5d6fd3053be500b7f1c69fc0d80990c2ad8dd412 
RUN apk add tor --update-cache --repository http://dl-4.alpinelinux.org/alpine/edge/community

COPY --from=go-build /usr/bin/obfs4proxy /usr/local/bin/obfs4proxy

COPY entrypoint.sh /entrypoint.sh
COPY start.sh /start.sh
RUN chmod +x /entrypoint.sh /start.sh

ENTRYPOINT [ "/bin/sh" , "entrypoint.sh" ]
