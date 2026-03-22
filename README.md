# EKS Platform — Production-Grade Kubernetes on AWS

> A fully automated, GitOps-driven platform for deploying containerized applications on Amazon EKS — built with Terraform, ArgoCD, Karpenter, Prometheus, and GitHub Actions.

---

## What Is This?

This project is a **production-grade cloud platform** built entirely from scratch on AWS. It provisions a complete Kubernetes environment using infrastructure-as-code, deploys a real inventory management application, and automates everything from infrastructure provisioning to application delivery — all through Git.

Think of it as the foundation a real engineering team would build before shipping software to millions of users.

---

## Live Application

**Inventory Manager** — a full-stack web application with:
- A **FastAPI** backend with a REST API (create, read, update, delete products)
- A **PostgreSQL** database for persistent storage
- A **React-style frontend** served by nginx
- Real health checks, metrics endpoints, and graceful error handling

---

## Architecture Overview

```
                        ┌────────────────────────────────────────── ───┐
                        │              AWS Cloud (ap-south-1)          │
                        │                                              │
  Browser ──────────────┼──▶  NGINX Ingress Controller                │
                        │         │           │                         │
                        │         ▼           ▼                         │
                        │    Frontend      Backend (FastAPI)            │
                        │    (nginx)           │                        │
                        │                      ▼                        │
                        │               PostgreSQL (StatefulSet)        │
                        │                                               │
                        │  ┌────────────────────────────────────── ┐    │
                        │  │         EKS Cluster                   │    │
                        │  │                                       │    │
                        │  │  ├── ArgoCD       (GitOps)            │    │
                        │  │  System Nodes (t3.medium)             │    │
                        │  │  ├── Karpenter    (Autoscaling)       │    │
                        │  │  ├── Prometheus   (Metrics)           │    │
                        │  │  └── Grafana      (Dashboards)        │    │
                        │  │                                       │    │
                        │  │  App Nodes (Karpenter-managed)        │    │
                        │  │  ├── backend pods  (HPA: 2-10)        │    │
                        │  │  └── frontend pods (HPA: 2-5)         │    │
                        │  └────────────────────────────────────── ┘    │
                        │                                               │
                        │  VPC  ──  Public Subnets  ──  Private Subnets │
                        │  NAT Gateway  ──  Internet Gateway            │
                        └───────────────────────────────────────────────┘
```

---

## How Everything Fits Together

### 1. Infrastructure Layer — Terraform

All AWS resources are defined as code using **Terraform** with reusable modules:

| Module | What it creates |
|---|---|
| `vpc` | VPC, public/private subnets, NAT gateway, route tables |
| `eks-cluster` | EKS control plane, IAM roles, OIDC provider |
| `eks-nodes` | System node group (tainted for platform workloads only) |
| `karpenter` | IAM + Helm install for node autoscaling |
| `argocd` | Helm install + root App-of-Apps configuration |
| `monitoring` | Prometheus + Grafana + AlertManager via Helm |

Each environment (`dev`, `prod`) has **isolated remote state** stored in S3 with DynamoDB locking — preventing state corruption when multiple engineers work simultaneously.

Cost is managed carefully — the NAT gateway (~$65/mo) and EKS control plane (~$73/mo) can be toggled independently via input variables, allowing full teardown when idle while preserving networking state.

---

### 2. GitOps Delivery — ArgoCD App-of-Apps

Instead of manually running `kubectl apply`, this platform uses **ArgoCD** with the App-of-Apps pattern:

```
Git Repository (k8s/)
      │
      ▼
ArgoCD Root App  ──watches──▶  argocd/apps/
      │
      ├──▶  backend app    ──deploys──▶  k8s/backend/
      ├──▶  frontend app   ──deploys──▶  k8s/frontend/
      ├──▶  postgres app   ──deploys──▶  k8s/postgres/
      └──▶  monitoring app ──deploys──▶  k8s/monitoring/
```

**Every change to the `k8s/` folder in Git automatically syncs to the cluster within 3 minutes.** No manual deployments. No SSH into servers. Git is the single source of truth.

