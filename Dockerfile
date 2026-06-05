# ============================================================
#  SSH access on Render.com via Serveo.net reverse tunnel
#  Serveo dùng SSH thuần — ổn định hơn bore.pub
# ============================================================
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server \
    openssh-client \
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    python3 \
    bash \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Tạo thư mục run cho SSH
RUN mkdir -p /run/sshd

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
