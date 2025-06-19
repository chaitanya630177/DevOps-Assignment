form AWS Infrastructure with Node.js and Jenkins CI/CD

This project provisions a scalable AWS infrastructure using Terraform and deploys a Node.js application with a Jenkins CI/CD pipeline. It demonstrates Infrastructure as Code (IaC), containerization, and automated deployment practices, suitable for production.
## Project Overview
The project includes:
- **Infrastructure**:
  - **VPC** with public and private subnets across two availability zones
  - **EC2 Auto Scaling Group** behind an Application Load Balancer (ALB)
  - **RDS PostgreSQL** database
  - **Elastic Container Registry (ECR)** for Docker images
  - **IAM Roles** with least privilege access
- **Application**:
  - A Node.js Express app (`app.js`) containerized with a secure `Dockerfile` (non-root user, minimal image)
  - Unit tests (`app.test.js`) for the application
  - Optional `docker-compose.yml` for local Node.js + PostgreSQL testing
- **CI/CD**:
  - Jenkins pipeline (`Jenkinsfile`) with stages: Test, Build, Deploy, and rollback for failure handling
- **Security**:
  - Non-root Docker user, minimal `node:20-alpine` image
  - Sensitive data (e.g., `db_password`) marked as sensitive in Terraform
  - IAM roles with minimal permissions

The project is modular, configurable via `terraform.tfvars`, and hosted in a GitHub repository for version control.

## Project Structure
- **Terraform Files**:
  - `main.tf`: Ties modules together
  - `variables.tf`, `terraform.tfvars`: Configurable inputs
  - `outputs.tf`: Outputs (ALB DNS, ECR URL, RDS endpoint)
  - `provider.tf`: AWS provider configuration
  - `modules/`: Reusable modules for VPC, EC2 ASG, ALB, RDS, ECR, IAM
- **Application**:
  - `app/app.js`: Node.js Express app
  - `app/package.json`: Dependencies and scripts
  - `app/app.test.js`: Unit tests
  - `Dockerfile`: Containerizes the app
  - `docker-compose.yml`: Local multi-container setup
- **CI/CD**:
  - `Jenkinsfile`: Defines pipeline
  - `scripts/user_data.sh`: Configures EC2 instances
- **Other**:
  - `.gitignore`: Excludes sensitive files
  - `README.md`: This guide

