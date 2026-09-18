# EBS CSI Driver — Wrong IAM Policy ARN

## Incident

Terraform failed while attaching the IAM policy for the Amazon EBS CSI driver. The role `hireflow-ebs-csi-driver` had already been created, but the policy attachment errored:

```
NoSuchEntity: Policy arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicyV2 does not exist or is not attachable.
```

---

## Root Cause

The policy ARN in `ebs-csi-iam.tf` had a spurious `service-role/` path prefix:

```
# Wrong
arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicyV2

# Correct
arn:aws:iam::aws:policy/AmazonEBSCSIDriverPolicyV2
```

---

## Fix

I updated `infrastructure/terraform/ebs-csi-iam.tf`:

```hcl
resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  role       = aws_iam_role.ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEBSCSIDriverPolicyV2"
}
```

Then I ran:

```bash
terraform fmt
terraform validate
terraform plan
terraform apply
```

Terraform reused the already-created IAM role and successfully attached the policy.

---

## Key Lesson

AWS-managed policy ARNs must be copied exactly — `service-role/` and similar path prefixes are not interchangeable. I now verify policy ARNs with the AWS CLI before applying:

```bash
aws iam get-policy --policy-arn arn:aws:iam::aws:policy/AmazonEBSCSIDriverPolicyV2
```

```bash
terraform state list | grep ebs_csi
```

---

## References

- [AmazonEBSCSIDriverPolicyV2](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonEBSCSIDriverPolicyV2.html)
- [Amazon EBS CSI driver on Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)
