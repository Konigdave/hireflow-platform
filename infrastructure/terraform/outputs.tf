output "ecr_repository_url" {
  description = "URL of the HireFlow ECR repository"
  value       = aws_ecr_repository.hireflow.repository_url
}

output "eks_cluster_name" {
  description = "Name of the HireFlow EKS cluster"
  value       = aws_eks_cluster.hireflow.name
}

output "eks_cluster_endpoint" {
  description = "Kubernetes API endpoint for the HireFlow EKS cluster"
  value       = aws_eks_cluster.hireflow.endpoint
}

output "eks_node_group_name" {
  description = "Name of the HireFlow EKS managed node group"
  value       = aws_eks_node_group.hireflow.node_group_name
}
