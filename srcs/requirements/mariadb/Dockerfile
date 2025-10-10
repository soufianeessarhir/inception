FROM alpine:3.21
RUN apk add --no-cache mariadb mariadb-client && rm -rf /var/cache/apk/*
COPY --chmod=644 conf/server.conf  /etc/my.cnf.d/mariadb-server.cnf
COPY --chmod=700 tools/setup.sh /usr/local/bin/setup.sh
ENTRYPOINT ["/usr/local/bin/setup.sh"]
CMD ["mariadbd"]