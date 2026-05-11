provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  vpc_name     = var.vpc_name
  vpc_cidr     = var.vpc_cidr

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.azs

  enable_nat_gateway = var.enable_nat_gateway
  create_eip         = var.create_eip

  # Only EC2 SG needed — no ELB, app, or DB SG for Zabbix
  create_ec2_sg = true
  create_elb_sg = false
  create_app_sg = false
  create_db_sg  = false

  ec2_ingress_rules = var.ec2_ingress_rules

  create_db_subnet_group = false

  tags = var.tags
}

module "ec2" {
  source = "../../modules/ec2"

  ami_id        = var.ami_id
  instance_name = var.instance_name
  instance_type = var.instance_type
  key_name      = var.key_name
  environment   = var.environment
  enable_ssm    = var.enable_ssm

  user_data = file("script.sh")

  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.vpc.ec2_sg_id]
}