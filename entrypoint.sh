#!/bin/bash

# ============================================================
#  Biến môi trường — đặt trong Render Environment Variables
#    ROOT_PASSWORD : mật khẩu SSH root (bắt buộc)
#    PORT          : do Render inject tự động
# ============================================================

ROOT_PASSWORD="${ROOT_PASSWORD:-changeme}"
HTTP_PORT="${PORT:-8080}"

echo "================================================"
echo " [1/4] Đặt mật khẩu root..."
echo "================================================"
echo "root:${ROOT_PASSWORD}" | chpasswd

echo "================================================"
echo " [2/4] Cấu hình SSH server..."
echo "================================================"
sed -i 's/#\?PermitRootLogin.*/PermitRootLogin yes/'               /etc/ssh/sshd_config
sed -i 's/#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#\?UsePAM.*/UsePAM no/'                                  /etc/ssh/sshd_config

# Tạo host keys
ssh-keygen -A

echo "================================================"
echo " [3/4] Khởi động SSH daemon..."
echo "================================================"
/usr/sbin/sshd

echo "================================================"
echo " [4/4] Giữ container sống (HTTP server)..."
echo "================================================"
echo "Render SSH Tunnel Running" > /tmp/index.html
cd /tmp && python3 -m http.server "${HTTP_PORT}" --bind 0.0.0.0 &

echo "================================================"
echo " [5/5] Mở Serveo tunnel (auto-reconnect)..."
echo "================================================"
echo ""
echo ">>> Khi thấy dòng 'Forwarding TCP connections from XXXXX.serveo.net'"
echo ">>> SSH vào bằng lệnh:"
echo ">>>   ssh -J serveo.net root@XXXXX.serveo.net"
echo ""

# Tạo SSH key nếu chưa có (cần để kết nối Serveo)
if [ ! -f /root/.ssh/id_rsa ]; then
    mkdir -p /root/.ssh
    ssh-keygen -t rsa -b 2048 -f /root/.ssh/id_rsa -N ""
fi

# Auto-reconnect vô hạn nếu Serveo bị drop
while true; do
    echo "[$(date)] Kết nối tới serveo.net..."
    ssh \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -o ServerAliveInterval=30 \
        -o ServerAliveCountMax=3 \
        -o ExitOnForwardFailure=yes \
        -o ConnectTimeout=15 \
        -T \
        -R 0:localhost:22 \
        serveo.net
    echo "[$(date)] Serveo bị ngắt — thử lại sau 5 giây..."
    sleep 5
done
