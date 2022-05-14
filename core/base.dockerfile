# Set empty base docker build container image.
FROM alpine:latest AS build_container

# Get and set environment variables needed.
ARG DOCKER_USER_NAME \
    DOCKER_USER_UID
ENV BUILD_DOCKER_USER_NAME=$DOCKER_USER_NAME \
    BUILD_DOCKER_USER_UID=$DOCKER_USER_UID

# Update/upgrade the image and add all the needed pacages.
RUN apk update && apk upgrade && apk add --no-cache curl wget nano nss-tools nss \
    # Create the needed folders and files to the build container and then copy it to the scratch container.
    && mkdir -p /base/.certificates && mkdir -p /base/.keys && mkdir -p /base/data \
    # TODO: Add password to the user.
    # Create a new user with the given name and uid and give permisions to all the created files and folders.
    && adduser --disabled-password -h /home/$BUILD_DOCKER_USER_NAME -s /bin/bash -u $BUILD_DOCKER_USER_UID $BUILD_DOCKER_USER_NAME && chown -R $BUILD_DOCKER_USER_NAME /base/

# Switch to a non-root user.
USER $BUILD_DOCKER_USER_NAME

# Start the empty base docker image and keep it alive.
CMD tail -f /dev/null
