'''hcl
# Defining CloudWatch Log Group for Centralized Logging
resource "aws_cloudwatch_log_group" "app" {
  name              = "/${var.project_name}/app"
  retention_in_days = 7
  tags = {
    Name = "${var.project_name}-app-logs"
  }
}
```
