# ADR 005 — Run PostgreSQL and Redis Inside Kubernetes

**Status:** Accepted

---

## Context

HireFlow needs PostgreSQL for application data and Redis for Celery task brokering. For this deployment the two main options were:

1. Run both inside the EKS cluster
2. Use managed AWS services (RDS + ElastiCache)

This is primarily a learning and portfolio project, so the approach should demonstrate practical Kubernetes skills while keeping AWS costs manageable.

---

## Decision

I decided to run PostgreSQL and Redis inside Kubernetes, managed through the HireFlow Helm chart. PostgreSQL uses a PersistentVolumeClaim backed by the `gp3` StorageClass via Amazon EBS.

This lets the project demonstrate:

- Stateful workloads in Kubernetes
- PVC and dynamic EBS volume provisioning
- Helm-based configuration
- Kubernetes networking and service discovery
- Operational troubleshooting of stateful components

---

## Consequences

**Benefits**

- Hands-on experience with stateful Kubernetes workloads
- Reuses existing PostgreSQL and Redis Helm templates
- Exercises the EBS CSI driver and `gp3` StorageClass
- Avoids additional managed-service costs
- Generates useful troubleshooting and interview examples

**Trade-offs**

- Backups and recovery must be handled separately
- Database upgrades and maintenance are my responsibility
- No automatic high availability by default
- EBS volumes are tied to a single Availability Zone
- More operational overhead than managed services

---

## Production Consideration

This deployment is not intended to be production-ready. In a production context I would evaluate moving PostgreSQL to Amazon RDS and Redis to ElastiCache, where backups, upgrades, and high availability are handled by AWS.

---

## References

- [Kubernetes StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [Kubernetes Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Kubernetes StorageClasses](https://kubernetes.io/docs/concepts/storage/storage-classes/)
- [Amazon EBS CSI driver on Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)
- [Amazon RDS](https://aws.amazon.com/rds/)
- [Amazon ElastiCache](https://aws.amazon.com/elasticache/)
