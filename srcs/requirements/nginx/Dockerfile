FROM alpine:3.21
RUN apk add --no-cache nginx openssl
COPY conf/nginx.conf /etc/nginx/nginx.conf
CMD ["nginx"]