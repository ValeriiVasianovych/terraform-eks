# Setting Up Horizontal Pod Autoscaler (HPA) in AWS EKS

## Purpose

Automatically scale the number of pods based on load (CPU, memory) in a Kubernetes cluster running on AWS EKS. This improves application stability and optimizes infrastructure costs.

---

## Theoretical Background

- HPA scales the number of pods based on metrics, typically CPU or memory usage.
- A `resources` block must be defined in the Deployment or StatefulSet for HPA to work.
- Without resource requests, HPA cannot determine a scaling target and will show `unknown` status.
- Avoid using `replicas` in manifests when using GitOps tools (e.g., ArgoCD, FluxCD) to prevent conflicts with HPA.
- HPA targets Deployments by name, not labels.
- Custom metrics (e.g., requests per second) require additional components and setup.

---

## Installing and Configuring Metrics Server

1. **Metrics Server** is required to collect metrics from kubelets and expose them via the Kubernetes API.
2. It is deployed via Terraform using the `helm_release` resource.
3. Terraform providers can authenticate via AWS CLI (`exec`) or token.
4. It is recommended to initialize providers in the environment folder rather than inside modules.
5. Explicit dependency on the Node Group should be defined to prevent Helm deployment errors.
6. After deployment:
   - Check the `metrics-server` logs for errors.
   - Use `kubectl top pods` and `kubectl top nodes` to verify metrics collection.

---

## HPA Configuration Example

1. A sample application is deployed with CPU resource requests specified.
2. A service is created to generate load.
3. An HPA object is defined:
   - Targets the Deployment by name.
   - Sets minimum and maximum pod counts.
   - Specifies target CPU and/or memory utilization thresholds.
4. Manifests are applied and functionality is verified.
5. When load is applied (e.g., Fibonacci calculation), HPA increases the number of pods.
6. When the load drops, HPA automatically scales the pod count down.

---

## Monitoring HPA

Useful commands:

```bash
watch -t kubectl get hpa -n <namespace>
watch -t kubectl get pods -n <namespace>
kubectl top pods -n <namespace>
kubectl logs <metrics-server-pod> -n kube-system
````

---

## What Was Achieved

* Metrics Server was installed and configured.
* An application with appropriate resource requests was deployed.
* HPA was set up and tested.
* Load was simulated and autoscaling behavior was verified.

---

## Benefits

* **Automated Scaling** — pod count adjusts to match the current load.
* **Resource Efficiency** — pods run only when needed, reducing infrastructure costs.
* **Application Stability** — handles traffic spikes without downtime.
* **GitOps Integration** — properly configured HPA works seamlessly with tools like ArgoCD and FluxCD.

---

## Conclusion

HPA is a critical component for ensuring high availability and performance in Kubernetes applications. When used in AWS EKS, it enables efficient, automatic resource management in response to real-time load changes.