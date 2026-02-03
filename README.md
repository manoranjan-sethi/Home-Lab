# DevSecOps Homelab Infrastructure
3-Node Kubernetes Cluster running on Ubuntu 24.04 (i5-8400 | 32GB RAM).

## Architecture
- **Control Plane:** 2 vCPU, 4GB RAM
- **Worker 1 (Ops):** 1 vCPU, 4GB RAM (Argo CD, Prometheus)
- **Worker 2 (App):** 1 vCPU, 4GB RAM (Application workloads)

## Tech Stack
- **Orchestration:** Kubeadm (v1.30+)
- **GitOps:** Argo CD
- **Observability:** Prometheus, Grafana, Node Exporter