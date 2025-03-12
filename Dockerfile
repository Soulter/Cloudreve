
FROM golang:alpine AS builder

WORKDIR /build
COPY . .
RUN apk add --no-cache --update go gcc g++
RUN go build -a -o cloudreve -ldflags " -X 'github.com/cloudreve/Cloudreve/v3/pkg/conf.BackendVersion=$VERSION' -X 'github.com/cloudreve/Cloudreve/v3/pkg/conf.LastCommit=$COMMIT_SHA'"

FROM alpine:latest

WORKDIR /cloudreve

COPY --from=builder /build/cloudreve ./cloudreve

RUN apk update \
    && apk add --no-cache tzdata \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && chmod +x ./cloudreve \
    && mkdir -p /data/aria2 \
    && chmod -R 766 /data/aria2

EXPOSE 5212
VOLUME ["/cloudreve/uploads", "/cloudreve/avatar", "/data"]

ENTRYPOINT ["./cloudreve"]
