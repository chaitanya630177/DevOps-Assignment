'''hcl
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
}

variable "desired_capacity" {
  description = "Desired number of instances"
  type        = number
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "ec2_instance_profile_arn" {
  description = "ARN of the EC2 instance profile"
  type        = string
}

variable "alb_security_group_id" {
  description = "ID of the ALB security group"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "allowed_ssh_ip" {
  description = "CIDR block allowed for SSH access"
  type        = string
}

variable "log_group_name" {
  description = "Name of the CloudWatch Log Group"
  type        = string
}
```
