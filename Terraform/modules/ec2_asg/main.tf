#defining the Auto Scaling Group and Launch Template
data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
}

resource "aws_launch_template" "main" {
  name          = "${var.project_name}-lt"
  image_id      = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]
  instance_type = var.instance_type
  user_data     = base64encode(file("${path.module}/../../scripts/user_data.sh"))
  iam_instance_profile {
    arn = var.ec2_instance_profile_arn
  }
  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [var.ec2_security_group_id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-ecs-instance"
    }
  }
}

resource "aws_autoscaling_group" "main" {
  name                = "${var.project_name}-asg"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.private_subnet_ids
  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
  target_group_arns = [var.target_group_arn]
  health_check_type = "EC2"
  tags = [
    {
      key                 = "Name"
      value               = "${var.project_name}-asg"
      propagate_at_launch = true
    }
  ]
}
