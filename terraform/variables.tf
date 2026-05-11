# ── Provider ──────────────────────────────────────────────────
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

# ── Project ───────────────────────────────────────────────────
variable "project_name" {
  description = "Project name used in resource name prefixes"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev / staging / prod)"
  type        = string
}

# ── VPC ───────────────────────────────────────────────────────
variable "vpc_name" {
  description = "Human-readable VPC name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "azs" {
  description = "Availability zones to distribute subnets across"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to create a NAT Gateway"
  type        = bool
}

variable "create_eip" {
  description = "Whether to create an Elastic IP for NAT Gateway"
  type        = bool
}

variable "ec2_ingress_rules" {
  description = "Ingress rules for the EC2 security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string))
  }))
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

# ── EC2 ───────────────────────────────────────────────────────
variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "AWS key pair name for SSH access"
  type        = string
}

variable "enable_ssm" {
  description = "Whether to attach SSM IAM role to EC2"
  type        = bool
}