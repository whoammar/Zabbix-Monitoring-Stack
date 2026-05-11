output "zabbix_public_ip" {
  description = "Public IP of the Zabbix monitoring EC2"
  value       = module.ec2.public_ip
}

output "zabbix_web_url" {
  description = "Zabbix Web UI URL"
  value       = "http://${module.ec2.public_ip}:80"
}

output "grafana_url" {
  description = "Grafana Dashboard URL"
  value       = "http://${module.ec2.public_ip}:3000"
}

output "vpc_id" {
  description = "VPC ID created for Zabbix stack"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "ssh_command" {
  description = "SSH command to connect to Zabbix server"
  value       = "ssh -i Zabbix-Monitoring.pem ubuntu@${module.ec2.public_ip}"
}