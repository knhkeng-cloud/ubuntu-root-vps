FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# ==========================================
# SYSTEM UPDATE
# ==========================================

RUN apt-get update && apt-get upgrade -y

# ==========================================
# ESSENTIAL PACKAGES
# ==========================================

RUN apt-get install -y \
    ca-certificates \
    curl \
    wget \
    git \
    gnupg \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    locales \
    tzdata \
    sudo \
    bash \
    zsh \
    fish

# ==========================================
# PYTHON DEVELOPMENT
# ==========================================

RUN apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    python3-full \
    python-is-python3 \
    python3-setuptools \
    python3-wheel

# ==========================================
# COMPILERS AND BUILD TOOLS
# ==========================================

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

# ==========================================
# JAVA DEVELOPMENT
# ==========================================

RUN apt-get install -y \
    default-jdk \
    default-jre

# ==========================================
# NODE.JS DEVELOPMENT
# ==========================================

RUN apt-get install -y \
    nodejs \
    npm

# ==========================================
# SSH SERVER
# ==========================================

RUN apt-get install -y \
    openssh-server \
    openssl

# ==========================================
# TERMINAL UTILITIES
# ==========================================

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
    fastfetch \
    less \
    man-db

# ==========================================
# NETWORKING TOOLS
# ==========================================

RUN apt-get install -y \
    net-tools \
    iproute2 \
    iputils-ping \
    dnsutils \
    traceroute \
    socat \
    netcat-openbsd \
    rsync \
    lsof \
    whois \
    mtr-tiny

# ==========================================
# WEB HOSTING TOOLS
# ==========================================

RUN apt-get install -y \
    nginx \
    apache2-utils \
    php-cli \
    php-curl \
    php-mbstring \
    php-xml \
    php-zip

# ==========================================
# DATABASE CLIENTS
# ==========================================

RUN apt-get install -y \
    sqlite3 \
    postgresql-client \
    redis-tools

# ==========================================
# FILE MANAGEMENT
# ==========================================

RUN apt-get install -y \
    zip \
    unzip \
    p7zip-full \
    tar \
    gzip \
    xz-utils \
    file \
    jq

# ==========================================
# MEDIA TOOLS
# ==========================================

RUN apt-get install -y \
    ffmpeg

# ==========================================
# SYSTEM UTILITIES
# ==========================================

RUN apt-get install -y \
    cron \
    logrotate \
    procps \
    psmisc \
    strace \
    tini \
    git-lfs

# ==========================================
# CLEANUP
# ==========================================

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ==========================================
# SSH CONFIGURATION
# ==========================================

RUN mkdir -p /var/run/sshd /root/.ssh && \
    chmod 700 /root/.ssh

RUN printf '%s\n' \
    'Port 22' \
    'AddressFamily any' \
    'ListenAddress 0.0.0.0' \
    'PermitRootLogin yes' \
    'PasswordAuthentication yes' \
    'PubkeyAuthentication yes' \
    'UsePAM no' \
    'AllowTcpForwarding yes' \
    'X11Forwarding no' \
    'ClientAliveInterval 60' \
    'ClientAliveCountMax 3' \
    > /etc/ssh/sshd_config

# ==========================================
# VPS STARTUP SCRIPT
# ==========================================

RUN cat > /usr/local/bin/start-vps <<'EOF'
#!/bin/bash
set -e

echo "=================================="
echo "       UBUNTU ROOT VPS"
echo "=================================="

if [ -z "${ROOT_PASSWORD:-}" ]; then
    echo "ERROR: ROOT_PASSWORD is missing."
    exit 1
fi

# Configure root password
printf 'root:%s\n' "$ROOT_PASSWORD" | chpasswd

# Optional SSH public key
if [ -n "${SSH_PUBLIC_KEY:-}" ]; then
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh
    printf '%s\n' "$SSH_PUBLIC_KEY" >> /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
fi

# Generate SSH host keys
ssh-keygen -A

# Validate SSH configuration
/usr/sbin/sshd -t

echo "Ubuntu: 24.04"
echo "Python: $(python3 --version)"
echo "Node: $(node --version)"
echo "NPM: $(npm --version)"
echo "Git: $(git --version)"
echo "Java: $(java -version 2>&1 | head -n 1)"

echo "=================================="
echo "Starting SSH server..."
echo "=================================="

exec /usr/sbin/sshd -D -e
EOF

RUN chmod +x /usr/local/bin/start-vps

# ==========================================
# SSH PORT
# ==========================================

EXPOSE 22

# ==========================================
# START VPS
# ==========================================

ENTRYPOINT ["/usr/local/bin/start-vps"]
