resource "aws_security_group" "eks_worker_sg" {
  name_prefix = "eks-worker-sg"
  vpc_id      = aws_vpc.eks_vpc.id  # Reference to your VPC

  tags = {
    Name = "eks-worker-sg"
  }
}

# Allow SSH access (optional)
resource "aws_security_group_rule" "ssh_access" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # Restrict this to your IP for security
  security_group_id = aws_security_group.eks_worker_sg.id
}

# Allow all traffic within the security group
resource "aws_security_group_rule" "worker_node_communication" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"  # All protocols
  self              = true  # Allow traffic within the same security group
  security_group_id = aws_security_group.eks_worker_sg.id
}

# Allow all outbound traffic
resource "aws_security_group_rule" "worker_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"  # All protocols
  cidr_blocks       = ["0.0.0.0/0"]  # Allow outbound traffic to anywhere
  security_group_id = aws_security_group.eks_worker_sg.id
}


# Add an ingress rule to allow control plane communication
resource "aws_security_group_rule" "cluster_to_worker_ingress" {
  description              = "Allow EKS control plane to communicate with worker nodes"
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_worker_sg.id
  source_security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

resource "aws_security_group_rule" "cluster_to_worker_ingress_443" {
    description              = "Allow EKS control plane to communicate with worker nodes on port 443"
    type                     = "ingress"
    from_port                = 443
    to_port                  = 443
    protocol                 = "tcp"
    security_group_id        = aws_security_group.eks_worker_sg.id
    source_security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}






resource "aws_security_group_rule" "bastion_to_workers" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_worker_sg.id
  source_security_group_id = aws_security_group.bastion_sg.id
}