# Runbooks - Common Operations

## 1. Deploying a New Service Version

### Prerequisites
- AWS CLI configured with proper credentials
- kubectl configured for the EKS cluster
- Docker installed

### Steps
```bash
# 1. Update kubeconfig
aws eks update-kubeconfig --name ecommerce-prod --region us-east-2

# 2. Build and push new image
cd microservices/<service-name>
docker build -t 866934333672.dkr.ecr.us-east-2.amazonaws.com/<service-name>:<version> .
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 866934333672.dkr.ecr.us-east-2.amazonaws.com
docker push 866934333672.dkr.ecr.us-east-2.amazonaws.com/<service-name>:<version>

# 3. Update deployment
kubectl set image deployment/<service-name> <service-name>=866934333672.dkr.ecr.us-east-2.amazonaws.com/<service-name>:<version> -n ecommerce

# 4. Monitor rollout
kubectl rollout status deployment/<service-name> -n ecommerce

# 5. Verify
kubectl get pods -n ecommerce -l app=<service-name>
```

## 2. Rolling Back a Deployment

```bash
# View rollout history
kubectl rollout history deployment/<service-name> -n ecommerce

# Rollback to previous version
kubectl rollout undo deployment/<service-name> -n ecommerce

# Rollback to specific revision
kubectl rollout undo deployment/<service-name> -n ecommerce --to-revision=<number>

# Verify rollback
kubectl rollout status deployment/<service-name> -n ecommerce
```

## 3. Scaling Services

```bash
# Scale a specific service
kubectl scale deployment/<service-name> -n ecommerce --replicas=<count>

# Verify scaling
kubectl get pods -n ecommerce -l app=<service-name>
```

## 4. Viewing Logs

```bash
# View logs for a specific service
kubectl logs -n ecommerce -l app=<service-name> --tail=100 -f

# View logs for a specific pod
kubectl logs -n ecommerce <pod-name> --tail=100

# View previous container logs (if crashed)
kubectl logs -n ecommerce <pod-name> --previous
```

## 5. Database Operations

```bash
# Connect to RDS from a pod
kubectl run -n ecommerce db-client --rm -it --image=postgres:15 -- psql -h <RDS_ENDPOINT> -U ecomadmin -d ecommerce

# Check database connections
kubectl exec -n ecommerce deploy/user-service -- wget -qO- http://localhost:3001/health
```

## 6. Checking Cluster Health

```bash
# Node status
kubectl get nodes

# All pods across namespaces
kubectl get pods --all-namespaces

# Resource usage
kubectl top nodes
kubectl top pods -n ecommerce

# Events (for debugging)
kubectl get events -n ecommerce --sort-by='.lastTimestamp'
```

## 7. Monitoring Access

```bash
# Port-forward Grafana
kubectl port-forward svc/grafana -n monitoring 3000:80

# Port-forward Prometheus
kubectl port-forward svc/prometheus -n monitoring 9090:9090

# Port-forward Kibana
kubectl port-forward svc/kibana -n logging 5601:80
```

## 8. Certificate/Secret Rotation

```bash
# Update secret in AWS Secrets Manager
aws secretsmanager update-secret --secret-id ecommerce-prod/db-credentials --secret-string '{"username":"...","password":"..."}'

# Restart pods to pick up new secrets
kubectl rollout restart deployment -n ecommerce
```

## 9. Terraform Operations

```bash
# Plan changes
cd terraform
terraform plan -var="db_password=<password>"

# Apply changes
terraform apply -var="db_password=<password>"

# View current state
terraform show

# Import existing resource
terraform import module.<module>.<resource> <aws-id>
```
