resource "aws_vpc" "k8s_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "kubernetes-vpc"
    Project = "terraform-kubernetes"
  }
}
resource "aws_subnet" "k8s_public_subnet" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name    = "kubernetes-public-subnet"
    Project = "terraform-kubernetes"
  }
}
resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_vpc.id

  tags = {
    Name    = "kubernetes-igw"
    Project = "terraform-kubernetes"
  }
}
resource "aws_route_table" "k8s_public_rt" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_igw.id
  }

  tags = {
    Name    = "kubernetes-public-rt"
    Project = "terraform-kubernetes"
  }
}
resource "aws_route_table_association" "k8s_public_rta" {
  subnet_id      = aws_subnet.k8s_public_subnet.id
  route_table_id = aws_route_table.k8s_public_rt.id
}
resource "aws_security_group" "master_sg" {
  name        = "kubernetes-master-sg"
  description = "Security group for Kubernetes master"
  vpc_id      = aws_vpc.k8s_vpc.id

  tags = {
    Name    = "kubernetes-master-sg"
    Project = "terraform-kubernetes"
  }
}
resource "aws_security_group" "worker_sg" {
  name        = "kubernetes-worker-sg"
  description = "Security group for Kubernetes workers"
  vpc_id      = aws_vpc.k8s_vpc.id

  tags = {
    Name    = "kubernetes-worker-sg"
    Project = "terraform-kubernetes"
  }
}
resource "aws_vpc_security_group_ingress_rule" "master_ssh" {
  security_group_id = aws_security_group.master_sg.id
  cidr_ipv4         = var.my_ip
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "worker_ssh" {
  security_group_id = aws_security_group.worker_sg.id
  cidr_ipv4         = var.my_ip
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "worker_to_master" {
  security_group_id            = aws_security_group.master_sg.id
  referenced_security_group_id = aws_security_group.worker_sg.id
  ip_protocol                  = "-1"
}
resource "aws_vpc_security_group_ingress_rule" "master_to_worker" {
  security_group_id            = aws_security_group.worker_sg.id
  referenced_security_group_id = aws_security_group.master_sg.id
  ip_protocol                  = "-1"
}
resource "aws_vpc_security_group_egress_rule" "master_egress" {
  security_group_id = aws_security_group.master_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
resource "aws_vpc_security_group_egress_rule" "worker_egress" {
  security_group_id = aws_security_group.worker_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
resource "aws_vpc_security_group_ingress_rule" "worker_to_worker" {
  security_group_id            = aws_security_group.worker_sg.id
  referenced_security_group_id = aws_security_group.worker_sg.id
  ip_protocol                  = "-1"
}
resource "aws_instance" "master" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.k8s_public_subnet.id
  vpc_security_group_ids = [aws_security_group.master_sg.id]
  key_name               = var.key_name

  private_ip                  = "10.0.1.10"
  associate_public_ip_address = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true
  }

  user_data = join("\n", [
    file("${path.module}/scripts/common.sh"),
    file("${path.module}/scripts/control-plane.sh")
  ])

  user_data_replace_on_change = true

  metadata_options {
    http_tokens = "required"
  }

  depends_on = [
    aws_route_table_association.k8s_public_rta
  ]

  tags = {
    Name    = "kubernetes-master"
    Role    = "control-plane"
    Project = "terraform-kubernetes"
  }
}
resource "aws_instance" "worker" {
  count = var.worker_count

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.k8s_public_subnet.id
  vpc_security_group_ids = [aws_security_group.worker_sg.id]
  key_name               = var.key_name

  private_ip = cidrhost(var.subnet_cidr, 20 + count.index)

  associate_public_ip_address = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_tokens = "required"
  }

  depends_on = [
    aws_route_table_association.k8s_public_rta
  ]

  tags = {
    Name    = "kubernetes-worker-${count.index + 1}"
    Role    = "worker"
    Project = "terraform-kubernetes"
  }
  user_data = join("\n", [
    file("${path.module}/scripts/common.sh"),
    file("${path.module}/scripts/worker-node.sh")
  ])

  user_data_replace_on_change = true

}
resource "aws_vpc_security_group_ingress_rule" "worker_nodeport" {
  security_group_id = aws_security_group.worker_sg.id
  cidr_ipv4         = var.my_ip
  from_port         = 30080
  to_port           = 30080
  ip_protocol       = "tcp"
  description       = "Nginx NodePort access"
}
