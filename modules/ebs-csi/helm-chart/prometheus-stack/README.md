# Prometheus Stack for Service Manager Monitoring

© 2025, Nokia  
All rights reserved.  
This is unpublished proprietary source code of Nokia. The copyright notice does not imply publication or distribution of this code.

---

## Overview

This Helm chart, based on the official [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack), is designed to deploy a monitoring system in Kubernetes tailored for the **Service Manager** application. It monitors the application, its components, and the underlying infrastructure using:

- **Prometheus** for metric collection
- **Grafana** for visualization
- Custom CRD objects like `ServiceMonitor` for configuration

---

## Key Modifications

This chart diverges from the original `kube-prometheus-stack` with the following changes:

- Removed unused components, such as AlertManager.
- Added 50GB Persistent Volumes for Prometheus and Grafana to store historical metrics.
- Enabled automatic discovery of metric endpoints across all cluster namespaces.
- Included pre-configured Grafana dashboards for Service Manager:
  - General metrics
  - Database status
  - HTTP request metrics
- Configured access to Prometheus and Grafana via Ingress objects using AWS Application Load Balancer (ALB).
- Set up `ServiceMonitor` to collect application metrics without direct Prometheus modifications.

---

## Installation

To install the Helm chart, run:

```bash
helm install prometheus-stack prometheus-stack/ --namespace monitoring --create-namespace
```

This creates the `monitoring` namespace (if it doesn't exist) and deploys the chart's resources.

> **Prerequisite**: Ensure the AWS Load Balancer Controller is configured and running in your cluster.

---

## Configuring Ingress Access

### Accessing Grafana

Grafana's web interface is accessible externally via a DNS name configured in AWS Route53. Below is the Ingress manifest for Grafana:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: prometheus-stack-grafana
  namespace: monitoring
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/group.name: grafana
    alb.ingress.kubernetes.io/backend-protocol: HTTP
    alb.ingress.kubernetes.io/healthcheck-path: /
    alb.ingress.kubernetes.io/healthcheck-port: "80"
    alb.ingress.kubernetes.io/healthcheck-protocol: HTTP
    alb.ingress.kubernetes.io/inbound-cidrs: 131.228.32.160/27,131.228.2.0/27,18.193.255.169/32,18.156.44.147/32
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS": 443}]'
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/tags: account_id=707078929101,...
    alb.ingress.kubernetes.io/wafv2-acl-arn: arn:aws:wafv2:...
spec:
  rules:
    - host: grafana.portal.incubator.aut.sdf.saas.nokia.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: prometheus-stack-grafana
                port:
                  number: 80
```

Apply the manifest:

```bash
kubectl apply -f grafana-ingress.yaml
```

This creates an external ALB, making Grafana accessible.

### Accessing Prometheus

Prometheus is similarly exposed via an Ingress:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: prometheus-stack-prometheus
  namespace: monitoring
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/group.name: prometheus
    alb.ingress.kubernetes.io/backend-protocol: HTTP
    alb.ingress.kubernetes.io/healthcheck-path: /
    alb.ingress.kubernetes.io/healthcheck-port: "9090"
    alb.ingress.kubernetes.io/healthcheck-protocol: HTTP
    alb.ingress.kubernetes.io/inbound-cidrs: 131.228.32.160/27,...
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS": 443}]'
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/wafv2-acl-arn: arn:aws:wafv2:...
    alb.ingress.kubernetes.io/tags: account_id=707078929101,...
spec:
  rules:
    - host: prometheus.portal.incubator.aut.sdf.saas.nokia.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: prometheus-stack-prometheus
                port:
                  number: 9090
```

Apply the manifest:

```bash
kubectl apply -f prometheus-ingress.yaml
```

### Verifying Ingress Resources

Check the status of Ingress resources:

```bash
kubectl get ingress -n monitoring
```

Expected output:

```
NAME                         HOSTS                                                ADDRESS
prometheus-stack-grafana     grafana.portal.incubator.aut.sdf.saas.nokia.com     k8s-grafana-xxxx.elb.amazonaws.com
prometheus-stack-prometheus  prometheus.portal.incubator.aut.sdf.saas.nokia.com  k8s-prometheus-yyyy.elb.amazonaws.com
```

---

## Collecting Metrics from Service Manager

### Verify the Service

Ensure the `sf-service-manager` Kubernetes service exists:

```bash
kubectl get svc -n lm | grep service
```

Example output:

```
sf-service-manager   ClusterIP   172.20.213.246   <none>        8443/TCP   125d
```

### Check Service Labels

Verify the service has the correct label for `ServiceMonitor`:

```bash
kubectl get svc sf-service-manager -n <namespace> --show-labels
```

Expected label:

```yaml
app.kubernetes.io/name=sf-service-manager
```

### Create a ServiceMonitor

Create the following `ServiceMonitor` manifest:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: sf-service-manager-metrics-monitor
  namespace: monitoring
  labels:
    release: prometheus-stack
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: sf-service-manager
  namespaceSelector:
    any: true
  endpoints:
    - port: https
      path: /management/prometheus
      interval: 30s
      scheme: https
      tlsConfig:
        insecureSkipVerify: true
```

Apply it:

```bash
kubectl apply -f servicemonitor.yaml
```

Prometheus will automatically detect the `ServiceMonitor` and start scraping the specified endpoint.

---

## Verifying Metric Collection

For local access to the Prometheus UI:

```bash
kubectl port-forward svc/prometheus-stack-prometheus -n monitoring 9090
```

Open in your browser:

```
http://localhost:9090/targets
```

Alternatively, verify the `sf-service-manager` target is in the "UP" state using the Prometheus UI via the Ingress URL.

---

## Grafana

### Access

Access Grafana at:

```
https://grafana.portal.incubator.aut.sdf.saas.nokia.com
```

### Default Credentials

- **Username**: `admin`
- **Password**: Auto-generated during chart installation or matches the username.

> **Recommendation**: Change the password immediately after the first login.

### Pre-installed Dashboards

The chart includes the following dashboards:

- **Service Manager General**: Displays application health, CPU/RAM usage, pod count, uptime, and restarts.
- **Service Manager DB**: Shows database metrics, including response times, connection counts, and errors.
- **Service Manager HTTP**: Visualizes REST API metrics, such as response codes, latency, and request volume.

Access them via: **Dashboards → Search for "Service Manager"**.

---

## Data Storage Configuration

### Verify Persistent Volume Claims

Check PVCs for Prometheus and Grafana:

```bash
kubectl get pvc -n monitoring
```

Ensure PVCs are created with at least 50Gi capacity. Verify the `StorageClass` (e.g., `gp2` or `gp3` for AWS EBS).

---

## Conclusion

This Helm chart provides a robust monitoring infrastructure for the Service Manager application in Kubernetes, featuring:

- Automated Prometheus metric collection
- Flexible Grafana visualizations
- Configurable metric scraping via `ServiceMonitor` CRDs
- Seamless access through AWS ALB Ingress