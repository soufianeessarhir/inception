FROM alpine:3.21
RUN apk add --no-cache nginx && \
    mkdir -p /var/lib/html && \
    chown -R nginx:nginx /var/lib/html &&  chmod 755 /var/lib/html
COPY --chmod=644 conf/nginx.conf /etc/nginx/nginx.conf 
COPY --chmod=644 --chown=nginx:nginx tools/app/ /var/lib/html/
EXPOSE 80
CMD ["nginx"]