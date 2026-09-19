# ADR 006 — Application Health-Check Endpoint


---

## Context

HireFlow runs on Kubernetes behind an AWS ALB. The ALB was previously using `/` for health checks, but the app has no homepage route so every health check returned `404 Not Found`.

A `404` doesn't mean the app is down — it just means the route doesn't exist. Infrastructure needs a predictable URL it can use to confirm Django is actually responding.

---

## Decision

I added a dedicated health-check endpoint at `/health/` that returns:

```json
{ "status": "healthy" }
```

`config/views.py`:

```python
from django.http import JsonResponse

def health_check(request):
    return JsonResponse({"status": "healthy"})
```

`config/urls.py`:

```python
path("health/", health_check, name="health-check"),
```

The endpoint returns `200 OK` whenever Django can handle the request.

---

## Rationale

- Gives the ALB and Kubernetes a predictable, unambiguous liveness signal
- Returns machine-readable JSON rather than HTML
- Avoids coupling health checks to any application route
- Easy to extend later with dependency checks

---

## Current Limitations

This is a basic liveness check only. A `200` response confirms Django is running — it does not verify PostgreSQL, Redis, Celery workers, or document processing.

---

## Verification

```bash
curl http://127.0.0.1:8000/health/
# → { "status": "healthy" }
```

---

## Future Improvements

A separate readiness endpoint may be added later to verify critical dependencies (PostgreSQL, Redis) before the ALB routes live traffic to a pod.
