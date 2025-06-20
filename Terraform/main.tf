#main configuration tying all modules together
provider "aws" {
  region = var.region
}

module "vpc" {
  source              = "./modules/vpc"
  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones  = var.availability_zones
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
}

module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name
}

module "alb" {
  source               = "./modules/alb"
  project_name         = var.project_name
  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.vpc.public_subnet_ids
  alb_security_group_id = module.vpc.alb_security_group_id
}

module "ec2_asg" {
  source                   = "./modules/ec2_asg"
  project_name             = var.project_name
  instance_type            = var.instance_type
  min_size                 = var.asg_min_size
  max_size                 = var.asg_max_size
  desired_capacity         = var.asg_desired_capacity
  private_subnet_ids       = module.vpc.private_subnet_ids
  ec2_security_group_id    = module.vpc.ec2_security_group_id
  ec2_instance_profile_arn = module.iam.ec2_instance_profile_arn
  target_group_arn         = module.alb.target_group_arn
}

module "rds" {
  source                = "./modules/rds"
  project_name          = var.project_name
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  ec2_security_group_id = module.vpc.ec2_security_group_id
  db_instance_class     = var.db_instance_class
  db_allocated_storage  = var.db_allocated_storage
  db_engine_version     = var.db_engine_version
  db_username           = var.db_username
  db_password           = var.db_password
  db_name               = var.db_name
}

module "monitoring" {
  source          = "./modules/monitoring"
  project_name    = var.project_name
  alarm_email     = var.alarm_email
  asg_name        = module.ec2_asg.asg_name
  alb_arn         = module.alb.alb_arn
  rds_identifier  = module.rds.rds_identifier
}
```
