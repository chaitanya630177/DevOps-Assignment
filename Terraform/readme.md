form AWS Infrastructure Project
This repository provisions a scalable AWS infrastructure using Terraform, including:

VPC with public and private subnets
EC2 Auto Scaling Group behind an Application Load Balancer (ALB)
RDS PostgreSQL database
ECR for Docker image storage
IAM Roles with least privilege access

The infrastructure is modular, configurable via variables, and suitable for production-grade deployments.
Prerequisites

AWS account with IAM user credentials (Access Key and Secret Key)
Terraform installed (v1.5 or later)
Docker installed
AWS CLI configured
Git installed

Setup Instructions

Clone the Repository:
git clone https://github.com/your-username/terraform-aws-infra.git
cd terraform-aws-infra


Configure AWS Credentials:Set up your AWS CLI:
aws configure

Enter your Access Key ID, Secret Access Key, region (e.g., us-east-1), and output format.

Update Variables:Edit terraform.tfvars to customize values like project_name, region, db_username, db_password, etc. Ensure db_password is secure and not committed to version control.

Build and Push Docker Image to ECR:

Build the Docker image:docker build -t demo-infra .


Authenticate Docker with ECR:aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ECR_REPOSITORY_URL>

Replace <ECR_REPOSITORY_URL> with the output from terraform output ecr_repository_url after applying Terraform.
Tag and push the image:docker tag demo-infra:latest <ECR_REPOSITORY_URL>:latest
docker push <ECR_REPOSITORY_URL>:latest




Initialize Terraform:
terraform init


Review the Plan:
terraform plan


Apply the Configuration:
terraform apply

Confirm with yes when prompted.

Access the Application:

Get the ALB DNS name:terraform output alb_dns_name


Open the URL in a browser to see the Flask app response (Hello from Flask on ECS!).


Verify RDS Connectivity:

Use the RDS endpoint:terraform output rds_endpoint


Connect using a PostgreSQL client (e.g., psql):psql -h <RDS_ENDPOINT> -U admin -d mydb




Clean Up:Destroy resources to avoid charges:
terraform destroy

Confirm with yes. Manually delete ECR images if necessary.


Real-Time Experience Demonstration
To showcase a real-time provisioning experience during your presentation:

Prepare the Environment:

Ensure AWS credentials are configured.
Clone the repository and review terraform.tfvars.


Live Demo Steps:

Run terraform init to initialize.
Run terraform plan to show the planned resources.
Run terraform apply to provision the infrastructure live (takes ~5-10 minutes).
Show the ALB DNS name (terraform output alb_dns_name) and open it in a browser.
Demonstrate scaling by updating asg_desired_capacity in terraform.tfvars and re-running terraform apply.
Connect to the RDS instance using psql to show database connectivity.


Highlight Modularity:

Explain the modules/ directory structure and how each module (VPC, EC2_ASG, ALB, RDS, ECR, IAM) encapsulates specific resources.
Show how variables in variables.tf and terraform.tfvars make the setup configurable.


Show Outputs:

Display outputs (alb_dns_name, ecr_repository_url, rds_endpoint) to demonstrate infrastructure details.


Clean Up Live:

Run terraform destroy to show resource cleanup, emphasizing cost management.



Project Structure

modules/: Reusable Terraform modules for VPC, EC2 ASG, ALB, RDS, ECR, and IAM.
scripts/user_data.sh: User data script to configure EC2 instances with Docker and pull the image from ECR.
app/app.py: Sample Flask application for the Docker container.
Dockerfile: Builds the Docker image for ECR.
main.tf: Ties all modules together.
variables.tf and terraform.tfvars: Define and set configurable variables.
outputs.tf: Outputs key infrastructure details.
.gitignore: Excludes sensitive files from version control.
README.md: This file with deployment instructions.

Notes

Security: IAM roles follow least privilege principles. Sensitive data like db_password is marked as sensitive in Terraform.
Cost: Be cautious of AWS charges. Use the AWS Free Tier where possible and destroy resources after use.
Modularity: Modules allow reuse across projects. Update terraform.tfvars for different environments (e.g., dev, prod).
Real-Time Demo Tips:
Practice the deployment beforehand to ensure smooth execution.
Use a projector or screen share to show terminal commands and browser output.
Explain each step to the audience, focusing on Infrastructure as Code benefits (repeatability, version control, automation).



Troubleshooting

Permission Errors: Ensure your IAM user has permissions for VPC, EC2, ALB, RDS, ECR, and IAM resources.
ECR Push Issues: Verify AWS CLI is configured and the ECR repository URL is correct.
ALB Not Responding: Check security groups and ensure the Docker container is running on port 5000.
RDS Connectivity: Verify the EC2 security group allows outbound traffic to RDS port 5432.

For further details, refer to the Terraform AWS provider documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs

