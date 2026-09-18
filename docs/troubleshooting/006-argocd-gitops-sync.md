# Argo CD GitOps Sync

## Objective

Move HireFlow from manual Helm deployments to a GitOps workflow using Argo CD.

```
Before:  Git → helm upgrade → Kubernetes
After:   Git → Argo CD → Helm → Kubernetes
```

---

## Setup

Argo CD was installed into the `argocd` namespace. All components came up healthy.

HireFlow was already running as a Helm release (`hireflow-helm`) with Django, Postgres, Redis, and Worker all healthy.

**Secret handling:** the chart was updated to reference an existing secret rather than create one:

```yaml
secrets:
  existingSecret: hireflow-helm-secret
```

This means Argo CD can render the chart without credentials committed to Git.

---

## Argo CD Application

| Field | Value |
|---|---|
| Repository | `https://github.com/Konigdave/hireflow-platform.git` |
| Path | `infrastructure/helm/hireflow` |
| Revision | `main` |
| Destination | `https://kubernetes.default.svc` |
| Namespace | `hireflow` |
| Helm release name | `hireflow-helm` |

Using the existing Helm release name preserved all current resource names.

---

## Initial Sync

Before the first sync, Argo CD reported `OutOfSync` — it had added `argocd.argoproj.io/tracking-id` metadata that wasn't in the cluster yet. No workload changes were detected.

> `OutOfSync` ≠ broken. The app was healthy; Argo CD just hadn't taken ownership yet.

```bash
argocd app sync hireflow
# → Sync Status: Synced | Health Status: Healthy
```

---

## GitOps Verification

To confirm Argo CD was actually watching Git, a controlled change was made:

```yaml
# infrastructure/helm/hireflow/values.yaml
django:
  replicaCount: 2   # was 1
```

After pushing to GitHub, Argo CD detected drift and reported `OutOfSync`. Because the sync policy was **Manual**, it waited for an explicit command:

```bash
argocd app sync hireflow
# → hireflow-helm-django   2/2
# → Sync Status: Synced | Health Status: Healthy
```

---

## Key Lessons

- **Git is the desired state.** Argo CD reconciles the cluster to match it.
- **Helm and Argo CD are complementary.** Helm renders resources; Argo CD manages when they're applied.
- **Manual sync policy** is useful for controlled rollouts — Argo CD detects drift but waits for your command.
- **`OutOfSync` is not an outage.** A healthy app can be out of sync.

---

## References

- [Argo CD — Getting Started](https://argo-cd.readthedocs.io/en/stable/getting_started/)
- [Argo CD — Application Specification](https://argo-cd.readthedocs.io/en/stable/user-guide/application-specification/)
- [Argo CD — Helm](https://argo-cd.readthedocs.io/en/stable/user-guide/helm/)
- [Argo CD — App Sync](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_app_sync/)
- [Argo CD — Automated Sync Policy](https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/)
