data "aws_iam_policy_document" "lbc_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]
  }
}

resource "aws_iam_role" "load_balancer_controller" {
  name               = "hireflow-aws-load-balancer-controller"
  assume_role_policy = data.aws_iam_policy_document.lbc_assume_role.json

  tags = {
    Name = "hireflow-aws-load-balancer-controller"
  }
}

resource "aws_iam_policy" "load_balancer_controller" {
  name        = "HireFlowAWSLoadBalancerControllerPolicy"
  description = "IAM permissions for the AWS Load Balancer Controller"

  policy = file("${path.module}/lbc-iam-policy.json")

  tags = {
    Name = "hireflow-aws-load-balancer-controller-policy"
  }
}

resource "aws_iam_role_policy_attachment" "load_balancer_controller" {
  role       = aws_iam_role.load_balancer_controller.name
  policy_arn = aws_iam_policy.load_balancer_controller.arn
}

resource "aws_eks_pod_identity_association" "load_balancer_controller" {
  cluster_name    = aws_eks_cluster.hireflow.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.load_balancer_controller.arn

  depends_on = [
    aws_eks_addon.pod_identity_agent,
    aws_iam_role_policy_attachment.load_balancer_controller,
  ]
}
