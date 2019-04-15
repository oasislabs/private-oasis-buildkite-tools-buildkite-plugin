ARG FEDORA_VERSION=29

FROM registry.fedoraproject.org/fedora:${FEDORA_VERSION}

ARG GITLINT_VERSION=0.11.0

ENV NAME=oasislabs/gitlint VERSION=1.0.0 ARCH=x86_64
LABEL   name="$NAME" \
        version="$VERSION" \
        architecture="$ARCH" \
        summary="Oasis Labs image for running gitlint." \
        maintainer="Oasis Labs Engineering <engineering@oasislabs.com>"

RUN dnf -y --setopt=tsflags=nodocs install git-core && \
    dnf clean all && \
    pip3 --no-cache-dir install gitlint==${GITLINT_VERSION}
