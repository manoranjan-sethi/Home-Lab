# Known Issues

1. Worker nodes failed to join (conntrack not found)

- **Description:** Worker nodes failed to join because the `conntrack` utility was missing.
- **Lesson learned:** Ensure prerequisites are applied across the entire fleet (control plane and workers). Use automation (Ansible, Terraform) to guarantee identical base packages across nodes.

2. (placeholder for additional issues)