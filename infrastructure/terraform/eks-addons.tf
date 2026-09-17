resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = aws_eks_cluster.hireflow.name
  addon_name   = "eks-pod-identity-agent"

  depends_on = [
    aws_eks_node_group.hireflow,
  ]
}
