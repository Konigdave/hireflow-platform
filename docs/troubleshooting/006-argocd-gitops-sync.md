# Argo CD GitOps Sync

## Objective

I wanted to move HireFlow from manually running Helm commands to a GitOps workflow using Argo CD.

```
Before:  Git → helm upgrade → Kubernetes
After:   Git → Argo CD → Helm → Kubernetes
```

---

## Setup

I installed Argo CD into the `argocd` namespace and confirmed all components came up healthy. I also installed the Argo CD CLI locally and connected it to the in-cluster Kubernetes API.

At this point HireFlow was already running as a Helm release (`hireflow-helm`) with Django, Postgres, Redis, and Worker all healthy.

**Secret handling:** I updated the chart to reference an existing secret rather than create one, so Argo CD could render the chart without credentials committed to Git:

```yaml
secrets:
  existingSecret: hireflow-helm-secret
```

---

## Argo CD Application

I created an Argo CD Application named `hireflow` with the following config:

| Field | Value |
|---|---|
| Repository | `https://github.com/Konigdave/hireflow-platform.git` |
| Path | `infrastructure/helm/hireflow` |
| Revision | `main` |
| Destination | `https://kubernetes.default.svc` |
| Namespace | `hireflow` |
| Helm release name | `hireflow-helm` |

I reused the existing Helm release name to preserve all current Kubernetes resource names.

---

## Initial Sync

Before syncing, Argo CD reported `OutOfSync`. I inspected the diff and found it was only adding `argocd.argoproj.io/tracking-id` metadata — no workload changes. The app was still healthy.

> `OutOfSync` ≠ broken. Argo CD just hadn't taken ownership yet.

I ran:

```bash
argocd app sync hireflow
# → Sync Status: Synced | Health Status: Healthy
```

All existing pods remained healthy.

---

## GitOps Verification

To confirm Argo CD was actually watching Git, I made a controlled change:

```yaml
# infrastructure/helm/hireflow/values.yaml
django:
  replicaCount: 2   # was 1
```

I committed and pushed to GitHub. Argo CD immediately detected drift and reported `OutOfSync`. Because I had set the sync policy to **Manual**, it waited for my command rather than applying the change automatically.

I then synced manually:

```bash
argocd app sync hireflow
# → hireflow-helm-django   2/2
# → Sync Status: Synced | Health Status: Healthy
```

---

## Key Lessons

- **Git is the desired state.** I change a value in Git; Argo CD reconciles the cluster to match it.
- **Helm and Argo CD are complementary.** Helm renders the resources; Argo CD decides when they're applied.
- **I used Manual sync policy** to keep control during the initial setup — Argo CD detects drift but waits for my explicit command.
- **`OutOfSync` is not an outage.** I learned early on that a healthy app can be out of sync.

---

## References

- [Argo CD — Getting Started](https://argo-cd.readthedocs.io/en/stable/getting_started/)
- [Argo CD — Application Specification](https://argo-cd.readthedocs.io/en/stable/user-guide/application-specification/)
- [Argo CD — Helm](https://argo-cd.readthedocs.io/en/stable/user-guide/helm/)
- [Argo CD — App Sync](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_app_sync/)
- [Argo CD — Automated Sync Policy](https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/)
