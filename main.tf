# Provider Configuration
provider "aws" {
  region = var.region
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  app_name           = var.app_name
}

# ALB Module
module "alb" {
  source = "./modules/alb"
  app_name        = var.app_name
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
}

# ASG Module
module "asg" {
  source = "./modules/asg"
  app_name           = var.app_name
  vpc_id             = module.vpc.vpc_id
  private_subnets    = module.vpc.private_subnets
  alb_security_group = module.alb.alb_security_group
  target_group_arn   = module.alb.target_group_arn
  instance_type      = var.instance_type
  ecr_repository_url = module.ecr.repository_url
}

# RDS Module
module "rds" {
  source = "./modules/rds"
  app_name            = var.app_name
  vpc_id              = module.vpc.vpc_id
  private_subnets     = module.vpc.private_subnets
  ec2_security_group  = module.asg.ec2_security_group
  db_engine           = var.db_engine
  db_instance_class   = var.db_instance_class
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"
  app_name = var.app_name
}
