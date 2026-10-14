#
# Basic Parameters
#
ARG PUBLIC_REGISTRY="public.ecr.aws"
ARG VER="3.19.0"

ARG BASE_REGISTRY="${PUBLIC_REGISTRY}"
ARG BASE_REPO="arkcase/jenkins-build-base"
ARG BASE_VER_PFX=""
ARG BASE_VER="1.10.0"
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
# Install sudo
#
RUN apt-get update && \
    apt-get install -y \
        screen \
        sudo \
      && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#
# Add the sudo configuration for the build group
#
COPY --chown=root:root 00-build /etc/sudoers.d
RUN chmod 0640 /etc/sudoers.d/00-build

#
# Add the configure and entrypoint scripts
#
COPY --chown=root:root configure entrypoint /
RUN chmod 0755 /configure /entrypoint

#
# Add any tools managed at this level
#
ADD --chown=root:root tools /tools

#
# Add the default initializers & configurators
#
COPY --chown=root:root init.d /init.d
COPY --chown=root:root conf.d /conf.d

#
# Install all the scripts that are used during builds
#
COPY --chown=root:root scripts/ /usr/local/bin

RUN --mount=type=bind,target=/src \
    --mount=type=secret,id=mvn_get_auth \
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
