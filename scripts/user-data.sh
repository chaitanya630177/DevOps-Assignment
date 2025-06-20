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
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/docker",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/docker"
          }
        ]
      }
    }
  }
}
EOF
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Install Fluent Bit (for ELK)
curl https://packages.fluentbit.io/amazonlinux/2/fluent-bit.repo -o /etc/yum.repos.d/fluent-bit.repo
yum install fluent-bit -y
cat <<EOF > /etc/fluent-bit/fluent-bit.conf
[SERVICE]
    Flush        1
    Log_Level    info
    Parsers_File parsers.conf

[INPUT]
    Name              tail
    Path              /var/log/docker
    Parser            json

[OUTPUT]
    Name              es
    Match             *
    Host              elasticsearch
    Port              9200
    Index             chaydemo-logs
    Type              _doc
EOF
cat <<EOF > /etc/fluent-bit/parsers.conf
[PARSER]
    Name   json
    Format json
    Time_Key time
    Time_Format %Y-%m-%dT%H:%M:%S
EOF
systemctl start fluent-bit
systemctl enable fluent-bit

# Pull and run Docker image
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest
docker run -d -p 80:3000 --log-driver=awslogs --log-opt awslogs-region=us-east-1 --log-opt awslogs-group=${log_group_name} --log-opt awslogs-stream={instance_id}/app ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest

