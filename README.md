```markdown
# 🔍 Zabbix Monitoring Stack

A production-ready monitoring stack deployed on AWS using Terraform (modular) and Docker Compose.
Includes Zabbix Server, Zabbix Web UI, PostgreSQL, and Grafana — all running as containers on a single EC2 instance.

---

## 📁 Project Structure

```
Zabbix-Monitoring-Stack/
├── .gitignore
├── README.md
├── docker/
│   └── docker-compose.yml
└── terraform/
    ├── main.tf
    ├── variables.tf
    ├── terraform.tfvars
    ├── terraform.tfvars.example
    ├── outputs.tf
    └── script.sh
```

---

## 🚀 How It Works

1. **Terraform** provisions VPC, subnets, security groups, and EC2 on AWS
2. **script.sh** runs automatically on EC2 first boot as user-data
3. **script.sh** installs Docker → clones this repo → runs `docker compose up -d`
4. **Docker Compose** spins up 4 containers: Zabbix Server, Zabbix Web, PostgreSQL, Grafana
5. **Zabbix Agents** on target servers connect back to Zabbix Server on port `10051`

---

## 🐳 Docker Services

| Container | Port | Purpose |
|-----------|------|---------|
| `zabbix-postgres` | 5432 | Database |
| `zabbix-server` | 10051 | Core monitoring server |
| `zabbix-web` | 80 | Web UI |
| `zabbix-grafana` | 3000 | Dashboards |

---

## 🔐 Default Credentials

| Service | URL | Username | Password |
|---------|-----|----------|----------|
| Zabbix Web | `http://<EC2_IP>:80` | `Admin` | `zabbix` |
| Grafana | `http://<EC2_IP>:3000` | `admin` | `admin123` |

> ⚠️ Change these immediately after first login in production.

---

## 🛠️ Prerequisites

- AWS account with programmatic access configured (`aws configure`)
- Terraform >= 1.3
- AWS Key Pair created in your region
- Git

---

## ⚙️ Deployment

**1. Clone the repo**
```bash
git clone https://github.com/whoammar/Zabbix-Monitoring-Stack.git
cd Zabbix-Monitoring-Stack/terraform
```

**2. Create your tfvars**
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values — region, AMI, key pair name, your IP.

**3. Deploy**
```bash
terraform init
terraform plan
terraform apply
```

**4. Access**

Wait 3–4 minutes after apply for Docker to pull images, then open:
```
Zabbix Web  →  http://<EC2_PUBLIC_IP>:80
Grafana     →  http://<EC2_PUBLIC_IP>:3000
```

**5. SSH**
```bash
ssh -i your-keypair.pem ubuntu@<EC2_PUBLIC_IP>
```

---

## 🔒 Security Group Ports

| Port | Source | Purpose |
|------|--------|---------|
| `22` | Your IP only | SSH |
| `80` | 0.0.0.0/0 | Zabbix Web UI |
| `443` | 0.0.0.0/0 | HTTPS |
| `3000` | 0.0.0.0/0 | Grafana |
| `10051` | 0.0.0.0/0 | Zabbix agent trap port |

---

## 📡 Adding a Target Server to Monitor

Install Zabbix Agent on any server you want to monitor:

```bash
wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb
dpkg -i zabbix-release_6.4-1+ubuntu22.04_all.deb
apt update && apt install zabbix-agent -y

sed -i 's/Server=127.0.0.1/Server=<ZABBIX_EC2_IP>/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/ServerActive=127.0.0.1/ServerActive=<ZABBIX_EC2_IP>/' /etc/zabbix/zabbix_agentd.conf

systemctl restart zabbix-agent
systemctl enable zabbix-agent
```

Then in Zabbix Web UI:
```
Configuration → Hosts → Create Host → enter IP → assign template → Save
```

---

## 🧹 Teardown

```bash
terraform destroy
```

---

## 📝 Notes

- `terraform.tfvars` is gitignored — never commit real credentials
- Use `terraform.tfvars.example` as a safe template to commit
- Timezone is set to `Asia/Karachi` — change in `docker-compose.yml` if needed
- Grafana has `alexanderzobnin-zabbix-app` plugin pre-installed
```

---

### What to do now:

1. **Open** `~/Desktop/Terraform Modules Final/Zabbix-Monitoring-Stack/README.md` in VS Code  
2. **Delete** everything inside and paste the above block  
3. **Save** the file  
4. Run these commands in your terminal:

```bash
cd ~/Desktop/Terraform\ Modules\ Final/Zabbix-Monitoring-Stack
git add README.md
git commit -m "Fix markdown formatting for GitHub"
git push -u origin main --force
```
