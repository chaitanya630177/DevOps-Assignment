'''bash
#!/bin/bash
# Install Docker and pull image from ECR
yum update -y
amazon-linux-extras install docker -y
service docker start
usermod -a -G docker ec2-user
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPOSITORY_URL}
docker run -d -p 80:3000 ${ECR_REPOSITORY_URL}:latest
```
