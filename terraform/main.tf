# --- Use the AWS Default Networking (Bypasses VPC Limits) ---
resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "sub_1" {
  availability_zone = "eu-west-2a"
}

resource "aws_default_subnet" "sub_2" {
  availability_zone = "eu-west-2b"
}

# --- EKS Cluster (Renamed to 'final' for a clean slate) ---
resource "aws_eks_cluster" "eks" {
  name     = "gitops-eks-final"
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids = [aws_default_subnet.sub_1.id, aws_default_subnet.sub_2.id]
  }
}

# --- Managed Node Group (UPGRADED TO T3.SMALL) ---
resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "gitops-nodes-final"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = [aws_default_subnet.sub_1.id, aws_default_subnet.sub_2.id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  # t3.small allows 11 pods per node (t3.micro only allows 4)
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

# --- Standard EKS Policy Attachments ---
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