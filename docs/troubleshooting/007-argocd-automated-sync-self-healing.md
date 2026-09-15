# Argo CD Automated Sync and Self-Healing

## Objective

I wanted Argo CD to automatically apply Git changes to Kubernetes and automatically correct any manual changes made directly to the cluster — no manual `argocd app sync` required.

```
Git = Desired State
Kubernetes = Actual State
Argo CD = Reconciler
```

---

## Before Automated Sync

The Argo CD Application was using `Sync Policy: Manual`. Whenever Git changed, Argo CD detected the drift but waited for me to run:

```bash
argocd app sync hireflow
```

I wanted to remove that manual step entirely.

---

## Enabling Automated Sync and Self-Healing

I enabled both features with a single command:

```bash
argocd app set hireflow \
  --sync-policy automated \
  --self-heal
```

The Application immediately reported:

```
Sync Policy: Automated
Sync Status: Synced
Health Status: Healthy
```

---

## Self-Healing Test

With Git specifying `replicaCount: 2` for Django, I deliberately scaled the deployment to zero directly in Kubernetes:

```bash
kubectl scale deployment hireflow-helm-django \
  -n hireflow \
  --replicas=0
```

This created a deliberate drift:

```
Git desired state:    Django = 2
Kubernetes actual:    Django = 0
```

Argo CD detected the drift and automatically restored the deployment without any input from me:

```
0/2 → 1/2 → 2/2
```

---

## Automated Sync vs Self-Healing

These two features solve different problems:

| Feature | Trigger | What it does |
|---|---|---|
| Automated Sync | A change is pushed to Git | Applies the Git change to Kubernetes automatically |
| Self-Healing | A manual change is made to Kubernetes | Reverts the cluster back to the Git desired state |

---

## Key Lessons

- **Git is the only place I make permanent changes.** Direct `kubectl` changes are useful for debugging but Argo CD will revert them.
- **Automated sync removed the manual deployment step** — I push to Git and the cluster updates itself.
- **Self-healing means the cluster enforces Git** — no one can accidentally leave the cluster in a drifted state.

---

## References

- [Argo CD — Automated Sync Policy](https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/)
- [Argo CD — App Sync](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_app_sync/)
- [Argo CD — Getting Started](https://argo-cd.readthedocs.io/en/stable/getting_started/)
