resource "aws_eks_node_group" "eks_managed_nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-managed-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.private_subnet[*].id
  instance_types  = ["t2.micro"]
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  remote_access {
    ec2_ssh_key = "mk_technologies_key"  # Replace with your actual key pair name
  }

  tags = {
    Name                              = "eks-managed-node"
    "kubernetes.io/cluster/mk-eks-cluster" = "owned"
  }
}
