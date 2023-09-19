FROM archlinux/archlinux:base

RUN pacman --needed --noconfirm -Syu \
    awk \
    binutils \
    bzip2 \
    coreutils \
    fakeroot \
    file \
    findutils \
    gcc \
    gettext \
    git \
    go-pie \
    grep \
    gzip \
    libarchive \
    ncurses \
    openssh \
    sed \
    xz

RUN useradd -m builder && \
    echo "builder ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    usermod -a -G wheel builder

COPY ssh_config /ssh_config
COPY entrypoint.sh /entrypoint.sh

USER builder
WORKDIR /home/builder
ENV HOME=/home/builder

ENTRYPOINT ["/entrypoint.sh"]
