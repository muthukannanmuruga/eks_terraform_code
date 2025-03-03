output "cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "bastion_sg" {
  value = aws_security_group.bastion_sg.id
}



