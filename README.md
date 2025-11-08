# Terraform ECS Fargate with Application Load Balancer (ALB)

## Overview

This project provisions a **load-balanced web server environment** on **AWS** using **Terraform**.  
It automates the deployment of an **ECS Fargate service** behind an **Application Load Balancer (ALB)** to provide scalability, high availability, and fault tolerance.

Unlike typical infrastructure provisioning, this setup **uses your existing AWS VPC, subnets, and security groups** to deploy resources — making it ideal for environments where network components are already managed and standardized.

---

## Key Features

- Infrastructure as Code (IaC) using Terraform  
- Uses existing VPC, subnets, and security groups from your AWS environment  
- Application Load Balancer (ALB) for distributing HTTP/HTTPS traffic  
- ECS Fargate for running containerized applications without managing servers  
- Secure network communication through preconfigured security groups  
- CloudWatch integration for container logs and monitoring  
- Simplified deployment using minimal configuration inputs  

---

## Architecture Summary

1. Uses **existing VPC** and **subnets** provided by the user.  
2. Deploys an **Application Load Balancer (ALB)** in the existing public subnets.  
3. Launches an **ECS Fargate service** in the existing private subnets.  
4. Associates ECS tasks and ALB with the provided **security groups**.  
5. Configures task execution roles for accessing ECR and CloudWatch Logs.  
6. Ensures high availability across multiple Availability Zones (AZs).  

---

## Prerequisites

Before deploying, ensure that you have:

1. An **existing VPC** ID.  
2. At least two **public subnets** (for the ALB).  
3. At least two **private subnets** (for the ECS service).  
4. Preconfigured **security groups** for ALB and ECS (with appropriate inbound/outbound rules).  
5. AWS CLI configured or Terraform AWS provider credentials set up.

You will need to provide the following variables in your `terraform.tfvars` file or as input:

```hcl
vpc_id           = "vpc-xxxxxxxxxxxxxx"
public_subnets   = ["subnet-xxxxxxxxxxxx", "subnet-yyyyyyyyyyyy"]
private_subnets  = ["subnet-zzzzzzzzzzzz", "subnet-aaaaaaaaaaaa"]
alb_sg_id        = "sg-xxxxxxxxxxxxxx"
ecs_sg_id        = "sg-yyyyyyyyyyyyyy"
Deployment Steps
Clone this repository:

bash
Copy code
git clone https://github.com/shrigaurav1/Terraform_ECS_ALB.git
cd Terraform_ECS_ALB
Initialize Terraform:

bash
Copy code
terraform init
Review the plan:

bash
Copy code
terraform plan
Apply the configuration:

bash
Copy code
terraform apply
Once the deployment completes, note the ALB DNS name from Terraform output and access it in a web browser to verify the application.

Flow Description
A client sends a request to the Application Load Balancer (ALB).

The ALB forwards the request to the ECS service running in the private subnets.

The ECS service sends the request to the containerized web server running on Fargate.

If a Fargate task or container becomes unavailable, the ALB automatically redirects traffic to healthy tasks.

This ensures continuous availability and fault tolerance for the application.

Tools Used
Terraform – Infrastructure as Code (IaC)

AWS ECS Fargate – Serverless container orchestration

AWS Application Load Balancer (ALB) – Traffic distribution and health checks

AWS VPC – Existing network infrastructure

CloudWatch Logs – Container log monitoring

FOSS (Free and Open Source Software)

Repository
GitHub Link:
https://github.com/shrigaurav1/Terraform_ECS_ALB

This repository includes Terraform code for:

Deploying an ECS Fargate cluster and service

Configuring an Application Load Balancer

Using existing VPC, subnets, and security groups

Setting up IAM roles, log groups, and task definitions

Conclusion
This Terraform configuration provides a modular, secure, and production-ready ECS Fargate deployment that integrates seamlessly with existing AWS networking resources.
By leveraging preconfigured VPCs, subnets, and security groups, it ensures compliance with organizational standards while maintaining flexibility and ease of deployment.

The setup achieves high availability, scalability, and cost efficiency for running containerized applications in AWS.
