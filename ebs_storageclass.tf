# EKS Cluster Data
data "aws_caller_identity" "current" {}
data "aws_eks_cluster" "current" {
  name = aws_eks_cluster.eks_cluster.name
}
data "aws_eks_cluster_auth" "current" {
  name = aws_eks_cluster.eks_cluster.name
}

# OIDC Provider Configuration
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}


# EBS CSI Driver IAM Role
data "aws_iam_policy_document" "ebs_csi_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    principals {
      type        = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}"
      ]
    }
  }
}

resource "aws_iam_role" "ebs_csi_driver" {
  name               = "ebs-csi-driver-${aws_eks_cluster.eks_cluster.name}"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  role       = aws_iam_role.ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}


# EBS CSI Driver Addon
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.eks_cluster.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.41.0-eksbuild.1" # Verify version for your EKS version
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn
  resolve_conflicts        = "OVERWRITE"

  lifecycle {
    ignore_changes = [
      modified_at,
      configuration_values
    ]
  }

  depends_on = [
    aws_eks_node_group.eks_managed_nodes,
    aws_iam_openid_connect_provider.eks_oidc,
    aws_iam_role_policy_attachment.ebs_csi_policy
  ]
}

