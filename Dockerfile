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
		jq \
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
		sshpass \
		subversion \
		sudo \
		unzip \
		vim \
		wget \
		xmlstarlet \
		xz-utils \
		zip \
		zlib1g-dev \
	&& apt-get clean && rm -rf /var/lib/apt/lists/*

#
# Create the user and their home
#
RUN groupadd --gid "${APP_GID}" "${APP_GROUP}"
RUN useradd --uid "${APP_UID}" --gid "${APP_GID}" --groups "${APP_GROUP}" -m --home-dir "/home/${APP_USER}" "${APP_USER}"

#
# Add the configure and entrypoint scripts
#
COPY --chown=root:root configure entrypoint /
RUN chmod 0755 /configure /entrypoint

#
# Add the sudo configuration for the build group
#
COPY --chown=root:root 00-builder /etc/sudoers.d
RUN chmod 0640 /etc/sudoers.d/00-builder

#
# Now do the configurations for the actual user
#
USER "${APP_USER}"

#
# Final parameters
#
VOLUME      [ "/init.d" ]
VOLUME      [ "/cache" ]
VOLUME      [ "/tools" ]
VOLUME      [ "/home/${APP_USER}" ]

WORKDIR     "/home/${APP_USER}"
ENTRYPOINT  [ "/entrypoint" ]
