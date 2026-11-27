variable "aws_region" {
  description = "AWS region for Kubernetes infrastructure"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for Kubernetes VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for Kubernetes public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for Kubernetes nodes"
  type        = string
  default     = "ap-south-1a"
}
variable "my_ip" {
  description = "Public IP address allowed for SSH"
  type        = string
}
variable "instance_type" {
  description = "EC2 instance type for Kubernetes nodes"
  type        = string
  default     = "m7i-flex.large"
}

variable "key_name" {
  description = "Existing EC2 SSH key pair"
  type        = string
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 20
}

variable "worker_count" {
  description = "Number of Kubernetes worker nodes"
}
variable "private_key_path" {
  description = "Local path to the EC2 private key"
  type        = string
}
