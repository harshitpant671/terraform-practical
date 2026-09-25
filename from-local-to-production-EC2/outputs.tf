# Public IP of EC2 Instance
output "INSTANCE_PUBLIC_IP" {
  # when use meta argument "count" 
  value       = aws_instance.my-instance[*].public_ip

  # Without meta argument
  value       = aws_instance.my-instance.public_ip  
  description = "Public IP of EC2 Instance"
}

# Private IP of EC2 Instance
output "INSTANCE_PRIVATE_IP" {
  value       = aws_instance.my-instance[*].private_ip
  description = "Private IP of EC2 Instance"
}

# Public DNS Name of EC2 Instance
output "INSTANCE_PUBLIC_DNS_NAME" {
  value       = aws_instance.my-instance[*].public_dns
  description = "Public DNS Name of EC2 Instance"
}

# When use "for_each" meta argument 
output "INSTANCE_PUBLIC_IP" {
  value = {
    for instance in aws_instance.my-instance : instance.public_ip
  }
}