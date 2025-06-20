form AWS Infrastructure Project

This project provisions a secure, highly available AWS infrastructure using Terraform, deploys a Node.js application in Docker containers, and automates deployments with a Jenkins CI/CD pipeline. It incorporates security best practices, monitoring, logging, and debugging capabilities, making it a production-ready solution for a scalable web application.

## Table of Contents
- [Project Overview](#project-overview)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Deployment with Terraform](#deployment-with-terraform)
- [CI/CD Pipeline](#cicd-pipeline)
- [Monitoring and Alerts](#monitoring-and-alerts)
- [Logging and Debugging](#logging-and-debugging)
- [Design Decisions](#design-decisions)
- [Architecture Trade-offs](#architecture-trade-offs)
- [Challenges Faced](#challenges-faced)
- [Testing the Setup](#testing-the-setup)
- [Presentation Demo](#presentation-demo)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)
- [Resources](#resources)

## Project Overview
- **Infrastructure**:
  - VPC with public and private subnets across two Availability Zones (AZs)
  - EC2 Auto Scaling Group (ASG) for dynamic scaling
  - Application Load Balancer (ALB) with HTTPS
  - RDS PostgreSQL with encryption
  - Elastic Container Registry (ECR) for Docker images
  - IAM roles with least privilege
- **Application**:
  - Node.js Express app with JSON-structured logging
  - Unit tests for reliability
  - Dockerized for consistency
- **CI/CD**:
  - Jenkins pipeline for testing, building, deploying, and rollback
- **Security**:
  - HTTPS via AWS Certificate Manager (ACM)
  - SSH restricted to specific IP
  - Secrets stored in AWS Systems Manager Parameter Store
  - Non-root containers, no privileged mode
  - Encryption at rest and in transit for RDS and app data
- **Monitoring**:
  - Amazon CloudWatch for CPU, memory, request rates, error rates
  - Optional Prometheus + Grafana for dashboards
  - CloudWatch Alarms with SNS email notifications
- **Logging**:
  - CloudWatch Logs for JSON-structured app logs
  - Optional self-hosted ELK Stack with Fluent Bit



## Prerequisites
- AWS account with IAM user (permissions: VPC, EC2, ALB, RDS, ECR, IAM, ACM, SSM, CloudWatch, SNS)
- Terraform (v1.5+): [Install](https://www.terraform.io/downloads.html)
- Docker: [Install](https://docs.docker.com/get-docker/)
- AWS CLI: [Install](https://aws.amazon.com/cli/)
- Git: [Install](https://git-scm.com/downloads)
- Jenkins server (Ubuntu EC2 recommended)
- Node.js/npm: [Install](https://nodejs.org/)
- psql: [Install](https://www.postgresql.org/download/)
- Text editor (e.g., VS Code, vim)

## Project Structure

terraform
├── modules/
│   ├── vpc/
│   ├── ec2_asg/
│   ├── alb/
│   ├── rds/
│   ├── ecr/
│   ├── iam/
│   ├── monitoring/
│   ├── logging/
├── scripts/
│   ├── user_data.sh
├── app/
│   ├── app.js
│   ├── package.json
│   ├── app.test.js
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── provider.tf
├── Dockerfile
├── docker-compose.yml
├── prometheus.yml
├── fluent-bit.conf
├── Jenkinsfile
├── .gitignore
├── README.md
## Deployment with Terraform
1. **Clone Repository**:
   ```bash
   git clone https://github.com/chaitanya630177/DevOps-Assignment.git
   cd Devops-Assignment


Configure AWS Credentials:
aws configure


Enter Access Key ID, Secret Access Key
Region: us-east-1
Output: json


Set Up Domain:

Register a domain (e.g., via Route 53)
Create ACM certificate in us-east-1:
AWS Console > Certificate Manager > Request certificate
Add domain (e.g., example.com)
Validate via DNS or email


Update terraform.tfvars with domain_name


Configure Variables:
vi terraform.tfvars

region                = "us-east-1"
project_name          = "chaydemo-infra"
vpc_cidr              = "10.0.0.0/16"
public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_ids    = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones    = ["us-east-1a", "us-east-1b"]
instance_type         = "t3.micro"
asg_min_size          = 1
asg_max_size          = 3
asg_desired_capacity  = 2
db_instance_class     = "db.t3.micro"
db_allocated_storage  = 20
db_engine_version     = "15.0"
db_username           = "admin"
db_password           = "securepassword123"
db_name               = "chaitu"
domain_name           = "your-domain.com"
allowed_ssh_ip        = "your-ip/32"
alarm_email           = "vchaitanya4545@gamil.com"


Replace your-domain.com, your-ip/32, your-email@example.com
Save: :w, Quit: :q
Fix vi issues:chmod u+w terraform.tfvars
rm .terraform.tfvars.swp
sudo vi terraform.tfvars




Initialize Terraform:
terraform init


Plan:
terraform plan


Build and Push Docker Image:
docker build -t chaydemo-infra .
terraform apply -auto-approve
export ECR_URL=$(terraform output -raw ecr_repository_url)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL
docker tag chaydemo-infra:latest $ECR_URL:latest
docker push $ECR_URL:latest
terraform apply -auto-approve


Verify Deployment:

ALB: terraform output alb_dns_name → Open https://<ALB_DNS>
RDS:psql "host=$(terraform output -raw rds_endpoint) user=admin dbname=chaitu sslmode=verify-full sslrootcert=ssl/rds-ca-cert.pem"


SSH:ssh -i key.pem ec2-user@<EC2_PUBLIC_IP>





CI/CD Pipeline
The Jenkins pipeline automates testing, building, and deploying the application.

Set Up Jenkins:

Launch Ubuntu EC2 instance
Install Jenkins:sudo apt update
sudo apt install openjdk-11-jdk -y
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list
sudo apt update
sudo apt install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins


Access: http://<server>:8080
Unlock: sudo cat /var/lib/jenkins/secrets/initialAdminPassword


Install Dependencies:
sudo apt install -y docker.io nodejs npm awscli
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins


Configure Jenkins:

Install plugins: Pipeline, Docker Pipeline, AWS Credentials
Add credentials:
aws-access-key-id, aws-secret-access-key
ecr-registry (.dkr.ecr.us-east-1.amazonaws.com)


Create pipeline:
Name: chaydemo-infra
SCM: Git, URL: https://github.com/your-username/terraform-aws-infra.git
Script: Jenkinsfile




Pipeline Stages (Jenkinsfile):

Test: Run npm test for unit tests
Build: Build Docker image, push to ECR
Deploy: Apply Terraform, verify ALB health
Rollback: Revert to previous image on failure


Trigger Pipeline:
git add .
git commit -m "Update app"
git push origin main


Jenkins detects changes, runs pipeline
Monitor: http://<jenkins>:8080



Monitoring and Alerts
Monitoring uses CloudWatch and optional Prometheus + Grafana.

CloudWatch Setup:

Automatically configured via Terraform (monitoring module)
Metrics:
EC2: CPU, memory (via CloudWatch Agent)
ALB: Request rates (RequestCount), error rates (`HTTPCode_ELB_5XX)
RDS: CPU, memory


Alarms:
High CPU (>70%) on EC2 and RDS
ALB 5XX errors >5 in 5 minutes)
Notifications: SNS email (set alarm_email in terraform.tfvars)




Verify Metrics:

AWS Console > CloudWatch > Metrics
Check namespaces: AWS/EC2, AWS/ApplicationELB, AWS/RDS, ChayDemo/Custom


Test Alarms:

Simulate CPU load:ssh -i key.pem ec2-user@<EC2_IP> "stress --cpu 8 --timeout 300"


Simulate ALB errors:app.get('/', (req, res) => res.status(500).send('Error'));

Push to trigger pipeline
Check email for SNS notifications


Prometheus + Grafana (Local):
docker-compose up --build


Grafana: http://localhost:3001 (admin/admin)
Add Prometheus data source: http://prometheus:9090
Create dashboards: CPU, memory, request rates
Stop: docker-compose down


Amazon Managed Grafana (Optional):

AWS Console > Grafana > Create workspace
Add CloudWatch data source
Import dashboards for EC2, ALB, RDS



Logging and Debugging
Logging uses CloudWatch Logs and optional ELK Stack.

CloudWatch Logs:

Configured via Terraform (logging module)
JSON-structured app logs via winston (app.js))
EC2 logs via CloudWatch Agent (user_data.sh))
Log Group: /chaydemo-infra/app


Verify Logs:

AWS Console > CloudWatch > Log Groups > /chaydemo-infra/app
Search: [{"message":"HTTP request"}]


ELK Stack (Local):
docker-compose up --build


Kibana: http://localhost:5601
Create index pattern: chaydemo-logs*
View logs in Discover
Stop: docker-compose down


ELK on EC2 (Optional):

Deploy Elasticsearch/Kibana on EC2
Update fluent-bit.conf with EC2 IP
Open security group for port 9200



Design Decisions

Terraform Modules:
Modular structure for reusability and clarity
Separated VPC, EC2, ALB, RDS, etc., for maintainability


Security:
ACM for free SSL certificates
SSH restricted to specific IP
Parameter Store for secrets
Non-root containers to reduce attack surface


Monitoring:
CloudWatch for simplicity, native AWS integration
Prometheus/Grafana for flexible dashboards


Logging:
CloudWatch Logs for ease of use
ELK Stack for advanced analytics


CI/CD:
Jenkins for customizable pipelines
ECR for secure image management



Architecture Trade-offs

EC2 vs. ECS/EKS:
Chosen: EC2 with Docker for simplicity
Trade-off: ECS/EKS offers better container management but increases complexity


CloudWatch vs. ELK:
Chosen: CloudWatch Logs as primary
Trade-off: ELK provides advanced querying but requires maintenance


Self-hosted vs. Managed Grafana:
Chosen: Local Grafana for testing
Trade-off: Managed Grafana reduces setup but incurs cost


Free Tier vs. Scalability:
Chosen: Free Tier resources (t.micro, db.t.micro)
Trade-off: Limited scalability; upgrade for production



Challenges Faced

ACM Certificate:
Manual validation required; automated DNS validation possible with Route 53


Jenkins Setup:
Dependency installation and credential issues
Resolved: Detailed setup instructions


Logging:
Ensuring JSON structure across logs
Resolved: Used winston and awslogs driver


Vi Issues:
File permissions, .swp files
Resolved: chmod, rm commands


Cost Management:
Risk of exceeding Free Tier
Resolved: Emphasize terraform destroy



Testing the Setup

Security:
HTTPS: Verify certificate
SSH: Test unauthorized IP
Secrets:aws ssm get-parameter --name /chaydemo-infra/rds/password --with-decryption


Containers:docker run -it $ECR_URL:latest whoami

Output: appuser


HA:
Scale: Update asg_desired_capacity
Health Check:sudo docker stop $(sudo docker ps -q)


Load Test:sudo apt install apache2-utils
ab -n 1000 -c 10 https://$(terraform output -raw alb_dns_name)/


Jenkins:
Check credentials, plugins, logs


Terraform:
Verify tfvars, IAM permissions


Monitoring/Logging:
Ensure CloudWatch Agent, Fluent Bit


ALB/RDS:
Check security groups, SSL settings



Cleanup
terraform destroy -auto-approve
aws ecr delete-repository --repository-name chaydemo-infra-repo --region us-east-1 --force

Resources

Terraform
Jenkins
CloudWatch
ELK
Docker