## Prerequisites
Before executing the project, ensure you have:
- **AWS Account** with IAM user credentials (Access Key ID, Secret Access Key)
- **Terraform** (v1.5 or later): [Install](https://www.terraform.io/downloads.html)
- **Docker**: [Install](https://docs.docker.com/get-docker/)
- **AWS CLI**: [Install](https://aws.amazon.com/cli/)
- **Git**: [Install](https://git-scm.com/downloads)
- **Jenkins Server**: Running on an EC2 instance or locally
- **Node.js and npm**: For local testing [Install](https://nodejs.org/)
- **psql** (PostgreSQL client): For RDS testing [Install](https://www.postgresql.org/download/)
- **Text Editor**: e.g., VS Code or `vi`

## Setup Instructions
Follow these steps to set up and execute the project.

### 1. Clone the Repository
Clone the project from GitHub:
```bash
git clone https://github.com/your-username/terraform-aws-infra.git
cd terraform-aws-infra

Replace your-username with your GitHub username.
2. Configure AWS Credentials
Set up the AWS CLI with your IAM user credentials:
aws configure


AWS Access Key ID: Your IAM user’s access key
AWS Secret Access Key: Your IAM user’s secret key
Default region name: us-east-1
Default output format: json

Ensure the IAM user has permissions for:

VPC, EC2, ALB, RDS, ECR, IAM, CloudWatch Logs

3. Set Up Jenkins
Deploy Jenkins to run the CI/CD pipeline.
Install Jenkins
On an Ubuntu EC2 instance or local server:
sudo apt update
sudo apt install openjdk-11-jdk -y
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list
sudo apt update
sudo apt install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins


Access Jenkins at http://<jenkins-server>:8080.
Unlock using the initial admin password:sudo cat /var/lib/jenkins/secrets/initialAdminPassword


Complete the setup wizard, creating an admin user.

Install Dependencies on Jenkins
Ensure the Jenkins server has:

Docker:sudo apt install docker.io -y
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins


AWS CLI:sudo apt install awscli -y


Terraform:wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform --version


Node.js and npm:sudo apt install nodejs npm -y
node --version
npm --version



Install Jenkins Plugins

Go to Manage Jenkins > Manage Plugins.
Install:
Pipeline
Docker Pipeline
AWS Credentials



Configure Jenkins Credentials

Go to Manage Jenkins > Manage Credentials > (global).
Add:
ID: aws-access-key-id, Kind: Secret text, Value: AWS Access Key ID
ID: aws-secret-access-key, Kind: Secret text, Value: AWS Secret Access Key
ID: ecr-registry, Kind: Secret text, Value: ECR URL (e.g., <account-id>.dkr.ecr.us-east-1.amazonaws.com)



Create Jenkins Pipeline

In Jenkins, create a new Pipeline job named chaydemo-infra.
Select Pipeline script from SCM.
Set:
SCM: Git
Repository URL: https://github.com/your-username/terraform-aws-infra.git
Script Path: Jenkinsfile


Save and run the pipeline to test connectivity.

4. Configure Project Variables
Edit terraform.tfvars to set project-specific values:
vi terraform.tfvars

Example content:
region                = "us-east-1"
project_name          = "chaydemo-infra"
vpc_cidr              = "10.0.0.0/16"
public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs  = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones    = ["us-east-1a", "us-east-1b"]
instance_type         = "t3.micro"
asg_min_size          = 1
asg_max_size          = 3
asg_desired_capacity  = 2
db_instance_class     = "db.t3.micro"
db_allocated_storage  = 20
db_engine_version     = "15.0"
db_username           = "admin"
db_password           = "securepassword" # Replace with a secure password
db_name               = "chaitu"


Save with :w and quit with :q.
Vi Editor Issues:
If you can’t save:chmod u+w terraform.tfvars

Check for swap files:ls -a | grep .swp
rm .terraform.tfvars.swp

Use sudo if needed:sudo vi terraform.tfvars





Note: Do not commit terraform.tfvars to GitHub (it’s excluded by .gitignore) to protect db_password.
5. Manual Deployment (Optional)
Test the project manually before relying on Jenkins.
Initialize Terraform
terraform init

Plan Infrastructure
terraform plan

Review the planned resources.
Build and Push Docker Image

Build the Node.js image:docker build -t chaydemo-infra .


Apply Terraform to get the ECR URL:terraform apply

Confirm with yes. This provisions the infrastructure.
Get the ECR URL:terraform output ecr_repository_url


Authenticate with ECR:aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ECR_REPOSITORY_URL>

Replace <ECR_REPOSITORY_URL> with the output.
Tag and push:docker tag chaydemo-infra:latest <ECR_REPOSITORY_URL>:latest
docker push <ECR_REPOSITORY_URL>:latest



Reapply Terraform
If user_data.sh needs the latest image:
terraform apply

Verify Deployment

Get ALB DNS:terraform output alb_dns_name

Open in a browser to see "Hello from Node.js on AWS!".
Verify RDS:terraform output rds_endpoint
psql -h <RDS_ENDPOINT> -U admin -d chaitu

Enter the db_password from terraform.tfvars.

Local Testing (Optional)
Test locally with docker-compose.yml:
docker-compose up --build


Access the app at http://localhost:3000.
Connect to PostgreSQL:psql -h localhost -U admin -d chaitu

Password: chay (from docker-compose.yml).
Stop:docker-compose down



6. Execute CI/CD Pipeline with Jenkins
The Jenkins pipeline automates testing, building, and deploying.
Trigger Pipeline

Push changes to the main branch:git add .
git commit -m "Update application code"
git push origin main


In Jenkins, monitor the pipeline (chaydemo-infra) in the UI.

Pipeline Stages

Test: Runs npm test to execute unit tests (app.test.js).
Build: Builds the Docker image, tags it with the Git commit SHA and latest, and pushes to ECR.
Deploy: Applies Terraform changes and checks ALB health with curl. If it fails, triggers rollback.
Rollback: Reverts user_data.sh to the previous image tag and reapplies Terraform.

Verify Pipeline Output

In Jenkins, view logs to confirm each stage.
Check the ALB DNS in a browser after deployment.

7. Demonstrate Rollback
Simulate a deployment failure to show rollback:

Edit app.js to return a 500 status:app.get('/', (req, res) => {
  res.status(500).send('Error');
});


Commit and push:git add app/app.js
git commit -m "Introduce failing app"
git push origin main


Monitor Jenkins: The Deploy stage fails (ALB health check), triggering Rollback.
Verify the ALB DNS returns to "Hello from Node.js on AWS!" after rollback.

8. Real-Time Presentation Demo
Showcase the project live for your presentation.
Preparation

Set up Jenkins and push code to GitHub.
Test manual deployment and pipeline execution.
Prepare a diagram (e.g., via draw.io) showing VPC, EC2 ASG, ALB, RDS, ECR, and Jenkins CI/CD.

Demo Steps

Show Repository:
Open GitHub to display the project structure.
Highlight Jenkinsfile, Dockerfile, app.js, and Terraform modules.


Run Pipeline:
Push a code change to trigger Jenkins.
Show Jenkins UI with Test, Build, Deploy stages.


Display Application:
Run:terraform output alb_dns_name


Open in a browser.


Simulate Failure:
Push a failing app.js (500 status).
Show rollback in Jenkins restoring the app.


Scale Infrastructure:
Edit terraform.tfvars:asg_desired_capacity = 3


Commit and push to show Terraform applying changes.


Verify RDS:
Connect with psql using terraform output rds_endpoint.


Local Testing:
Run docker-compose up to show local setup.


Clean Up:
Run:terraform destroy


Confirm with yes.



Talking Points

IaC: Terraform’s repeatability and modularity.
CI/CD: Jenkins automation for testing, building, deploying.
Security: Non-root Docker, minimal image, IAM least privilege.
Rollback: Failure handling for reliability.
Scalability: Auto Scaling Group and ALB.
Real-Time: Live provisioning and deployment.

9. Clean Up
Avoid AWS charges by destroying resources:
terraform destroy

Confirm with yes. Manually delete ECR images if needed:
aws ecr delete-repository --repository-name chaydemo-infra-repo --region us-east-1 --force

Troubleshooting

Vi Editor:
Can’t save files? Check permissions:chmod u+w <file>

Remove swap files:rm .<file>.swp

Use sudo vi <file>.


Jenkins:
Pipeline fails? Check credentials and ensure Docker, AWS CLI, Terraform, Node.js are installed.
View logs in Jenkins UI.


Terraform:
Variable prompts? Ensure terraform.tfvars is complete.
Permission errors? Verify IAM user permissions.


ECR:
Push fails? Check AWS CLI configuration and ECR URL.


ALB:
No response? Verify security groups allow port 80; ensure Docker runs on port 3000.


RDS:
Can’t connect? Check EC2 security group allows port 5432 to RDS.



Notes

Security: Use a secure db_password in terraform.tfvars. Avoid committing sensitive files.
Cost: Use AWS Free Tier (t3.micro, db.t3.micro). Always run terraform destroy.
Assignment: Meets requirements for Terraform, Node.js, secure Docker, Jenkins CI/CD with rollback.
Presentation:
Practice demo steps.
Use screen sharing to show terminal, Jenkins, and browser.
Explain each component’s role.



Resources

Terraform AWS Provider
Jenkins Documentation
Docker Documentation
AWS CLI
Node.js
PostgreSQL


