# Deployment Architecture

## CI/CD Pipeline Flow

```
Developer Push ──► GitHub Actions Triggered
                        │
                   ┌────▼────┐
                   │  Build  │  npm ci, npm test
                   └────┬────┘
                        │
                   ┌────▼────────┐
                   │  Scan       │  Trivy container scanning
                   │  Container  │  CRITICAL/HIGH vulns = fail
                   └────┬────────┘
                        │
                   ┌────▼────┐
                   │  Push   │  ECR: 866934333672.dkr.ecr.us-east-2
                   │  to ECR │
                   └────┬────┘
                        │
                   ┌────▼──────────┐
                   │  Blue-Green   │  kubectl set image
                   │  Deploy       │  kubectl rollout status
                   └────┬──────────┘
                        │
                   ┌────▼──────────┐
                   │  Health       │  /health endpoint checks
                   │  Verification │
                   └────┬──────────┘
                        │
                   ┌────▼──────────┐
                   │  Auto         │  kubectl rollout undo
                   │  Rollback     │  (on failure)
                   └───────────────┘
```

## Infrastructure Pipeline (Terraform)

```
PR Created ──► terraform plan (review) ──► Merge to main ──► terraform apply (auto-approve)
```

## Kubernetes Cluster Layout

```
EKS Cluster: ecommerce-prod
├── Namespace: ecommerce
│   ├── Deployment: user-service (2 replicas)
│   ├── Deployment: product-service (2 replicas)
│   ├── Deployment: cart-service (2 replicas)
│   ├── Deployment: payment-service (2 replicas)
│   ├── Deployment: order-service (2 replicas)
│   ├── Service: [ClusterIP for each]
│   ├── Ingress: ALB-based API Gateway
│   ├── ConfigMap: ecommerce-config
│   ├── RBAC: ServiceAccount + Role + RoleBinding
│   └── NetworkPolicy: namespace isolation
├── Namespace: monitoring
│   ├── Deployment: prometheus (1 replica)
│   ├── Deployment: grafana (1 replica)
│   ├── DaemonSet: xray-daemon
│   └── ServiceAccount: monitoring-sa
└── Namespace: logging
    ├── Deployment: elasticsearch (1 replica)
    ├── Deployment: logstash (1 replica)
    ├── Deployment: kibana (1 replica)
    └── DaemonSet: filebeat
```

## Node Configuration
- Instance Type: t3.medium (2 vCPU, 4 GiB RAM)
- Min Nodes: 1
- Max Nodes: 3
- Desired: 2
- Auto-scaling enabled via EKS managed node groups

## GitOps Workflow
1. Developer pushes code to feature branch
2. PR triggers CI pipeline (build, test, scan)
3. Merge to main triggers CD pipeline (deploy to EKS)
4. Kubernetes manifests in `kubernetes/` directory are source of truth
5. Ansible playbooks manage node configuration
6. Terraform manages infrastructure state
