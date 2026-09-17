resource "aws_eks_node_group" "hireflow" {
  cluster_name    = aws_eks_cluster.hireflow.name
  node_group_name = "hireflow-workers"
  node_role_arn   = aws_iam_role.eks_node.arn

  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id,
  ]

  ami_type       = "AL2023_x86_64_STANDARD"
  instance_types = ["t3.small"]
  capacity_type  = "ON_DEMAND"

  disk_size = 20

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 2
  }

  labels = {
    workload = "hireflow"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_worker,
    aws_iam_role_policy_attachment.eks_node_ecr,
    aws_iam_role_policy_attachment.eks_node_cni,
  ]

  tags = {
    Name = "hireflow-worker"
  }
}
