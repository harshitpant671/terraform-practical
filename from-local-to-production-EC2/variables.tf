variable "ec2_instance_type" {
    default = "t3.micro"
    type = string
    description = "EC2 instance type"
}

variable "ec2_default_root_storage_size" {
    default = 10
    type = number
    description = "Root storage size"
}

variable "ec2_ami_id" {
    default = "AMI_ID"
    type = string
    description = "EC2 AMI ID"
}

variable "env" {
    default = "production"
    type = string
}

