# Docker Compose PostgreSQL Readiness Troubleshooting

## Problem

When starting the HireFlow stack with Docker Compose:

```bash
docker compose up --build
```

the Django container failed during startup while running database migrations.

The relevant error was:

```text
psycopg.OperationalError: connection failed:
connection to server at "172.18.0.3", port 5432 failed:
Connection refused
```

The Django container then exited with code `1`.

---

## Initial Configuration

The `web` service originally used:

```yaml
depends_on:
  postgres:
    condition: service_started
```

This meant Docker Compose waited for the PostgreSQL **container to start**, but not for PostgreSQL itself to become ready to accept connections.

---

## Root Cause

There was a race condition during startup.

The sequence was:

```text
PostgreSQL container starts
        ↓
PostgreSQL begins initialization
        ↓
Django container starts
        ↓
Django runs migrations
        ↓
Django attempts to connect to PostgreSQL
        ↓
PostgreSQL is not ready yet
        ↓
Connection refused
        ↓
Django exits
```

## The logs showed Django attempting the migration while PostgreSQL was still initializing. PostgreSQL only became ready later in the startup process.

## Solution

A PostgreSQL health check was added:

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
  interval: 5s
  timeout: 5s
  retries: 5
```

The Django service was then changed to wait for PostgreSQL to become healthy:

```yaml
depends_on:
  postgres:
    condition: service_healthy
  redis:
    condition: service_started
```

---

## How the Health Check Works

`pg_isready` checks whether PostgreSQL is ready to accept connections.

Instead of simply checking:

```text
Container started
```

Docker Compose can now wait for:

```text
PostgreSQL container started
        ↓
Health check
        ↓
PostgreSQL ready
        ↓
Django starts
        ↓
Migrations run
        ↓
Django server starts
```

---

## Verification

After updating the Compose configuration, the stack was started successfully with:

```bash
docker compose up --build
```

Django was able to connect to PostgreSQL and complete its startup successfully.

---

## Key Lesson

`depends_on` with:

```yaml
condition: service_started
```

does **not** guarantee that the dependent service is ready to accept connections.

For services such as databases, application startup should account for **service readiness**, not merely container startup.

This is an important distinction when designing distributed applications.

---

## DevOps Lesson

The troubleshooting process followed:

```text
Application failure
        ↓
Inspect container logs
        ↓
Identify connection refused
        ↓
Compare startup timing
        ↓
Identify readiness race condition
        ↓
Add health check
        ↓
Wait for healthy dependency
        ↓
Verify successful startup
```

This same principle will become important later when deploying HireFlow to Kubernetes, where readiness and liveness probes are used to control how workloads interact with dependent services.
