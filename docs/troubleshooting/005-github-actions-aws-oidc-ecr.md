# GitHub Actions AWS OIDC / ECR Troubleshooting

## Problem

GitHub Actions failed when attempting to authenticate to AWS:

```text
Error: Could not assume role with OIDC:
Not authorized to perform sts:AssumeRoleWithWebIdentity
```

The goal was to allow GitHub Actions to assume an AWS IAM role using OIDC and push the HireFlow Docker image to Amazon ECR.

---

## Symptoms

The AWS-side configuration appeared correct:

- GitHub OIDC provider existed
- `HireFlowGitHubActions` IAM role existed
- ECR push permissions were attached
- GitHub Actions had:

```yaml
permissions:
  id-token: write
  contents: read
```

However, role assumption still failed.

---

## Diagnosis

The IAM role trust policy initially used:

```
repo:Konigdave/hireflow-platform:ref:refs/heads/main
```

The repository was created after GitHub's **July 15, 2026** change to immutable OIDC subject claims, so the repository uses the newer format:

```
repo:OWNER@OWNER-ID/REPO@REPO-ID:ref:refs/heads/BRANCH
```

We first retrieved GitHub node IDs:

```
U_kgDOC6nYKg
R_kgDOTsHNEQ
```

These were incorrect for the OIDC subject claim. The numeric IDs were obtained with:

```bash
gh api repos/Konigdave/hireflow-platform \
  --jq '{repository_id: .id, owner_id: .owner.id, owner: .owner.login}'
```

Result:

```json
{
  "owner_id": 195680298,
  "repository_id": 1321323793
}
```

---

## Root Cause

The IAM trust policy contained the wrong `sub` claim.

The incorrect value used GitHub GraphQL node IDs instead of the **numeric** owner and repository IDs expected by the immutable OIDC subject format.

---

## Fix

The trust policy `sub` condition was updated to:

```
repo:Konigdave@195680298/hireflow-platform@1321323793:ref:refs/heads/main
```

Then the IAM role trust policy was applied:

```bash
aws iam update-assume-role-policy \
  --role-name HireFlowGitHubActions \
  --policy-document file://trust-policy.json
```

GitHub Actions subsequently authenticated successfully.

### Final Authentication Flow

```
GitHub Actions
      ↓
   OIDC token
      ↓
AWS OIDC Provider
      ↓
HireFlowGitHubActions
      ↓
HireFlowECRPushPolicy
      ↓
  ECR: hireflow
```

---

## Key Lessons

### Trust policy vs permissions policy

| Policy | Question it answers |
|---|---|
| Trust policy | Who can assume this role? |
| Permissions policy | What can the role do? |

### GitHub IDs

GraphQL node IDs (`U_kg...`, `R_kg...`) are **not** the numeric IDs used in the immutable OIDC subject claim. Always use the REST API to retrieve numeric `owner.id` and repository `id`.

### Least privilege

The GitHub role was scoped only to push images to the `hireflow` ECR repository — not `AdministratorAccess`.

### OIDC vs long-lived keys

GitHub Actions uses **temporary** AWS credentials via OIDC rather than storing `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` as secrets.

---

## References

- [GitHub — Configuring OpenID Connect in AWS](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws)
- [GitHub — OpenID Connect Reference](https://docs.github.com/en/actions/reference/security/oidc)
- [AWS IAM — OpenID Connect Federation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp_oidc.html)
- [AWS STS — Temporary Credentials](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_request.html)
- [GitHub — configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials)
