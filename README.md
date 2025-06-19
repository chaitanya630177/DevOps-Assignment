# Terraform AWS Infrastructure Project

This repository provisions a scalable AWS infrastructure using Terraform and deploys a Node.js application. It includes:
- **VPC** with public and private subnets
- **EC2 Auto Scaling Group** behind an Application Load Balancer (ALB)
- **RDS PostgreSQL** database
- **ECR** for Docker image storage
- **IAM Roles** with least privilege access
- **Node.js App** containerized with security best practices

The infrastructure is modular, configurable, and suitable for production-grade deployments.

## Prerequisites
- AWS account with IAM user credentials
- Terraform (v1.5+)
- Docker
- AWS CLI
- Git
- Node.js (optional, for local testing)

## Setup Instructions
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/chaitanya630177/DevOps-Assignment.git
   cd  Devops-Assignment




Configure AWS Credentials:
aws configure

Set Access Key ID, Secret Access Key, region (us-east-1), and output format.

Update Variables:Edit terraform.tfvars to customize project_name, region, db_username, db_password, etc. Ensure db_password is secure.

Build and Push Docker Image to ECR:

Build the Node.js image:docker build -t chaydemo-infra .


Authenticate with ECR:aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ECR_REPOSITORY_URL>

Replace <ECR_REPOSITORY_URL> with terraform output ecr_repository_url.
Tag and push:docker tag chaydemo-infra:latest <ECR_REPOSITORY_URL>:latest
docker push <ECR_REPOSITORY_URL>:latest




Initialize Terraform:
terraform init


Review Plan:
terraform plan


Apply Configuration:
terraform apply

Confirm with yes.

Access the Application:

Get ALB DNS:terraform output alb_dns_name


Open in a browser to see "Hello from Node.js on AWS!".


Verify RDS:

Get RDS endpoint:terraform output rds_endpoint


Connect:psql -h <RDS_ENDPOINT> -U admin -d chaitu


Use docker-compose.yml:docker-compose up --build


Access at http://localhost:3000.
Connect to PostgreSQL:psql -h localhost -U admin -d chaitu




Clean Up:
terraform destroy

Confirm with yes. Delete ECR images manually if needed.


Prepare:
Configure AWS credentials.
Clone the repository.



Highlight:
Modularity: modules/ structure.
Configurability: variables.tf, terraform.tfvars.
Security: Non-root Docker user, minimal image.


Clean Up:
Run terraform destroy.



Project Structure

modules/: Terraform modules for VPC, EC2 ASG, ALB, RDS, ECR, IAM.
scripts/user_data.sh: Configures EC2 instances.
app/app.js, app/package.json: Node.js application.
Dockerfile: Containerizes the app.
docker-compose.yml: Optional local multi-container setup.
main.tf, variables.tf, outputs.tf, terraform.tfvars, provider.tf: Terraform configuration.
.gitignore: Excludes sensitive files.
README.md: Deployment guide.





Troubleshooting

Permissions: Ensure IAM user has VPC, EC2, ALB, RDS, ECR, IAM permissions.
ECR Push: Verify AWS CLI and ECR URL.
ALB Issues: Check security groups, Docker port 3000.
RDS: Ensure EC2 security group allows port 5432.

See Terraform Docs for details.```

