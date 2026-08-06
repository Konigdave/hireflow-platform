# Docker First Build Troubleshooting

## Overview

During the initial containerization of HireFlow, several issues were encountered while running the Django application inside Docker. These issues helped improve the Docker image and provided valuable lessons about Linux permissions, Docker containers, and Django migrations.

---

# Issue 1: SQLite Permission Error

## Error

```
django.db.utils.OperationalError:
unable to open database file
```

## Root Cause

The application was configured to run as a non-root user (`appuser`).

However, the application directory (`/app`) was owned by `root`.

As a result, Django could not create or write to the SQLite database file.

## Investigation

Inside the container:

```bash
whoami
pwd
ls -ld /app
ls -la /app
```

Output showed:

```
drwxr-xr-x root root /app
```

Only the root user had write permissions.

## Solution

Update the Dockerfile:

```dockerfile
COPY . .

RUN chown -R appuser:appuser /app

USER appuser
```

## Lessons Learned

- Containers should run as non-root users whenever possible.
- Running as a non-root user requires the application directory to have appropriate ownership.
- Linux file permissions directly affect application behavior inside containers.

---

# Issue 2: Missing Database Table

## Error

```
OperationalError:
no such table: documents_document
```

## Root Cause

The Document model existed, but no migration file had been created.

Without a migration, Django had no instructions for creating the database table.

## Investigation

Checking the migrations folder:

```bash
ls apps/documents/migrations
```

Output:

```
__init__.py
```

The expected migration file:

```
0001_initial.py
```

was missing.

## Solution

Generate the migration:

```bash
python manage.py makemigrations
```

Apply it:

```bash
python manage.py migrate
```

Rebuild the Docker image:

```bash
docker build -t hireflow:v1 .
```

---

# Issue 3: Migrations Lost After Restart

## Observation

Running migrations manually inside one container worked.

However, starting a new container resulted in the same error.

## Root Cause

Containers are ephemeral.

Each `docker run` creates a brand-new writable filesystem.

Changes made inside one container are not automatically available in another.

## Solution

Create an entrypoint script.

```sh
#!/bin/sh

set -e

python manage.py migrate

exec python manage.py runserver 0.0.0.0:8000
```

The Dockerfile now starts the application through the entrypoint rather than calling `runserver` directly.

---

# Key Lessons

## Linux

- Understand file ownership.
- Understand file permissions.
- Follow the Principle of Least Privilege.

---

## Docker

- Images are immutable.
- Containers are ephemeral.
- Images and containers are different concepts.
- Every new container starts with a fresh writable layer.

---

## Django

- `makemigrations` creates migration files.
- `migrate` applies them to the database.
- Missing migration files result in missing database tables.

---

## DevOps Mindset

Always follow a structured debugging process:

```
Observe the error
        ↓
Form a hypothesis
        ↓
Collect evidence
        ↓
Identify the root cause
        ↓
Apply the fix
        ↓
Verify the solution
```

Avoid fixing symptoms without understanding the underlying cause.

---

# Future Improvements

- Replace SQLite with PostgreSQL.
- Automate startup with an entrypoint script.
- Use Docker Compose to manage multiple services.
- Introduce persistent volumes.
- Deploy to Kubernetes.
