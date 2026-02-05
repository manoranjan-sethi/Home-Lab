# DevSecOps Homelab Infrastructure

A compact 3-node Kubernetes cluster for DevSecOps experimentation running on Ubuntu 24.04 (i5-8400 | 32GB RAM).

## System Overview

The Home Lab is a Kubernetes setup running via **kubeadm** inside **Multipass** virtual machines on a single host. The cluster is designed with resource efficiency and observability in mind.

- **Host Optimization:** Skipping the Ubuntu desktop (GNOME) layer saved ~1.5 GB RAM for cluster tasks.
- **Networking:** A fixed IP is assigned to the host via DHCP to ensure stability across power cycles and smooth remote access.
- **Deployment:** **Argo CD** manages application rollouts.
- **Monitoring:** A **Grafana** dashboard visualizes real-time metrics collected by **Prometheus** via **Node Exporter**.

## Architecture Diagram

```text
          ( User )
             |
             | Remote Login / Dashboard Access
             v
+-----------------------------------------------------------------------+
| Host Machine (Ubuntu 24.04)                                           |
|                                                                       |
|   +---------------------------------------------------------------+   |
|   | Multipass VMs                                                 |   |
|   |                                                               |   |
|   |   +---------------------+        +------------------------+   |   |
|   |   |    Control Plane    |------- |        Worker 1        |   |   |
|   |   |  (2 vCPU, 4GB RAM)  |        |    (1 vCPU, 4GB RAM)   |   |   |
|   |   +----------+----------+        |   Argo CD, Prometheus  |   |   |
|   |              |                   |        Grafana         |   |   |
|   |              |                   +-----------+------------+   |   |
|   |              |                               | Deploys/       |   |
|   |              |                               v Monitors       |   |
|   |              |                   +------------------------+   |   |
|   |              +-------------------|         Worker 2       |   |   |
|   |                                  |    (1 vCPU, 4GB RAM)   |   |   |
|   |                                  |      App Workloads     |   |   |
|   |                                  |     (Node Exporter)    |   |   |
|   |                                  +------------------------+   |   |
|   +---------------------------------------------------------------+   |
+-----------------------------------------------------------------------+
```

## Node Specifications
- **Control Plane:** 2 vCPU, 4 GB RAM
- **Worker 1 (Ops):** 1 vCPU, 4 GB RAM — Argo CD, Prometheus
- **Worker 2 (App):** 1 vCPU, 4 GB RAM — Application workloads

## Tech Stack
- **Orchestration:** Kubeadm (v1.30+)
- **GitOps:** Argo CD
- **Observability:** Prometheus, Grafana, Node Exporter