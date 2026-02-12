# Known Issues

# 🛠 Troubleshooting & Known Issues: Multi-Node K8s GitOps Lab

This document serves as a technical post-mortem and knowledge base for the challenges encountered while architecting and deploying a self-healing, multi-node Kubernetes cluster on a physical Ubuntu 24.04 host (Intel i5-8400, 32GB RAM).

---

## 1. Node Join Failure: Missing `conntrack`
* **Description:** Worker nodes failed to join the cluster during the `kubeadm join` phase.
* **Root Cause:** The `conntrack` utility, a mandatory prerequisite for Kubernetes networking, was missing from the worker node base images.
* **Solution:** Manually installed `conntrack` on all worker nodes.
* **Lesson Learned:** Infrastructure prerequisites must be verified across the entire fleet. Moving forward, use automation (Ansible) to ensure baseline package parity across Control Plane and Worker nodes.

---

## 2. Argo CD Repository Connection: DNS Resolution Error
* **Description:** The `argocd-repo-server` was unable to connect to the public GitHub repository, reporting a "failed to resolve host" error.
* **Root Cause:** Pod-level DNS was failing to upstream requests from internal CoreDNS to public nameservers, even though the host machine had internet access.
* **Solution:** Performed a `kubectl patch` on the `argocd-repo-server` deployment to explicitly inject external DNS servers (`8.8.8.8`) into the pod's `dnsConfig`.
* **Lesson Learned:** Pod networking is a distinct layer from Node networking. Always verify the "path of truth" from inside the container using `kubectl exec` when external API connections fail.

---

## 3. Helm CRD Metadata Limit: "Too Long" Annotation
* **Description:** The `kube-prometheus-stack` deployment failed in Argo CD with an error: `metadata.annotations: Too long: must have at most 262144 bytes`.
* **Root Cause:** Argo CD's default `kubectl apply` method stores the object's state in a `last-applied-configuration` annotation. The Prometheus Custom Resource Definitions (CRDs) exceeded the maximum allowed size for Kubernetes annotations.
* **Solution:** Enabled **Server-Side Apply** in the Argo CD Application manifest to offload the merge logic to the API server, bypassing the client-side annotation limit.
* **Lesson Learned:** Modern, large-scale community Helm charts often require Server-Side Apply to handle complex CRD structures.



---

## 4. Prometheus Operator: TLS Handshake Failure
* **Description:** The stack remained in a `Progressing` state, and logs revealed: `http: TLS handshake error: remote error: tls: bad certificate`.
* **Root Cause:** In a self-signed `kubeadm` environment, the default Admission Webhooks for the Prometheus Operator fail to validate certificates against the internal Cluster CA.
* **Solution:** Modified `values.yaml` to set `prometheusOperator.admissionWebhooks.enabled: false`, disabling the failing security check for the local lab environment.
* **Lesson Learned:** Production-grade security defaults often assume a formal PKI infrastructure. In a DevSecOps lab, security constraints must be tuned to match the infrastructure's identity management capabilities.

---

## 5. Persistent Volume (PV) Scheduling Deadlock
* **Description:** Prometheus and Alertmanager pods remained in `Pending` status despite 32GB of available system RAM.
* **Root Cause:** The Helm chart requested Persistent Volume Claims (PVCs), but no **StorageClass** was configured on the physical host to provision the underlying disks.
* **Solution:** Overrode the storage specifications in `values.yaml` to use `emptyDir` (ephemeral storage), allowing the pods to run directly in the available node memory.
* **Lesson Learned:** Always verify storage availability before deploying stateful workloads. For ephemeral labs, `emptyDir` is a valid architectural trade-off to prioritize observability over data persistence.
