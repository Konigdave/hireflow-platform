# Helm Migration: Reusing Existing PVCs

## Problem

The existing HireFlow Kubernetes deployment already used:

- postgres-pvc
- media-pvc

The initial Helm chart attempted to create new PVCs:

- hireflow-postgres
- hireflow-media

This would have created new empty storage and could have caused the Helm deployment to start with a different database/media volume.

## Root Cause

The Helm chart was written as a fresh deployment and did not distinguish between:

- creating new storage
- reusing an existing PVC

## Solution

Added `existingClaim` values:

storage:
  postgres:
    size: 1Gi
    existingClaim: postgres-pvc

  media:
    size: 1Gi
    existingClaim: media-pvc

The PVC templates use conditional creation:

{{- if not .Values.storage.postgres.existingClaim }}

When an existing claim is supplied, Helm does not create a new PVC.

The Deployments reference the existing claims instead.

## Verification

helm template ... | grep ...

Confirmed:

claimName: media-pvc
claimName: postgres-pvc

and no PersistentVolumeClaim resources were rendered.

## Lesson

Helm charts should distinguish between:

- resources managed/created by the chart
- resources that already exist and should be reused

Persistent storage requires special care during migrations because creating a new PVC does not mean getting the existing data.
