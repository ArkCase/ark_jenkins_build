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
ARG NVM_VER="0.39.1"
ARG NVM_INSTALLER="https://raw.githubusercontent.com/creationix/nvm/v${NVM_VER}/install.sh"

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
ENV NVM_VER="${NVM_VER}"

#
# O/S updates, and base tools
#
RUN apt-get update && \
	apt-get -y dist-upgrade -f && \
	apt-get install -y \
		autoconf \
		automake \
		bzip2 \
		bzr \
		ca-certificates \
		curl \
		dirmngr \
		default-libmysqlclient-dev \
		dpkg-dev \
		file \
		g++ \
		gcc \
		gcc \
		git \
		gnupg \
		imagemagick \
		libbz2-dev \
		libc6-dev \
		libcurl4-openssl-dev \
		libdb-dev \
		libevent-dev \
		libffi-dev \
		libgdbm-dev \
		libgeoip-dev \
		libglib2.0-dev \
		libgmp-dev \
		libjpeg-dev \
		libkrb5-dev \
		liblzma-dev \
		libmagickcore-dev \
		libmagickwand-dev \
		libncurses5-dev \
		libncursesw5-dev \
		libpng-dev \
		libpq-dev \
		libreadline-dev \
		libsqlite3-dev \
		libssl-dev \
		libtool \
		libwebp-dev \
		libxml2-dev \
		libxslt-dev \
		libyaml-dev \
		make \
		make \
		mercurial \
		netbase \
		openssh-client \
		openssl \
		patch \
		procps \
		subversion \
		sudo \
		unzip \
		vim \
		wget \
		xz-utils \
		zlib1g-dev \
	&& apt-get clean && rm -rf /var/lib/apt/lists/*

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
COPY --chown=root:root 00-build /etc/sudoers.d
RUN chmod 0640 /etc/sudoers.d/00-build

#
# Now do the configurations for the actual user
#
USER "${APP_USER}"

#
# Install NVM (not really needed b/c of how /tools works)
#
# RUN export PROFILE="/home/${APP_USER}/.bashrc" && \
#	curl -o- "${NVM_INSTALLER}" | bash

#
# Final parameters
#
VOLUME      [ "/init.d" ]
VOLUME      [ "/opt/build/cache" ]
VOLUME      [ "/opt/build/tools" ]
VOLUME      [ "/home/${APP_USER}" ]

WORKDIR     "/home/${APP_USER}"
ENTRYPOINT  [ "/entrypoint" ]
