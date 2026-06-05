# ============================================================
#  SSH access on Render.com via bore reverse tunnel
#  Render chỉ expose HTTP — bore tunnel SSH port ra ngoài
# ============================================================
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# --- Cài SSH server + công cụ cơ bản ---
RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    python3 \
    unzip \
    bash \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# --- Cài bore v0.5.3 (reverse TCP tunnel) ---
RUN curl -fsSL \
    https://github.com/ekzhang/bore/releases/download/v0.5.3/bore-v0.5.3-x86_64-unknown-linux-musl.tar.gz \
    | tar xz -C /usr/local/bin \
    && chmod +x /usr/local/bin/bore

# --- Tạo thư mục run cho SSH ---
RUN mkdir -p /run/sshd

# --- Copy entrypoint ---
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Render yêu cầu HTTP — python3 http.server giữ container sống
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
