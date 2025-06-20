'''bash
#!/bin/bash
# Install Docker
yum update -y
amazon-linux-extras install docker -y
service docker start
usermod -aG docker ec2-user

# Install CloudWatch Agent
yum install -y amazon-cloudwatch-agent
cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "metrics": {
    "namespace": "ChayDemo/Custom",
    "metrics_collected": {
      "cpu": {
        "measurement": [
          "cpu_usage_active",
          "cpu_usage_iowait"
        ]
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ]
      }
    }
  }
}
EOF
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Pull and run Docker image
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest
docker run -d -p 80:3000 ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest
```
