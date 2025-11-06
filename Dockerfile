FROM golang:alpine@sha256:d3f0cf7723f3429e3f9ed846243970b20a2de7bae6a5b66fc5914e228d831bbb AS go-build

# Build /go/bin/obfs4proxy
RUN apk --no-cache add --update git \
 && git clone https://gitlab.com/yawning/obfs4.git \
 && cd obfs4 \
 && go build -o /usr/bin/obfs4proxy ./obfs4proxy

FROM alpine:latest@sha256:8a1f59ffb675680d47db6337b49d22281a139e9d709335b492be023728e11715 
RUN apk add tor --update-cache --repository http://dl-4.alpinelinux.org/alpine/edge/community

COPY --from=go-build /usr/bin/obfs4proxy /usr/local/bin/obfs4proxy

COPY entrypoint.sh /entrypoint.sh
COPY start.sh /start.sh
RUN chmod +x /entrypoint.sh /start.sh

ENTRYPOINT [ "/bin/sh" , "entrypoint.sh" ]
