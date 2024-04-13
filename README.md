# Terraform

# Terraform AWS ECS Infrastructure

This Terraform configuration sets up AWS ECS (Elastic Container Service) infrastructure including an ECR repository, ECS cluster, task definition, IAM roles, ECS service, ALB (Application Load Balancer), target group, listener, and security groups.

## Requirements

- Terraform >= 1.2.0
- AWS provider version ~> 5.16

## Usage

1. Clone this repository.
2. Make sure you have configured AWS credentials.
3. Update the Terraform variables and resource configurations as needed.
4. Run `terraform init` to initialize the Terraform working directory.
5. Run `terraform plan` to review the planned changes.
6. Run `terraform apply` to apply the changes and create the infrastructure.

## Configuration

The main Terraform configuration file `main.tf` defines the infrastructure resources including:

- ECR Repository
- ECS Cluster
- ECS Task Definition
- IAM Roles and Policies
- ECS Service
- ALB (Application Load Balancer)
- Target Group
- Listener
- Security Groups

## License
