output "vpc_id" {
  description = "Kubernetes VPC ID"
  value       = aws_vpc.k8s_vpc.id
}

output "vpc_cidr" {
  description = "Kubernetes VPC CIDR"
  value       = aws_vpc.k8s_vpc.cidr_block
}
output "subnet_id" {
  description = "Kubernetes public subnet ID"
  value       = aws_subnet.k8s_public_subnet.id
}

output "subnet_cidr" {
  description = "Kubernetes subnet CIDR"
  value       = aws_subnet.k8s_public_subnet.cidr_block
}
output "igw_id" {
  value = aws_internet_gateway.k8s_igw.id
}

output "route_table_id" {
  value = aws_route_table.k8s_public_rt.id
}

output "master_sg_id" {
  value = aws_security_group.master_sg.id
}

output "worker_sg_id" {
  value = aws_security_group.worker_sg.id
}
output "ami_id" {
  value = data.aws_ami.amazon_linux.id
}

output "master_public_ip" {
  value = aws_instance.master.public_ip
}

output "master_private_ip" {
  value = aws_instance.master.private_ip
}

output "worker_public_ips" {
  value = aws_instance.worker[*].public_ip
}

output "worker_private_ips" {
  value = aws_instance.worker[*].private_ip
}
