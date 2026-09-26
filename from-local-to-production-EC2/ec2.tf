# Key pair (Login)
resource "aws_key_pair" "my_key" {
  key_name   = "KEY_NAME"
  public_key = "System_public_key"
}

# VPC (Virtual Private Cloud)
resource "aws_default_vpc" "default" {
}

# Security Group
resource "aws_security_group" "my_security_group" {
  name        = "SECURITY_GROUP_NAME"
  description = "this will add a terraform generated Security group"
  vpc_id      = aws_default_vpc.default.id

  # Inbound rules

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH open"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP open"
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Flask app"
  }

  # Outbound rules

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic allowed"
  }

  tags = {
    Name = "TAG_NAME"
  }
}

# AWS EC2 Instance
resource "aws_instance" "my-instance" {
  for_each = tomap({
    my_instance_micro = "t2.micro"
    my_instance_medium = "t2.medium"
  })

  depends_on = [
    aws_key_pair.my_key,
    aws_security_group.my_security_group,
  ]
  
  # Meta argument (Dynamic Blocks)
  # count = 2
  key_name = aws_key_pair.my_key.key_name

  # Correct way to attach Security Group to VPC EC2
  vpc_security_group_ids = [
    aws_security_group.my_security_group.id
  ]

  # instance_type = "t3.micro"
  # instance_type = var.ec2_instance_type  # Without using meta argument

  # using meta argument
  instance_type = each.value

  # Ubuntu 22.04
  # ami = "AMI_ID"
  ami = var.ec2_ami_id

  # user data basically use to run script during the instance creation.
  user_data = file("install_nginx.sh")

  # Root volume storage
  # root_block_device {
  #   volume_size = 15
  #   volume_type = "gp3"
  # }

  root_block_device {
    # using meta argument
    volume_size = var.env == "production" ? 20 : var.ec2_default_root_storage_size # condotional Expression
    volume_type = "gp3"
  }

  tags = {
    # Name = "INSTANCE_NAME" # without meta argument
    Name = each.key
  }
}

# If I want to automate manual created instance in terraform, use terraform import.
# terraform import aws_instance.my-instance <instance-id>

# resource "aws_instance" "my_new_instance" {
#   ami = "unknown"
#   instance_type = "unknown"
# }
