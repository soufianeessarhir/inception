FROM alpine:3.21
RUN apk add --no-cache nginx
COPY --chmod=644 conf/nginx.conf /etc/nginx/nginx.conf 
COPY --chmod=644 tools/app/ /var/lib/html/
EXPOSE 80
CMD ["nginx"]