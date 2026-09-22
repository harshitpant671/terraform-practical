# Terraform AWS EC2 — Local to AWS

This project demonstrates how to provision an **AWS EC2 instance from a local Windows machine using Terraform**.

## Architecture

```text
Local Windows Machine
        |
        | Terraform
        v
      AWS
        |
        +-- Default VPC
        |
        +-- Key Pair
        |
        +-- Security Group
        |     +-- SSH   : 22
        |     +-- HTTP  : 80
        |     +-- Flask : 8000
        |
        +-- EC2 Instance
              +-- t3.micro
              +-- Ubuntu 22.04
              +-- 15 GB GP3
```

## Prerequisites

- AWS Account
- Terraform
- AWS CLI
- Git Bash
- SSH

Verify Terraform:

```bash
terraform version
```

Verify AWS CLI:

```bash
aws --version
```

## Configure AWS CLI

Configure your AWS credentials:

```bash
aws configure
```

Use:

```text
AWS Access Key ID:     <your-access-key>
AWS Secret Access Key: <your-secret-key>
Default region:        ap-south-1
Default output:        json
```

Verify the credentials:

```bash
aws sts get-caller-identity
```

## Project Structure

```text
terraform-practical/
├── README.md
├── provider.tf
├── ec2.tf
└── .gitignore
```

## Terraform Provider

Create `provider.tf`:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.6.0"
}

provider "aws" {
  region = "ap-south-1"
}
```

## EC2 Configuration

Create `ec2.tf`:

```hcl
# Key pair
resource "aws_key_pair" "my_key" {
  key_name   = "terra-key-ec2"
  public_key = "YOUR_PUBLIC_SSH_KEY"
}

# Default VPC
resource "aws_default_vpc" "default" {
}

# Security Group
resource "aws_security_group" "my_security_group" {
  name        = "automate-sg"
  description = "this will add a terraform generated Security group"
  vpc_id      = aws_default_vpc.default.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH open"
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP open"
  }

  # Flask application
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Flask app"
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic allowed"
  }

  tags = {
    Name = "automate-sg"
  }
}

# EC2 Instance
resource "aws_instance" "my-instance" {
  ami           = "ami-01a00762f46d584a1"
  instance_type = "t3.micro"

  key_name = aws_key_pair.my_key.key_name

  vpc_security_group_ids = [
    aws_security_group.my_security_group.id
  ]

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
  }

  tags = {
    Name = "hp-ec2-instance"
  }
}
```

> Replace `YOUR_PUBLIC_SSH_KEY` with your actual SSH public key.

Generate an Ed25519 key if needed:

```bash
ssh-keygen -t ed25519
```

View the public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

## Terraform Workflow

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Format the configuration

```bash
terraform fmt
```

### 3. Validate the configuration

```bash
terraform validate
```

Expected:

```text
Success! The configuration is valid.
```

### 4. Create the execution plan

```bash
terraform plan
```

Review the resources before applying them.

### 5. Create the AWS infrastructure

```bash
terraform apply
```

Enter:

```text
yes
```

when Terraform asks for confirmation.

## Verify Resources

List Terraform-managed resources:

```bash
terraform state list
```

Expected resources:

```text
aws_default_vpc.default
aws_instance.my-instance
aws_key_pair.my_key
aws_security_group.my_security_group
```

Check the Security Group:

```bash
terraform state show aws_security_group.my_security_group
```

Check the EC2 instance:

```bash
terraform state show aws_instance.my-instance
```

## Get the EC2 Public IP

Using AWS CLI:

```bash
aws ec2 describe-instances \
  --region ap-south-1 \
  --filters "Name=tag:Name,Values=hp-ec2-instance" \
  --query "Reservations[*].Instances[*].PublicIpAddress" \
  --output text
