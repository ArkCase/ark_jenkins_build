#
# Basic Parameters
#
ARG PUBLIC_REGISTRY="public.ecr.aws"
ARG VER="3.23.0"

ARG BASE_REGISTRY="${PUBLIC_REGISTRY}"
ARG BASE_REPO="arkcase/jenkins-build-base"
ARG BASE_VER_PFX=""
ARG BASE_VER="1.13.0"
ARG BASE_IMG="${BASE_REGISTRY}/${BASE_REPO}:${BASE_VER_PFX}${BASE_VER}"

ARG MAVEN_XFERLOG_VER="1.0.0"
ARG MAVEN_XFERLOG_SRC="com.armedia.maven:maven-uploads-only-transfer-log:${MAVEN_XFERLOG_VER}:jar"
ARG MAVEN_XFERLOG_REPO="https://nexus.armedia.com/repository/armedia"

FROM "${BASE_IMG}"

LABEL APP="Jenkins Build CI/CD Worker Image"
LABEL VERSION="${VER}"
LABEL IMAGE_SOURCE="https://github.com/ArkCase/ark_jenkins_build"

ARG MAVEN_XFERLOG_SRC
ARG MAVEN_XFERLOG_REPO

#
# These next few steps must be run as root
#
USER "root"

#
# Everything in a single layer: sudo and its configuration for the build group, the configure and entrypoint scripts,
# the tools managed at this level, the default initializers and configurators, the scripts used during builds, and
# the Maven extension
#
RUN --mount=type=bind,target=/src \
    --mount=type=secret,id=mvn_get_auth \
    apt-get update && \
    apt-get install -y \
        screen \
        sudo \
      && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    install -o root -g root -m 0440 -t /etc/sudoers.d /src/00-build && \
    install -o root -g root -m 0755 -t / /src/configure /src/entrypoint && \
    ( cd /src && tar --owner=root --group=root --mode=go-w -cf - tools init.d conf.d ) | tar -C / -xf - && \
    install -o root -g root -m 0755 -t /usr/local/bin /src/scripts/* && \
    . /run/secrets/mvn_get_auth && \
    /src/install-maven-ext "${MAVEN_XFERLOG_SRC}" "${MAVEN_XFERLOG_REPO}"

#
# Fall back down to the actual user
#
USER "${APP_USER}"

#
# Set our entrypoint
#
ENTRYPOINT  [ "/entrypoint" ]
