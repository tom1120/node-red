#!/bin/bash
export http_proxy=http://192.168.96.18:7890 && export https_proxy=http://192.168.96.18:7890
apt update
apt install -y curl
curl -fsSL https://repo.pigsty.cc/key | gpg --dearmor -o /etc/apt/keyrings/pigsty.gpg

distro_codename=bookworm
tee /etc/apt/sources.list.d/pigsty-io.list > /dev/null <<EOF
deb [signed-by=/etc/apt/keyrings/pigsty.gpg] https://repo.pigsty.cc/apt/infra generic main
deb [signed-by=/etc/apt/keyrings/pigsty.gpg] https://repo.pigsty.cc/apt/pgsql/${distro_codename} ${distro_codename} main
EOF

apt update
apt install -y pig
pig ext install -y zhparser
pig ext install age
# 测试
