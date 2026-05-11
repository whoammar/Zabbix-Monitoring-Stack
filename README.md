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
│   └── docker-compose.yml        # Zabbix Server + Web + PostgreSQL + Grafana
└── terraform/
    ├── main.tf                   # Calls VPC + EC2 modules
    ├── variables.tf              # Variable declarations
    ├── terraform.tfvars          # Your actual values (gitignored)
    ├── terraform.tfvars.example  # Safe placeholder for version control
    ├── outputs.tf                # EC2 IP, URLs, SSH command
    └── script.sh                 # EC2 user-data bootstrap script
```

---

## 🏗️ Architecture Overview

```
                        ┌─────────────────────────────────┐
                        │         AWS (us-east-1)          │
                        │                                  │
                        │  ┌──────────────────────────┐   │
                        │  │     VPC 10.0.0.0/16      │   │
                        │  │                          │   │
                        │  │  ┌────────────────────┐  │   │
                        │  │  │   Public Subnet     │  │   │
                        │  │  │   10.0.1.0/24       │  │   │
                        │  │  │                    │  │   │
                        │  │  │  ┌──────────────┐  │  │   │
                        │  │  │  │  EC2 t3.med  │  │  │   │
                        │  │  │  │              │  │  │   │
                        │  │  │  │ [Zabbix Srv] │  │  │   │
                        │  │  │  │ [Zabbix Web] │  │  │   │
                        │  │  │  │ [PostgreSQL] │  │  │   │
                        │  │  │  │ [Grafana]    │  │  │   │
                        │  │  │  └──────────────┘  │  │   │
                        │  │  └────────────────────┘  │   │
                        │  └──────────────────────────┘   │
                        └─────────────────────────────────┘
                                        ↑
                              Zabbix Agents (port 10051)
                              installed on target servers
```

---

## 🚀 How It Works

1. **Terraform** provisions a VPC, subnets, security groups, and an EC2 instance on AWS
2. **`script.sh`** runs automatically as EC2 user-data on first boot
3. **script.sh** installs Docker → clones this repo → runs `docker compose up -d`
4. **Docker Compose** spins up 4 containers: Zabbix Server, Zabbix Web, PostgreSQL, Grafana
5. **Zabbix Agents** on target servers connect back to the Zabbix Server on port `10051`

---

## 🐳 Docker Services

| Container | Image | Port | Purpose |
|---|---|---|---|
| `zabbix-postgres` | postgres:15-alpine | 5432 | Database |
| `zabbix-server` | zabbix-server-pgsql:6.4 | 10051 | Core monitoring server |
| `zabbix-web` | zabbix-web-nginx-pgsql:6.4 | 80 | Web UI |
| `zabbix-grafana` | grafana/grafana:latest | 3000 | Dashboards |

---

## 🔐 Default Credentials

| Service | URL | Username | Password |
|---|---|---|---|
| Zabbix Web | `http://<EC2_IP>:80` | `Admin` | `zabbix` |
| Grafana | `http://<EC2_IP>:3000` | `admin` | `admin123` |

> ⚠️ Change these immediately after first login in production.

---

## 🛠️ Prerequisites

- AWS account with programmatic access configured (`aws configure`)
- Terraform >= 1.3
- An AWS Key Pair (set `key_name` in `terraform.tfvars`)
- Git

---

## ⚙️ Deployment

### 1. Clone the repo

```bash
git clone https://github.com/whoammar/Zabbix-Monitoring-Stack.git
cd Zabbix-Monitoring-Stack/terraform
```

### 2. Create your tfvars

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
aws_region    = "us-east-1"
key_name      = "your-keypair-name"
ami_id        = "ami-xxxxxxxxxxxxxxxxx"
instance_type = "t3.medium"
```

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 4. Access

After apply completes, wait **3–4 minutes** for Docker to pull images and start, then:

```
Zabbix Web  →  http://<EC2_PUBLIC_IP>:80
Grafana     →  http://<EC2_PUBLIC_IP>:3000
```

Terraform will print the exact URLs in the output.

### 5. SSH into EC2

```bash
ssh -i your-keypair.pem ubuntu@<EC2_PUBLIC_IP>
```

---

## 🔒 Security Group — Open Ports

| Port | Protocol | Source | Purpose |
|---|---|---|---|
| `22` | TCP | Your IP only | SSH access |
| `80` | TCP | 0.0.0.0/0 | Zabbix Web UI |
| `443` | TCP | 0.0.0.0/0 | HTTPS |
| `3000` | TCP | 0.0.0.0/0 | Grafana |
| `10051` | TCP | 0.0.0.0/0 | Zabbix agent trap port |

---

## 📡 Adding a Target Server to Monitor

Install Zabbix Agent on any server you want to monitor:

```bash
# Ubuntu/Debian
wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb
dpkg -i zabbix-release_6.4-1+ubuntu22.04_all.deb
apt update && apt install zabbix-agent -y

# Configure it to point to your Zabbix Server
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

This will remove all AWS resources — EC2, VPC, subnets, security groups.

---

## 📦 Terraform Outputs

| Output | Description |
|---|---|
| `zabbix_public_ip` | Public IP of the monitoring EC2 |
| `zabbix_web_url` | Direct URL to Zabbix Web UI |
| `grafana_url` | Direct URL to Grafana |
| `vpc_id` | VPC ID |
| `public_subnet_ids` | Public subnet IDs |
| `ssh_command` | Ready-to-use SSH command |

---

## 🗂️ Reusable Modules Used

This project consumes shared modules from the parent `modules/` directory:

- **`modules/vpc`** — VPC, subnets, IGW, route tables, security groups
- **`modules/ec2`** — EC2 instance, IAM SSM role, key pair, user-data

---

## 📝 Notes

- `terraform.tfvars` is gitignored — never commit real credentials
- Use `terraform.tfvars.example` as a template for new environments
- Timezone in Zabbix Web is set to `Asia/Karachi` — change in `docker-compose.yml` if needed
- Grafana comes with `alexanderzobnin-zabbix-app` plugin pre-installed
```

---
```