```

## Connect to EC2 Using SSH

For an Ubuntu instance:

```bash
ssh -i ~/.ssh/id_ed25519 ubuntu@YOUR_PUBLIC_IP
```

Replace `YOUR_PUBLIC_IP` with the EC2 public IP.

After connecting:

```bash
whoami
```

Check the operating system:

```bash
cat /etc/os-release
```

Check disk space:

```bash
df -h
```

## Security Group Ports

| Port | Protocol | Purpose |
|---|---|---|
| 22 | TCP | SSH |
| 80 | TCP | HTTP |
| 8000 | TCP | Flask application |

> For production environments, avoid opening SSH to `0.0.0.0/0`. Restrict port 22 to trusted IP addresses.

## Important: `vpc_security_group_ids`

For the EC2 instance, this project uses:

```hcl
vpc_security_group_ids = [
  aws_security_group.my_security_group.id
]
```

This passes the Security Group ID to the EC2 instance.

Example:

```text
sg-0bf5098dd3c404832
```

Do not replace it with the security group's name.

## Useful Terraform Commands

Initialize:

```bash
terraform init
```

Format:

```bash
terraform fmt
```

Validate:

```bash
terraform validate
```

Plan:

```bash
terraform plan
```

Apply:

```bash
terraform apply
```

Show state:

```bash
terraform show
```

List resources:

```bash
terraform state list
```

Show a resource:

```bash
terraform state show aws_instance.my-instance
```

Destroy resources:

```bash
terraform destroy
```

## Destroy the Infrastructure

When the practical is complete, destroy the resources to avoid unnecessary AWS charges:

```bash
terraform destroy
```

Confirm with:

```text
yes
```

Then verify that the EC2 instance has been terminated in AWS.

## `.gitignore`

Create a `.gitignore` file:

```gitignore
# Terraform
.terraform/
*.tfstate
*.tfstate.*
crash.log
crash.*.log

# Variables
*.tfvars
*.tfvars.json

# SSH private keys
*.pem
id_rsa
id_rsa.pub
id_ed25519
id_ed25519.pub

# Environment files
.env

# VS Code
.vscode/

# Windows
Thumbs.db
Desktop.ini
```

## Security Notes

Never commit the following to GitHub:

- AWS Access Key
- AWS Secret Access Key
- SSH private key
- `terraform.tfstate`
- Sensitive `.tfvars` files

Use environment variables, AWS profiles, or a secure CI/CD secret store for credentials.

## Troubleshooting

### Terraform command not found

If Git Bash shows:

```text
terraform: command not found
```

and Terraform is installed at `C:\terraform`, run:

```bash
export PATH="/c/terraform:$PATH"
```

Then verify:

```bash
terraform version
```

To make the Git Bash PATH change persistent:

```bash
echo 'export PATH="/c/terraform:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### AWS credentials error

Run:

```bash
aws configure
```

Then:

```bash
aws sts get-caller-identity
```

### Security Group ID error

Make sure the EC2 resource contains:

```hcl
vpc_security_group_ids = [
  aws_security_group.my_security_group.id
]
```

Then run:

```bash
terraform fmt
terraform validate
terraform plan
```

## Current Project Configuration

| Resource | Configuration |
|---|---|
| AWS Region | `ap-south-1` |
| EC2 Type | `t3.micro` |
| OS | Ubuntu 22.04 |
| Root Volume | 15 GB GP3 |
| Key Pair | `terra-key-ec2` |
| Security Group | `automate-sg` |
| SSH Port | `22` |
| HTTP Port | `80` |
| Flask Port | `8000` |

## Terraform Deployment Flow

```text
terraform init
       |
       v
terraform fmt
       |
       v
terraform validate
       |
       v
terraform plan
       |
       v
terraform apply
       |
       v
    AWS EC2
       |
       v
   SSH Access
       |
       v
terraform destroy
```

## Project Objective

The objective of this project is to understand Infrastructure as Code (IaC) and learn how to provision AWS infrastructure from a local machine using Terraform.

### Technologies Used

- Terraform
- AWS
- Amazon EC2
- Amazon VPC
- AWS Security Groups
- AWS Key Pair
- AWS CLI
- Git Bash
- Windows