**Rollbacks** are a single git revert — ArgoCD detects the change and restores the previous state automatically.

---

### 3. CI/CD Pipelines — GitHub Actions

Two pipelines, two purposes:

#### Terraform CI (`terraform.yml`)
Triggers on every pull request touching `terraform/`:
1. Assumes AWS IAM role via **OIDC** — no long-lived credentials stored anywhere
2. Runs `terraform fmt`, `terraform validate`, `terraform plan`
3. Posts the plan output as a PR comment for review before any infrastructure changes

#### App Deploy (`app-deploy.yml`)
Triggers on every push to `main` touching `backend/` or `frontend/`:
1. Logs into Docker Hub
2. Builds Docker images for backend and frontend
3. Pushes images tagged `latest`
4. ArgoCD picks up the new image and rolls it out to the cluster

---

### 4. Node Autoscaling — Karpenter

Rather than manually managing node groups, **Karpenter** watches for unschedulable pods and provisions exactly the right EC2 instance within seconds.

```
Pod needs more resources
        │
        ▼
Karpenter reads pod requirements
        │
        ▼
Launches matching EC2 instance (t3.medium / t3.large)
        │
        ▼
Pod schedules onto new node (~60 seconds total)
        │
        ▼
Node terminates automatically when idle (30s consolidation)
```

The system node group (fixed at 2 nodes) runs platform services only and is **tainted** so application pods never land there — ensuring platform stability is never compromised by app workloads.

---

### 5. Observability — Prometheus + Grafana

The full `kube-prometheus-stack` is deployed, providing:

- **Node metrics** — CPU, memory, disk pressure per EC2 instance
- **Pod metrics** — restart counts, resource utilization, scheduling failures
- **Application metrics** — total products, low stock items (scraped from `/metrics`)
- **Grafana dashboards** — pre-built cluster health and custom app dashboards

**SLO Alerting** (`k8s/monitoring/alerts.yaml`):

| Alert | Condition | Severity |
|---|---|---|
| `HighErrorRate` | HTTP 5xx rate > 1% for 5 min | Critical |
| `HighLatency` | p99 latency > 500ms for 5 min | Warning |
| `PodCrashLooping` | Any inventory pod restarting | Critical |
| `NodeMemoryPressure` | Node memory > 85% | Warning |

---

### 6. Application Workloads

#### Backend (FastAPI)
- Full CRUD REST API for inventory management
- `/healthz` — liveness probe (is the app running?)
- `/readyz` — readiness probe (is the database connected?)
- `/metrics` — Prometheus scrape endpoint
- Horizontal Pod Autoscaler: scales 2→10 pods at 70% CPU

#### Frontend (nginx)
- Static HTML/JS served by nginx:alpine (5MB image)
- Calls backend via `/api` path — routed by NGINX Ingress
- Horizontal Pod Autoscaler: scales 2→5 pods at 70% CPU

#### PostgreSQL
- Runs as a **StatefulSet** with a PersistentVolumeClaim
- AWS automatically provisions an EBS volume — data survives pod restarts
- Credentials stored in Kubernetes Secrets — never in application code

---

## Repository Structure

```
eks-platform/
├── .github/
│   └── workflows/
│       ├── terraform.yml        # Infra CI — plan on PR
│       └── app-deploy.yml       # App CI — build + push on merge
│
├── terraform/
│   ├── global/                  # GitHub OIDC provider
│   ├── env/
│   │   ├── dev/                 # Dev environment (isolated state)
│   │   └── prod/                # Prod environment (isolated state)
│   └── modules/
│       ├── vpc/                 # Networking
│       ├── eks-cluster/         # Control plane + OIDC
│       ├── eks-nodes/           # System node group
│       ├── karpenter/           # Node autoscaling
│       ├── argocd/              # GitOps controller
│       └── monitoring/          # Prometheus + Grafana
│
├── k8s/
│   ├── namespace.yaml
│   ├── ingress.yaml             # NGINX routing rules
│   ├── backend/                 # Deployment + Service + HPA
│   ├── frontend/                # Deployment + Service + HPA
│   ├── postgres/                # StatefulSet + Service + Secret
│   └── monitoring/              # SLO alert rules
│
├── argocd/
│   └── apps/                    # App-of-Apps child applications
│
├── backend/                     # FastAPI application
│   ├── main.py
│   ├── requirements.txt
│   └── Dockerfile
│
└── frontend/                    # Static web frontend
    ├── index.html
    └── Dockerfile
```

