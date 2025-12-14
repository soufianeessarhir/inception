FROM alpine:3.21

RUN apk add --no-cache curl tar && \
    curl -L https://github.com/portainer/portainer/releases/download/2.37.0/portainer-2.37.0-linux-amd64.tar.gz \
      -o portainer.tar.gz && \
    tar xzf portainer.tar.gz && \
    rm portainer.tar.gz
    
EXPOSE 9443

CMD ["/portainer/portainer", "--data", "/data", "--host", "unix:///var/run/docker.sock"]
