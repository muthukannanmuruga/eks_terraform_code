resource "aws_eks_cluster" "eks_cluster" {
  name     = "mk-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = concat(aws_subnet.public_subnet[*].id, aws_subnet.private_subnet[*].id)
    security_group_ids = [aws_security_group.eks_worker_sg.id]  # Attach SG here
  }

  #Explicitly set authentication mode to use API and ConfigMap
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"  # Enables both API and ConfigMap auth
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
  ]
}