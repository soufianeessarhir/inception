FROM alpine:3.21

RUN wget https://github.com/portainer/portainer/releases/download/2.33.2/portainer-2.33.2-linux-amd64.tar.gz && \
    tar xzf portainer-2.33.2-linux-amd64.tar.gz && \
    rm portainer-2.33.2-linux-amd64.tar.gz
EXPOSE 9443
CMD ["/portainer/portainer", "--data", "/data", "--host", "unix:///var/run/docker.sock"]
