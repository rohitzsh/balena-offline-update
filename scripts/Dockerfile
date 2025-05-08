FROM debian:bookworm-20250407-slim

RUN apt-get update -y \
    && apt-get install -y \
    build-essential \
    chrpath \
    cpio \
    debianutils \
    device-tree-compiler \
    diffstat \
    file \
    gawk \
    gcc \
    git \
    iproute2 \
    iptables \
    iputils-ping \
    iputils-ping \
    kmod \
    libegl1-mesa \
    liblz4-tool \
    libsdl1.2-dev \
    locales \
    make \
    mesa-common-dev \
    pylint \
    python3 \
    python3-git \
    python3-jinja2 \
    python3-pexpect \
    python3-pip \
    python3-subunit \
    socat \
    sudo \
    texinfo \
    unzip \
    vim \
    wget \
    xterm \
    xz-utils \
    zstd

RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && echo "LANG=en_US.UTF-8" > /etc/locale.conf \
    && locale-gen en_US.UTF-8 \
    && rm -rf /etc/localtime \
    && ln -s /usr/share/zoneinfo/Europe/London /etc/localtime

ARG BUILDER_UID
ARG BUILDER_GID

WORKDIR /opt/yocto
ENV USER=builder 
ENV BUILDER_UID=${BUILDER_UID:-1000}
ENV BUILDER_GID=${BUILDER_GID:-1000}

# bitbake does not run in root so create an unprivileged user
RUN groupadd --gid "${BUILDER_GID}" "${USER}" && \
    useradd \
      --uid ${BUILDER_UID} \
      --gid ${BUILDER_GID} \
      --shell /bin/bash \
      --system \
      ${USER} \
    && chown builder:builder /opt \
    && usermod -aG sudo builder \
    && echo "builder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/builder

USER builder

COPY entrypoint.sh .
