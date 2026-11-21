FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# =====================================
# UPDATE UBUNTU
# =====================================

RUN apt-get update && apt-get upgrade -y

# =====================================
# ESSENTIAL UTILITIES
# =====================================

RUN apt-get install -y \
    ca-certificates \
    curl \
    wget \
    git \
    git-lfs \
    gnupg \
    sudo \
    software-properties-common \
    apt-transport-https \
    locales \
    tzdata \
    bash \
    zsh \
    fish \
    jq \
    file \
    less \
    man-db

# =====================================
# PYTHON
# =====================================

RUN apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    python3-full \
    python-is-python3 \
    python3-setuptools \
    python3-wheel

# =====================================
# C / C++ DEVELOPMENT
# =====================================

RUN apt-get install -y \
    build-essential \
    gcc \
    g++ \
    gfortran \
    make \
    cmake \
    ninja-build \
    pkg-config \
    autoconf \
    automake \
    libtool

# =====================================
# JAVA
# =====================================

RUN apt-get install -y \
    default-jdk \
    default-jre

# =====================================
# NODE.JS
# =====================================

RUN apt-get install -y \
    nodejs \
    npm

# =====================================
# SSH SERVER
# =====================================

RUN apt-get install -y \
    openssh-server \
    openssl

# =====================================
# TERMINAL TOOLS
# =====================================

RUN apt-get install -y \
    nano \
    vim \
    neovim \
    screen \
    tmux \
    htop \
    btop \
    tree \
    ncdu \
    less \
    procps \
    psmisc \
    lsof

# =====================================
# NETWORK TOOLS
# =====================================

RUN apt-get install -y \
    net-tools \
    iproute2 \
    iputils-ping \
    dnsutils \
    traceroute \
    socat \
    netcat-openbsd \
    rsync \
    whois \
    mtr-tiny

# =====================================
# WEB SERVER TOOLS
# =====================================

RUN apt-get install -y \
    nginx \
    apache2-utils \
    php-cli \
    php-curl \
    php-mbstring \
    php-xml \
    php-zip

# =====================================
# DATABASE CLIENTS
# =====================================

RUN apt-get install -y \
    sqlite3 \
    postgresql-client \
    redis-tools

# =====================================
# ARCHIVE UTILITIES
# =====================================

RUN apt-get install -y \
    zip \
    unzip \
    p7zip-full \
    tar \
    gzip \
    xz-utils

# =====================================
# MEDIA UTILITIES
# =====================================

RUN apt-get install -y \
    ffmpeg

# =====================================
# EXTRA UTILITIES
# =====================================

RUN apt-get install -y \
    cron \
    logrotate \
    strace \
    tini

# =====================================
# CLEAN PACKAGE CACHE
# =====================================

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# =====================================
# SSH CONFIGURATION
# =====================================

RUN mkdir -p /var/run/sshd /root/.ssh && \
    chmod 700 /root/.ssh

RUN printf '%s\n' \
    'Port 22' \
    'AddressFamily any' \
    'ListenAddress 0.0.0.0' \
    'PermitRootLogin prohibit-password' \
    'PasswordAuthentication no' \
    'PubkeyAuthentication yes' \
    'AllowTcpForwarding yes' \
    'X11Forwarding no' \
    'ClientAliveInterval 60' \
    'ClientAliveCountMax 3' \
    > /etc/ssh/sshd_config

# =====================================
# VPS STARTUP SCRIPT
# =====================================

RUN cat > /usr/local/bin/start-vps <<'EOF'
#!/bin/bash
set -e

echo "=================================="
echo "       UBUNTU 24.04 VPS"
echo "=================================="

mkdir -p /var/run/sshd /root/.ssh
chmod 700 /root/.ssh

if [ -z "${SSH_PUBLIC_KEY:-}" ]; then
    echo "ERROR: SSH_PUBLIC_KEY is required."
    exit 1
fi

printf '%s\n' "$SSH_PUBLIC_KEY" > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

ssh-keygen -A

/usr/sbin/sshd -t

echo "Python: $(python3 --version)"
echo "Node: $(node --version)"
echo "NPM: $(npm --version)"
echo "Git: $(git --version)"

echo "Ubuntu VPS is starting..."

exec /usr/sbin/sshd -D -e
EOF

RUN chmod +x /usr/local/bin/start-vps

EXPOSE 22

CMD ["/usr/local/bin/start-vps"]
