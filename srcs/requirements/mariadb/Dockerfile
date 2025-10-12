FROM alpine:3.19
RUN apk add --no-cache mariadb mariadb-client && \
mkdir -p  /run/mysqld/  /var/lib/mysql/ && \
chown -R mysql:mysql /run/mysqld/  /var/lib/mysql
COPY --chmod=644  conf/server.conf /etc/my.cnf.d/mariadb-server.cnf
COPY --chmod=755  tools/setup.sh /usr/local/bin/setup.sh
EXPOSE 3306
ENTRYPOINT ["/usr/local/bin/setup.sh"]
CMD ["mariadbd","--user=mysql", "--console" ,"--skip-name-resolve"]