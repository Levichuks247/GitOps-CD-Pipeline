# --- VPC & Networking ---
resource "aws_vpc" "gitops_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "gitops-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.gitops_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.gitops_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_subnet" "sub_1" {
  vpc_id                  = aws_vpc.gitops_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true
  tags = { "kubernetes.io/cluster/gitops-eks-final" = "shared" }
}

resource "aws_subnet" "sub_2" {
  vpc_id                  = aws_vpc.gitops_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = true
  tags = { "kubernetes.io/cluster/gitops-eks-final" = "shared" }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.sub_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.sub_2.id
  route_table_id = aws_route_table.public_rt.id
}

# --- EKS Cluster ---
resource "aws_eks_cluster" "eks" {
  name     = "gitops-eks-final"
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids = [aws_subnet.sub_1.id, aws_subnet.sub_2.id]
  }
}

# --- Managed Node Group (t3.small) ---
resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "gitops-nodes-final"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = [aws_subnet.sub_1.id, aws_subnet.sub_2.id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.small"]
}

# --- IAM Roles ---
resource "aws_iam_role" "cluster" {
  name = "gitops-cluster-role-final"
  assume_role_policy = jsonencode({
    Version = "2012-10-17", Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "eks.amazonaws.com" } }]
  })
}

resource "aws_iam_role" "nodes" {
  name = "gitops-node-role-final"
  assume_role_policy = jsonencode({
    Version = "2012-10-17", Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}

# --- IAM Policy Attachments ---
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "node_worker" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "node_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "node_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}