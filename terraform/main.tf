# --- VPC & Networking ---
resource "aws_vpc" "gitops_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true # Added for EKS endpoint resolution
  tags                 = { Name = "gitops-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.gitops_vpc.id
}

# 1. Create a Route Table to allow traffic to the Internet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.gitops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_subnet" "sub_1" {
  vpc_id            = aws_vpc.gitops_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"
  map_public_ip_on_launch = true
  tags = { 
    "kubernetes.io/cluster/gitops-eks" = "shared" 
    "kubernetes.io/role/elb"           = "1" # Helpful for future LoadBalancers
  }
}

resource "aws_subnet" "sub_2" {
  vpc_id            = aws_vpc.gitops_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2b"
  map_public_ip_on_launch = true
  tags = { 
    "kubernetes.io/cluster/gitops-eks" = "shared" 
    "kubernetes.io/role/elb"           = "1"
  }
}

# 2. Associate the subnets with the Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.sub_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.sub_2.id
  route_table_id = aws_route_table.public_rt.id
}