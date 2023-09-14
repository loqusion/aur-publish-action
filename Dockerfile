FROM archlinux/archlinux:base

# Install dependencies
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

# Create non-root user and add .ssh/known_hosts
RUN useradd -m builder && \
    mkdir -p /home/builder/.ssh && \
    touch /home/builder/.ssh/known_hosts

# Copy ssh_config
COPY ssh_config /home/builder/.ssh/config

# Set permissions
RUN chown -R builder:builder /home/builder && \
    chmod 600 /home/builder/.ssh/* -R

# Copy entrypoint
COPY entrypoint.sh /

# Switch to non-root user and set workdir
USER builder
WORKDIR /home/builder

ENTRYPOINT ["/entrypoint.sh"]
