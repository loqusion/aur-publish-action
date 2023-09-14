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

COPY ssh_config /ssh_config
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
