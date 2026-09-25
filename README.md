# HireFlow

**Cloud-native CV processing platform built with Django, Kubernetes, AWS, CI/CD and GitOps.**

HireFlow is a document-processing platform that accepts candidate CVs through a REST API, processes them asynchronously, and extracts structured candidate information.

The project was built to demonstrate practical Cloud and DevOps engineering skills, including containerization, Kubernetes, AWS infrastructure, CI/CD, Infrastructure as Code, persistent storage, and GitOps.

---

## Architecture

![HireFlow System Architecture](diagrams/hireflow-architecture.png)

For a detailed explanation of the architecture and design decisions, see:

**[System Architecture](docs/architecture.md)**

---

## How It Works

A candidate CV follows an asynchronous processing pipeline:

```text
Client
  │
  │ Upload CV
  ▼
Django REST API
  │
  ├── Store document metadata
  │
  ▼
PostgreSQL
  │
  └── Queue processing task
           │
           ▼
         Redis
           │
           ▼
     Celery Worker
           │
           ├── Extract PDF text
           ├── Parse candidate information
           │
           ▼
       PostgreSQL
           │
           ▼
    Processing Status
           │
           ▼
      SSE Client
```

This allows document processing to happen asynchronously without blocking the API request.

---

## Key Features

- REST API for CV uploads
- Asynchronous CV processing with Celery
- Redis message broker
- PDF text extraction
- Candidate information parsing
- Processing status tracking
- Server-Sent Events (SSE)
- PostgreSQL persistence
- Docker containerization
- Kubernetes deployment
- Helm-based Kubernetes configuration
- Amazon EKS
- Amazon ECR
- Amazon EBS persistent storage
- AWS Application Load Balancer
- GitHub Actions CI
- AWS OIDC authentication
- ArgoCD GitOps
- Kubernetes health and readiness probes
- Kubernetes self-healing

---

## Technology Stack

| Category | Technology |
|---|---|
| Application | Django |
| API | Django REST Framework |
| Database | PostgreSQL |
| Background Processing | Celery |
| Message Broker | Redis |
| PDF Processing | pypdf |
| Containerization | Docker |
| Orchestration | Kubernetes |
| Kubernetes Platform | Amazon EKS |
| Packaging | Helm |
| Infrastructure as Code | Terraform |
| Container Registry | Amazon ECR |
| CI | GitHub Actions |
| GitOps / CD | ArgoCD |
| Load Balancing | AWS Application Load Balancer |
| Persistent Storage | Amazon EBS |
| Cloud Provider | AWS |

---

## CI/CD & GitOps

The project uses GitHub Actions for continuous integration.

The CI pipeline:

1. Checks out the source code
2. Configures AWS credentials using OIDC
3. Installs Python dependencies
4. Runs Django checks
5. Runs automated tests
6. Builds the Docker image
7. Pushes the image to Amazon ECR

Docker images are tagged using the Git commit SHA, providing traceability between source code and container images.

ArgoCD manages the Kubernetes deployment using the Helm configuration stored in GitHub.

```
GitHub
   │
   ├──────────────► GitHub Actions
   │                     │
   │                     ├── Tests
   │                     ├── Build
   │                     └── Push image
   │                            │
   │                            ▼
   │                       Amazon ECR
   │
   └──────────────► ArgoCD
                         │
                         ▼
                       Helm
                         │
                         ▼
                    Amazon EKS
```

ArgoCD uses automated synchronization with `prune` and `selfHeal` enabled.

---

## Kubernetes

HireFlow runs in a dedicated Kubernetes namespace with the following workloads:

```
hireflow
│
├── Django
├── Celery Worker
├── PostgreSQL
└── Redis
```

Persistent storage is provided through Kubernetes PersistentVolumeClaims backed by Amazon EBS.

The Django application uses:

- `/health/` for liveness checks
- `/ready/` for readiness checks

The readiness check verifies PostgreSQL connectivity before the application receives traffic.

---

## AWS Infrastructure

The current deployment uses:

- Amazon VPC
- Amazon EKS
- Two `t3.small` worker nodes
- AWS Application Load Balancer
- AWS Load Balancer Controller
- Amazon EBS
- AWS EBS CSI Driver
- Amazon ECR
- AWS IAM
- GitHub Actions OIDC

The EKS worker nodes are distributed across two Availability Zones in `us-east-1`.

---

## Reliability

The project includes several Kubernetes reliability mechanisms.

### Kubernetes Self-Healing

When an application pod is deleted, the Kubernetes Deployment automatically creates a replacement pod.

### Readiness Handling

When PostgreSQL becomes unavailable, the Django readiness endpoint returns `503`, causing the Django pod to become `NotReady` without unnecessarily restarting the container.

When PostgreSQL becomes available again, the pod automatically becomes ready.

### GitOps Self-Healing

ArgoCD continuously compares the desired state stored in Git with the live Kubernetes state.

With `selfHeal` enabled, configuration drift can automatically be reconciled back to the desired Git state.

---

## Documentation

Detailed technical documentation is available in the `docs/` directory.

- **System Architecture** — architecture, application flow, Kubernetes, AWS, CI/CD, security and future improvements
- **Architecture Decisions** — important technical decisions made during development
- **Troubleshooting** — problems encountered and how they were diagnosed and resolved
- **Project Backlog** — planned work and future improvements

---

## Current Limitations

The current implementation is intentionally focused on demonstrating Cloud and DevOps engineering practices.

Some components remain simplified:

- CV files currently use Kubernetes EBS-backed storage
- CV parsing uses a lightweight rule-based parser
- Application authentication is not yet implemented
- Prometheus and Grafana monitoring are not currently deployed
- The Django deployment currently uses a single replica
- The CI pipeline does not automatically update the Helm image tag after pushing a new image
- Production secret management is planned

---

## Future Improvements

Planned improvements include:

- Amazon S3 document storage
- Application authentication and authorization
- Improved CV parsing
- Automated image promotion through GitOps
- Prometheus and Grafana monitoring
- AWS Secrets Manager integration
- HTTPS/TLS
- Kubernetes NetworkPolicies
- Resource requests and limits
- Database backups and disaster recovery
- Separate development and production environments
- Horizontal scaling

---

## Project Goal

HireFlow is primarily a portfolio and learning project designed to demonstrate practical experience building and operating a cloud-native application.

The main focus is on:

```
Infrastructure
     +
Containers
     +
Kubernetes
     +
AWS
     +
CI/CD
     +
GitOps
```

rather than building a complex frontend or advanced business application.
