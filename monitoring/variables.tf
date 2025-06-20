'''hcl
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "alarm_email" {
  description = "Email for SNS notifications"
  type        = string
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer"
  type        = string
}

variable "rds_identifier" {
  description = "Identifier of the RDS instance"
  type        = string
}
```
