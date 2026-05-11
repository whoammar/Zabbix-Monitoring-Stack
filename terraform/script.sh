#!/bin/bash
set -e

echo "─────────────────────────────────────"
echo " Zabbix Stack Bootstrap Starting..."
echo "─────────────────────────────────────"

# ── 1. System Update ──────────────────────────────────────────
apt-get update -y
apt-get upgrade -y

# ── 2. Install Docker ─────────────────────────────────────────
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    git \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# ── 3. Start & Enable Docker ──────────────────────────────────
systemctl start docker
systemctl enable docker

# ── 4. Clone Your GitHub Repo ─────────────────────────────────
REPO_URL="https://github.com/whoammar/Zabbix-Monitoring-Stack"
CLONE_DIR="/opt/zabbix-stack"

git clone "$REPO_URL" "$CLONE_DIR"

# ── 5. Run Docker Compose ─────────────────────────────────────
cd "$CLONE_DIR/docker"

docker compose up -d

echo "─────────────────────────────────────"
echo " Zabbix Stack is UP!"
echo " Web UI  → http://$(curl -s ifconfig.me):80"
echo " Grafana → http://$(curl -s ifconfig.me):3000"
echo "─────────────────────────────────────"