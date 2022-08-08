FROM ubuntu:latest

#
# Basic Parameters
#
ARG ARCH="amd64"
ARG OS="linux"
ARG VER="1.0.0"
ARG PKG="jenkins-build"
ARG APP_USER="jenkins"
ARG APP_UID="1000"
ARG APP_GROUP="builder"
ARG APP_GID="1000"

#
# Some important labels
#
LABEL ORG="Armedia LLC"
LABEL MAINTAINER="Armedia Devops Team <devops@armedia.com>"
LABEL APP="Jenkins Build Base Image"
LABEL VERSION="${VER}"
LABEL IMAGE_SOURCE="https://github.com/ArkCase/ark_jenkins_build"

#
# Base environment variables
#
ENV APP_USER="${APP_USER}"
ENV APP_UID="${APP_UID}"
ENV APP_GID="${APP_GID}"

#
# O/S updates, and base tools
#
RUN apt-get update && apt-get -y dist-upgrade -f
RUN apt-get install -y \
        gcc \
        git \
        make \
        openssl \
        sudo \
        vim

#
# Create the user and their home
#
RUN groupadd --system "build"
RUN groupadd --gid "${APP_GID}" "${APP_GROUP}"
RUN useradd --uid "${APP_UID}" --gid "${APP_GID}" --groups "build" -m --home-dir "/home/${APP_USER}" "${APP_USER}"

#
# Add the entrypoint
#
COPY --chown=root:root entrypoint /
RUN chmod 0755 /entrypoint

#
# Add the sudo configuration for the build group
#
# COPY --chown=root:root 00-build /etc/sudoers.d
# RUN chmod 0640 /etc/sudoers.d/00-build

#
# Final parameters
#
USER        "${APP_USER}"
VOLUME      [ "/init.d" ]
VOLUME      [ "/home/${APP_USER}" ]
VOLUME      [ "/tools" ]
VOLUME      [ "/cache" ]

WORKDIR     "/home/${APP_USER}"
ENTRYPOINT  [ "/entrypoint" ]
