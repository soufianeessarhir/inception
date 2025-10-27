FROM alpine:3.21
RUN apk add --no-cache redis
COPY --chmod=444 conf/redis.conf /etc/redis.conf
CMD ["redis-server", "/etc/redis.conf", "--daemonize", "no"]