#!/bin/bash
set -e

# ============================================================
#  Biến môi trường — đặt trong Render Environment Variables
#    ROOT_PASSWORD : mật khẩu SSH root  (bắt buộc)
#    BORE_SERVER   : server bore tùy chỉnh (mặc định bore.pub)
#    PORT          : do Render inject tự động
# ============================================================

ROOT_PASSWORD="${ROOT_PASSWORD:-changeme}"
BORE_SERVER="${BORE_SERVER:-bore.pub}"
HTTP_PORT="${PORT:-8080}"

echo "================================================"
echo " [1/4] Đặt mật khẩu root..."
echo "================================================"
echo "root:${ROOT_PASSWORD}" | chpasswd

echo "================================================"
echo " [2/4] Cấu hình SSH server..."
echo "================================================"

# Cho phép root đăng nhập qua password
sed -i 's/#\?PermitRootLogin.*/PermitRootLogin yes/'        /etc/ssh/sshd_config
sed -i 's/#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#\?UsePAM.*/UsePAM no/'                           /etc/ssh/sshd_config

# Tạo host keys nếu chưa có
ssh-keygen -A

echo "================================================"
echo " [3/4] Khởi động SSH daemon..."
echo "================================================"
/usr/sbin/sshd

echo "================================================"
echo " [4/4] Mở bore tunnel SSH (port 22) → ${BORE_SERVER}"
echo "================================================"
echo ""
echo ">>> Sau khi thấy dòng 'listening at ${BORE_SERVER}:XXXXX'"
echo ">>> SSH vào bằng lệnh:"
echo ">>>   ssh root@${BORE_SERVER} -p XXXXX"
echo ""

# Chạy bore ngầm, in port ra log
bore local 22 --to "${BORE_SERVER}" &
BORE_PID=$!

# Giữ container sống bằng HTTP server đơn giản (Render cần HTTP response)
echo "Render SSH Tunnel is running..." > /tmp/index.html
cd /tmp && python3 -m http.server "${HTTP_PORT}" --bind 0.0.0.0 &

# Chờ bore — nếu bore crash thì restart
while true; do
    if ! kill -0 "$BORE_PID" 2>/dev/null; then
        echo "[WARN] bore crashed, restarting..."
        bore local 22 --to "${BORE_SERVER}" &
        BORE_PID=$!
    fi
    sleep 10
done
