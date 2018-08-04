#
# Nginx Dockerfile
#

# Pull base image.
FROM alpine
MAINTAINER behroozam <b.hasanbg@gmail.com>

WORKDIR /var/www/html

RUN apk --update upgrade && apk update && apk add curl ca-certificates && update-ca-certificates --fresh && apk add openssl
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories 
RUN apk --update add \
        nginx \
        bash
# Install Nginx.
RUN mkdir -p /run/nginx
# Define working directory.
WORKDIR /etc/nginx

ADD start-nginx.sh /start-nginx

# Define default command.
CMD ["/bin/bash","/start-nginx"]

# Expose ports.
EXPOSE 80
EXPOSE 443
