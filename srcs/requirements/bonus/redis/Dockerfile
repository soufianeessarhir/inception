FROM alpine:3.21
RUN apk add --no-cache redis && mkdir -p /var/log/redis /var/lib/redis /run/redis \
&& chown -R redis:redis  /var/log/redis /var/lib/redis /run/redis
USER redis
COPY --chmod=444 conf/redis.conf /etc/redis.conf
CMD ["redis-server", "/etc/redis.conf", "--daemonize", "no"]