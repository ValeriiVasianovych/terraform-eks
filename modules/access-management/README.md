# AWS EKS Cluster Access Management & Credentials Guide

## Table of Contents
- [AWS EKS Cluster Access Management \& Credentials Guide](#aws-eks-cluster-access-management--credentials-guide)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Step-by-Step Access Setup](#step-by-step-access-setup)
    - [1. Configure AWS Profile \& Credentials](#1-configure-aws-profile--credentials)
    - [2. Generate kubeconfig for EKS](#2-generate-kubeconfig-for-eks)
    - [3. Test Connection \& Permissions](#3-test-connection--permissions)
    - [4. Full Example Workflow](#4-full-example-workflow)
  - [RBAC Schemes \& Comparison](#rbac-schemes--comparison)
    - [Admin Access](#admin-access)
    - [Developer/Test Access](#developertest-access)
    - [Comparison Table \& Best Practices](#comparison-table--best-practices)
  - [Using Temporary AssumeRole Credentials](#using-temporary-assumerole-credentials)
  - [AWS CLI Cache Notes](#aws-cli-cache-notes)

---

## Overview

This guide explains how to manage access to an AWS EKS cluster using AWS IAM users, roles, and Kubernetes RBAC. It covers credential setup, kubeconfig generation, access testing, and best practices for secure access management.

---

## Step-by-Step Access Setup

### 1. Configure AWS Profile & Credentials

Set up AWS credentials for a specific profile:

```sh
aws configure --profile developer
```

Check which IAM user is active for a profile:

```sh
aws sts get-caller-identity --profile developer
```

---

### 2. Generate kubeconfig for EKS

Create or update kubeconfig for connecting to your EKS cluster with a specific profile:

```sh
aws eks update-kubeconfig --region us-east-1 --name eks-cluster-development --profile developer
```

---

### 3. Test Connection & Permissions

Check if `kubectl` can connect and list nodes/pods:

```sh
kubectl get nodes
kubectl get pods
```

Check if the current user has permission to view pods/configmaps:

```sh
kubectl auth can-i get pods
kubectl auth can-i get configmaps
```

---

### 4. Full Example Workflow

1. Configure AWS profile:
   ```sh
   aws configure --profile developer
   ```
2. Verify current IAM user:
   ```sh
   aws sts get-caller-identity --profile developer
   ```
3. Generate kubeconfig:
   ```sh
   aws eks update-kubeconfig --region us-east-1 --name eks-cluster-development --profile developer
   ```
4. View current kubeconfig context:
    ```sh
    kubectl config view --minify
    ```
5. Test access:
   ```sh
   kubectl get nodes
   kubectl auth can-i get pods
   ```

---

## RBAC Schemes & Comparison

### Admin Access

```
IAM User (manager)
   |
   | sts:AssumeRole
   v
IAM Role (eks-admin-role)
   |
   | mapped to EKS group 'admin'
   v
EKS RBAC Group: admin
   |
   | ClusterRoleBinding (admin-binding)
   v
ClusterRole: cluster-admin (full access)
   |
   v
EKS Cluster (full access)
```

### Developer/Test Access

```
IAM User (developer)
   |
   | sts:AssumeRole
   v
IAM Role (dev-test-role)
   |
   | mapped to EKS group 'dev-test'
   v
EKS RBAC Group: dev-test
   |
   | ClusterRoleBinding (dev-test-binding)
   v
ClusterRole: dev-test (limited permissions)
   |
   v
EKS Cluster (only allowed actions)
```

### Comparison Table & Best Practices

| Approach        | admin.yaml (admin)         | dev-test.yaml (dev-test)         |
| -------------- | ------------------------- | ------------------------------- |
| Access Level   | Full (cluster-admin)      | Limited (only necessary)        |
| Risk           | High                      | Minimal, principle of least privilege |
| Usage          | Admins only               | Developers, CI/CD               |
| Best Practice  | Use only for init/emergency | Use for day-to-day work         |

**Best Practices:**
- Minimize the number of users with cluster-admin rights.
- Use separate roles with least privilege for regular work (e.g., dev-test).
- Map IAM users/roles to EKS RBAC groups for access control.

---

## Using Temporary AssumeRole Credentials

1. **Obtain temporary credentials via AssumeRole:**
   ```sh
   aws sts assume-role \
     --role-arn arn:aws:iam::<ACCOUNT_ID>:role/eks-admin-role-<env> \
     --role-session-name my-session \
     --profile manager
   ```
   The response will include temporary keys: `AccessKeyId`, `SecretAccessKey`, `SessionToken`.

2. **Add aws config profile:**
   ```sh
   [profile eks-admin]
    role_arn = arn:aws:iam::312211201134:role/eks-admin-role-development
    source_profile = manager
    ```

3. **Generate kubeconfig:**
   ```sh
   aws eks update-kubeconfig --region <region> --name <cluster> --profile <profile>
   ```
   Or use the environment variables directly.

4. **Test access:**
   ```sh
   kubectl get nodes
   kubectl auth can-i get pods
   ```

---

## AWS CLI Cache Notes

- AWS CLI may cache temporary tokens in `~/.aws/cli/cache/`.
- If you change permissions or keys and behavior doesn't change, try clearing the cache:
  ```sh
  rm -rf ~/.aws/cli/cache/*
  ```
- Then repeat AssumeRole and update kubeconfig.

---
