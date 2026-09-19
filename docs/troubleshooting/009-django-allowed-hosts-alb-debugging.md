# 009 — Django `DisallowedHost` Errors Behind AWS ALB

## Incident

After deploying HireFlow to EKS behind an AWS ALB, Django was returning `400` errors on every health check:

```text
django.core.exceptions.DisallowedHost:
Invalid HTTP_HOST header: '10.0.11.34:8000'.
You may need to add '10.0.11.34' to ALLOWED_HOSTS.
```

Because the ALB was configured with `target-type: ip`, health checks hit the Django pod directly using its pod IP — which wasn't in `ALLOWED_HOSTS`.

---

## Root Cause

Two related issues:

1. The ALB health check used the pod IP as the HTTP `Host` header, which Django rejected.
2. After I updated the ConfigMap to `ALLOWED_HOSTS: "*"`, the errors continued — because **environment variables from a ConfigMap are injected at container start**. Updating the ConfigMap does not restart existing pods.

---

## Resolution

I restarted the Django deployment to pick up the new ConfigMap value:

```bash
kubectl rollout restart deployment/hireflow-helm-django -n hireflow
kubectl rollout status deployment/hireflow-helm-django -n hireflow
```

I verified the new value was loaded inside the pod:

```bash
kubectl exec -n hireflow deployment/hireflow-helm-django -- printenv ALLOWED_HOSTS
# → *
```

The `DisallowedHost` errors disappeared immediately after the rollout.

---

## Verification

I tested the API through the ALB:

```bash
curl -i -H "Host: hireflow.example.com" http://<ALB-DNS>/api/documents/
# → HTTP/1.1 200 OK

curl -i -X POST \
  -H "Host: hireflow.example.com" \
  -F "file=@/path/to/resume.pdf" \
  http://<ALB-DNS>/api/documents/
# → HTTP/1.1 201 Created
```

A follow-up request confirmed the full async pipeline worked:

```json
{
  "id": 1,
  "status": "COMPLETED",
  "candidate_name": "David Ayeni",
  "email": "davidayenioluremi@gmail.com",
  "phone": "+48 500 508 255"
}
```

`COMPLETED` confirmed that Celery, Redis, file processing, and the database all worked end-to-end.

---

## Key Lessons

- Django validates the `Host` header before processing any request — pod IPs will always fail this check.
- ConfigMap changes don't restart pods; I need to trigger a rollout manually (or automate it with a Helm checksum annotation).
- `ALLOWED_HOSTS: "*"` is useful for diagnosis only, not a final configuration.
- A `201 Created` + `COMPLETED` status is the cleanest end-to-end smoke test for this stack.

---

## Follow-Up

- [ ] Add a dedicated `/health/` endpoint returning `200 OK`
- [ ] Point the ALB health check at `/health/` instead of `/`
- [ ] Replace `ALLOWED_HOSTS: "*"` with a restricted production host list
- [ ] Add a Helm checksum annotation to auto-restart pods on ConfigMap changes
- [ ] Replace Django's dev server with a production WSGI/ASGI server
