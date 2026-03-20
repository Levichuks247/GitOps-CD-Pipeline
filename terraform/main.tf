# --- Managed Node Group ---
resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "gitops-nodes"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = [aws_subnet.sub_1.id, aws_subnet.sub_2.id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  # Upgraded to t3.small to increase the Pod (IP address) limit 
  # from 4 pods per node to 11 pods per node.
  instance_types = ["t3.small"] 
}