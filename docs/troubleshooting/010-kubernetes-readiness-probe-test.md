# Kubernetes Readiness Probe Failure and Recovery Test

**Date:** 2026-09-20  
**Environment:** AWS EKS  
**Application:** HireFlow

## 1. Objective

I wanted to verify that Kubernetes removes the Django application from Service traffic when PostgreSQL becomes unavailable and automatically restores traffic when PostgreSQL recovers.

## 2. Initial State

I confirmed all application components were healthy:

| Component | Status |
|---|---|
| Django | 1/1 Ready |
| PostgreSQL | 1/1 Ready |
| Redis | 1/1 Ready |
| Celery Worker | 1/1 Ready |

I had configured Django with the following probes:

- **Liveness probe:** `/health/`
- **Readiness probe:** `/ready/`

The `/ready/` endpoint checks PostgreSQL connectivity using a `SELECT 1` query.

## 3. Test Procedure

I intentionally scaled PostgreSQL down to zero replicas:

```bash
kubectl scale deployment hireflow-helm-postgres \
  -n hireflow \
  --replicas=0
```

I then monitored the pods:

```bash
kubectl get pods -n hireflow -w
```

## 4. Observed Result

After PostgreSQL stopped, I observed the Django pod change from:

```text
1/1 Running
```

to:

```text
0/1 Running
```

The Django container remained running, but Kubernetes marked it as **Not Ready** because the readiness probe could no longer connect to PostgreSQL.

The container was not restarted because the liveness probe continued to pass.

## 5. Recovery Procedure

I restored PostgreSQL:

```bash
kubectl scale deployment hireflow-helm-postgres \
  -n hireflow \
  --replicas=1
```

I monitored the pods again:

```bash
kubectl get pods -n hireflow -w
```

## 6. Recovery Result

PostgreSQL successfully returned to the `Running` state.

After PostgreSQL became available again, I observed Django automatically return to:

```text
1/1 Running
```

I did not need to manually restart the Django pod.

## 7. Key Findings

- The readiness probe correctly detected PostgreSQL unavailability.
- Kubernetes marked Django as Not Ready.
- The Django container remained running.
- Kubernetes prevented the unready pod from receiving Service traffic.
- Once PostgreSQL recovered, Django automatically became Ready again.
- The liveness probe and readiness probe serve different purposes.

## 8. Key Lesson

A **readiness probe** determines whether an application should receive traffic.

A **liveness probe** determines whether a container should be restarted.

In this test, PostgreSQL failure affected application readiness but did not require the Django container to be restarted.
