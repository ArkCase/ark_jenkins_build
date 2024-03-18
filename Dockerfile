FROM ubuntu:latest

#
# Basic Parameters
#
ARG ARCH="amd64"
ARG OS="linux"
ARG VER="1.3.3"
ARG PKG="jenkins-build"
ARG APP_USER="jenkins"
ARG APP_UID="1000"
ARG APP_GROUP="builder"
ARG APP_GID="1000"
ARG DOCKER_KEYRING="https://download.docker.com/linux/ubuntu/gpg"
ARG DOCKER_DEB_DISTRO="jammy"
ARG DOCKER_PACKAGE_REPO="https://download.docker.com/linux/ubuntu"
ARG K8S_VER="1.28"
ARG K8S_KEYRING="https://pkgs.k8s.io/core:/stable:/v${K8S_VER}/deb/Release.key"
ARG K8S_PACKAGE_REPO="https://pkgs.k8s.io/core:/stable:/v${K8S_VER}/deb/"
ARG HELM_VER="3.12.3"
ARG HELM_SRC="https://get.helm.sh/helm-v${HELM_VER}-linux-amd64.tar.gz"
ARG GITHUB_KEYRING="https://cli.github.com/packages/githubcli-archive-keyring.gpg"
ARG GITLAB_REPO="https://raw.githubusercontent.com/upciti/wakemeops/main/assets/install_repository"

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
ENV APP_VER="${VER}"
ENV TRUSTED_GPG_DIR="/etc/apt/trusted.gpg.d"
ENV APT_SOURCES_DIR="/etc/apt/sources.list.d"

#
# Prep to make GitLab CLI and GitHub CLI available
#
RUN apt-get update && \
    apt-get install -y \
        curl gpg \
      && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl -fsSL -o /etc/apt/trusted.gpg.d/github-archive-keyring.gpg "${GITHUB_KEYRING}" && \
    chmod go+r /etc/apt/trusted.gpg.d/github-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture)] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list && \
    curl -fsSL "${GITLAB_REPO}" | bash && \
    ( rm -f "${TRUSTED_GPG_DIR}/docker.gpg" &>/dev/null || true ) && \
    curl -fsSL "${DOCKER_KEYRING}" | gpg --dearmor -o "${TRUSTED_GPG_DIR}/docker.gpg" && \
    chmod a+r "${TRUSTED_GPG_DIR}/docker.gpg" && \
    echo "deb [arch=${ARCH}] ${DOCKER_PACKAGE_REPO} ${DOCKER_DEB_DISTRO} stable" > "${APT_SOURCES_DIR}/docker.list" && \
    curl -fsSL "${K8S_KEYRING}" | gpg --dearmor -o "${TRUSTED_GPG_DIR}/kubernetes.gpg" && \
    chmod a+r "${TRUSTED_GPG_DIR}/kubernetes.gpg" && \
    echo "deb ${K8S_PACKAGE_REPO} /" > "${APT_SOURCES_DIR}/kubernetes.list"


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
        ca-certificates-java \
        containerd.io \
        curl \
        dirmngr \
        default-libmysqlclient-dev \
        dos2unix \
        docker-buildx-plugin \
        docker-compose-plugin \
        docker-ce \
        docker-ce-cli \
        dpkg-dev \
        file \
        g++ \
        gcc \
        gcc \
        gettext-base \
        gh \
        git \
        git-flow \
        glab \
        gnupg \
        imagemagick \
        jq \
        kubectl \
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
        libxml2-utils \
        libxslt-dev \
        libyaml-dev \
        make \
        mercurial \
        mutt \
        netbase \
        openssh-client \
        openssl \
        patch \
        procps \
        python3-pip \
        rsync \
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
      && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl -L --fail "${HELM_SRC}" | tar -C /usr/local/bin --strip-components=1 -xzvf - linux-amd64/helm

#
# Create the user and their home
#
RUN groupadd --system "build"
RUN groupadd --gid "${APP_GID}" "${APP_GROUP}"
RUN useradd --uid "${APP_UID}" --gid "${APP_GID}" --groups "build,docker" -m --home-dir "/home/${APP_USER}" "${APP_USER}"

#
# Add the configure and entrypoint scripts
#
COPY --chown=root:root configure entrypoint /
RUN chmod 0755 /configure /entrypoint

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
# Final parameters
#
VOLUME      [ "/conf.d" ]
VOLUME      [ "/init.d" ]
VOLUME      [ "/cache" ]
VOLUME      [ "/tools" ]
VOLUME      [ "/home/${APP_USER}" ]

WORKDIR     "/home/${APP_USER}"
ENTRYPOINT  [ "/entrypoint" ]