---

## Key Engineering Decisions

**Why Karpenter over Cluster Autoscaler?**
Karpenter provisions nodes in ~60 seconds vs ~3 minutes for Cluster Autoscaler. It also selects the optimal instance type per workload rather than scaling a fixed node group — significantly reducing cost.

**Why App-of-Apps over plain manifests?**
A single root ArgoCD application manages all child apps declaratively. Adding a new service means adding one YAML file — ArgoCD discovers and deploys it automatically. No pipeline changes required.

**Why StatefulSet for PostgreSQL?**
StatefulSets guarantee stable network identity and persistent storage. A Deployment would lose data on pod restart — unacceptable for a database.

**Why OIDC over IAM access keys in CI?**
OIDC issues short-lived tokens per pipeline run. There are no credentials to rotate, leak, or expire. This is AWS's recommended approach for CI/CD authentication.

**Why resource requests and limits on every pod?**
Without them, a single misbehaving pod can consume all node resources and starve other workloads. Requests drive Kubernetes scheduling decisions; limits prevent runaway consumption.

---

## Resilience Testing

Platform resilience is verified by:

1. **Node failure simulation** — terminating EC2 instances via AWS console to verify Karpenter relaunches them and pods reschedule within SLO
2. **Failed deployment recovery** — pushing a broken image tag and verifying ArgoCD holds the last healthy state (self-heal enabled)
3. **Pod crash loop testing** — manually crashing pods to verify liveness probes trigger restarts and readiness probes gate traffic correctly

---

## Cost Management

| Resource | Monthly cost | Toggle |
|---|---|---|
| EKS control plane | ~$73 | `enable_eks = false` |
| NAT Gateway | ~$65 | `enable_nat_gateway = false` |
| t3.medium nodes (x2) | ~$60 | Scale to 0 when idle |
| **Total (dev, running)** | **~$198** | Full teardown when not in use |

Full teardown: `terraform destroy` — VPC state is preserved for fast re-provisioning.

---

## Tech Stack

| Category | Technology |
|---|---|
| Cloud | AWS (EKS, VPC, IAM, EBS, ECR) |
| Infrastructure as Code | Terraform |
| Container Orchestration | Kubernetes (EKS 1.29) |
| GitOps | ArgoCD |
| Node Autoscaling | Karpenter |
| Workload Autoscaling | Horizontal Pod Autoscaler |
| CI/CD | GitHub Actions |
| Ingress | NGINX Ingress Controller |
| TLS | cert-manager + Let's Encrypt |
| Observability | Prometheus + Grafana + AlertManager |
| Backend | Python / FastAPI |
| Frontend | HTML / JavaScript / nginx |
| Database | PostgreSQL |
| Container Registry | Docker Hub |
| Auth (CI) | AWS OIDC |

---

## Getting Started

### Prerequisites
- AWS CLI configured (`aws configure`)
- Terraform >= 1.5
- kubectl
- Helm >= 3.0

### Deploy

```bash
# Clone the repo
git clone https://github.com/pranshavv/eks-platform.git
cd eks-platform

# Enable infrastructure
# In terraform/env/dev/terraform.tfvars:
# enable_nat_gateway = true
# enable_eks         = true

# Plan and apply
cd terraform/env/dev
terraform init
terraform plan
terraform apply

# Connect kubectl to cluster
aws eks update-kubeconfig \
  --name eks-platform-dev \
  --region ap-south-1

# Verify everything is running
kubectl get pods -A
```

### Teardown (stop paying)

```bash
cd terraform/env/dev
terraform destroy
```

---

*Built by [@pranshavv](https://github.com/pranshavv)*
