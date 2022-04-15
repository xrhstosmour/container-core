# Set empty base docker build container image.
FROM alpine:latest AS build_container

# Get and set environment variables needed.
ARG DOCKER_USER_NAME
ARG DOCKER_USER_UID
ENV BUILD_DOCKER_USER_NAME=$DOCKER_USER_NAME
ENV BUILD_DOCKER_USER_UID=$DOCKER_USER_UID

# Update/upgrade the image and add all the needed pacages.
RUN apk update && apk upgrade && apk add --no-cache curl wget nano nss-tools nss

# Create the needed folders and files to the build container and then copy it to the scratch container.
RUN mkdir -p /base/.certificates && mkdir -p /base/.keys && mkdir -p /base/data && mkdir -p /base/.databases && mkdir -p /base/scripts

# Install the latest linux mkcert release and move the mkcert binary to the build container and give proper permissions.
RUN curl -s https://api.github.com/repos/FiloSottile/mkcert/releases/latest | grep browser_download_url | grep '\linux-amd64' | cut -d '"' -f 4 | wget -i - && mv mkcert-v*-linux-amd64 /usr/bin/mkcert && chmod +x /usr/bin/mkcert

# TODO: Change domain names to the wanted ones from .env.
# TODO: Find a way to properly refresh the certificates if are not valid.
# Generate certificate for domain "docker.localhost", "domain.local" and their sub-domains
RUN cd /base/.certificates && mkcert -install && mkcert -cert-file /base/.certificates/local_certificate.pem -key-file /base/.certificates/local_certificate_key.pem "localhost" "*.localhost"

# Create a new user with the given name and uid and give permisions to all the created files and folders.
RUN adduser --disabled-password -h /home/$BUILD_DOCKER_USER_NAME -s /bin/bash -u $BUILD_DOCKER_USER_UID $BUILD_DOCKER_USER_NAME && chown -R $BUILD_DOCKER_USER_NAME /base/

# TODO: Maybe delete the 2 following lines, because they are not needed, for now.
# Copy the needed files for our container, star (*) is for checking if file exists.
COPY server/scripts/services /scripts/services

# Make the script for waiting executable.
RUN chmod +x /scripts/**/*.sh

# TODO: Create code or container to auto-backup databases to the correspoding folder.

# Switch to a non-root user.
USER $BUILD_DOCKER_USER_NAME

# Start the empty base docker image and keep it alive.
CMD tail -f /dev/null
