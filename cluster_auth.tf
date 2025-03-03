

# 🎯 EKS Access Entry for Admin User (Custom Group)
resource "aws_eks_access_entry" "eks_admin" {
  cluster_name      = aws_eks_cluster.eks_cluster.name
  principal_arn     = "arn:aws:iam::311141558203:user/mk_admin"  # Your IAM User
  kubernetes_groups = ["eks-admin-group"]  # ✅ Custom group (not system:masters)
  type              = "STANDARD"
}

# 🎯 Attach AWS-Managed EKS Admin Policy
resource "aws_eks_access_policy_association" "eks_admin_policy" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::311141558203:user/mk_admin"

  depends_on = [aws_eks_access_entry.eks_admin]  # ✅ Ensure access entry exists first

  access_scope {
    type = "cluster"
  }
}
