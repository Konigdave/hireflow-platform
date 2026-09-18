resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = aws_eks_cluster.hireflow.name
  addon_name   = "eks-pod-identity-agent"

  depends_on = [
    aws_eks_node_group.hireflow,
  ]
}

data "aws_eks_addon_version" "ebs_csi_driver" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = aws_eks_cluster.hireflow.version
  most_recent        = true
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name  = aws_eks_cluster.hireflow.name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = data.aws_eks_addon_version.ebs_csi_driver.version

  pod_identity_association {
    role_arn        = aws_iam_role.ebs_csi_driver.arn
    service_account = "ebs-csi-controller-sa"
  }

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi_driver,
    aws_eks_addon.pod_identity_agent,
  ]
}
