FROM ubuntu:latest

#
# Basic Parameters
#
ARG ARCH="amd64"
ARG OS="linux"
ARG VER="1.0.0"
ARG PKG="jenkins-build"
ARG UID="0"

#
# Some important labels
#
LABEL ORG="Armedia LLC"
LABEL MAINTAINER="Armedia Devops Team <devops@armedia.com>"
LABEL APP="Jenkins Build Base Image"
LABEL VERSION="${VER}"
LABEL IMAGE_SOURCE="https://github.com/ArkCase/ark_jenkins_build"

RUN apt-get update && apt-get -y dist-upgrade
COPY entrypoint /

#
# Final parameters
#
VOLUME      [ "/tools" ]
VOLUME      [ "/cache" ]
VOLUME      [ "/init.d" ]
WORKDIR     /
ENTRYPOINT  [ "/entrypoint" ]
