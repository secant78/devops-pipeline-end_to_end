# Disaster Recovery Procedures

## DR Strategy Overview

| Component     | Strategy              | RPO      | RTO      |
|--------------|-----------------------|----------|----------|
| RDS          | Automated backups     | 24 hours | 1 hour   |
| ElastiCache  | Session recreation    | 0 (stateless) | 5 min |
| EKS          | Multi-AZ node groups  | 0        | 10 min   |
| S3/CloudFront| Cross-region replication| Minutes | 15 min  |
| Application  | Container re-deploy   | 0        | 5 min    |

## Scenario 1: Single AZ Failure

**Impact**: Reduced capacity, some pods rescheduled
**Auto-Recovery**: EKS automatically reschedules pods to healthy AZs

### Verification Steps
```bash
# Check node availability
kubectl get nodes -o wide

# Check pod distribution
kubectl get pods -n ecommerce -o wide

# Verify all services are running
for svc in user-service product-service cart-service payment-service order-service; do
  echo "--- $svc ---"
  kubectl get pods -n ecommerce -l app=$svc
done
```

## Scenario 2: RDS Primary Failure

**Impact**: Write operations unavailable
**Recovery**: Promote read replica

### Steps
```bash
# 1. Check RDS status
aws rds describe-db-instances --db-instance-identifier ecommerce-prod-primary --query 'DBInstances[0].DBInstanceStatus'

# 2. Promote read replica to primary
aws rds promote-read-replica --db-instance-identifier ecommerce-prod-read-replica

# 3. Wait for promotion (5-10 minutes)
aws rds wait db-instance-available --db-instance-identifier ecommerce-prod-read-replica

# 4. Update application configuration
kubectl edit configmap ecommerce-config -n ecommerce
# Change DB_HOST to new primary endpoint

# 5. Restart application pods
kubectl rollout restart deployment -n ecommerce

# 6. Update Secrets Manager
aws secretsmanager update-secret --secret-id ecommerce-prod/db-credentials \
  --secret-string '{"host":"<new-endpoint>","port":5432,"dbname":"ecommerce","username":"ecomadmin","password":"<password>"}'

# 7. Recreate read replica from new primary
# (Handled by Terraform after incident)
```

## Scenario 3: Complete Region Failure

**Impact**: All services unavailable
**Recovery**: Deploy to DR region (us-west-2)

### Steps
```bash
# 1. Switch to DR region
export AWS_DEFAULT_REGION=us-west-2

# 2. Apply Terraform in DR region
cd terraform
terraform workspace select dr || terraform workspace new dr
terraform apply -var="aws_region=us-west-2" -var="db_password=<password>"

# 3. Restore RDS from latest snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier ecommerce-dr-primary \
  --db-snapshot-identifier <latest-snapshot-id> \
  --region us-west-2

# 4. Update kubeconfig for DR cluster
aws eks update-kubeconfig --name ecommerce-prod --region us-west-2

# 5. Deploy application
kubectl apply -f kubernetes/namespaces.yaml
kubectl apply -f kubernetes/rbac.yaml
kubectl apply -f kubernetes/configmap.yaml
kubectl apply -f kubernetes/deployments/
kubectl apply -f kubernetes/ingress.yaml

# 6. Update DNS/CloudFront to point to DR region
# (Update Route 53 if using custom domain)

# 7. Verify all services
for svc in user-service product-service cart-service payment-service order-service; do
  kubectl rollout status deployment/$svc -n ecommerce
done
```

## Scenario 4: EKS Cluster Corruption

**Impact**: All services unavailable
**Recovery**: Recreate cluster from IaC

### Steps
```bash
# 1. Destroy and recreate EKS cluster
cd terraform
terraform destroy -target=module.eks -var="db_password=<password>"
terraform apply -var="db_password=<password>"

# 2. Update kubeconfig
aws eks update-kubeconfig --name ecommerce-prod --region us-east-2

# 3. Redeploy all resources
kubectl apply -f kubernetes/namespaces.yaml
kubectl apply -f kubernetes/rbac.yaml
kubectl apply -f kubernetes/configmap.yaml
kubectl apply -f kubernetes/deployments/
kubectl apply -f kubernetes/ingress.yaml
kubectl apply -f kubernetes/monitoring/

# 4. Verify cluster
kubectl get nodes
kubectl get pods --all-namespaces
```

## Scenario 5: Security Breach

### Immediate Response
```bash
# 1. Isolate affected services
kubectl scale deployment/<affected-service> -n ecommerce --replicas=0

# 2. Rotate all secrets
aws secretsmanager rotate-secret --secret-id ecommerce-prod/db-credentials
aws secretsmanager rotate-secret --secret-id ecommerce-prod/api-keys

# 3. Rotate RDS password
aws rds modify-db-instance --db-instance-identifier ecommerce-prod-primary --master-user-password <new-password>

# 4. Review WAF logs
aws wafv2 get-sampled-requests --web-acl-arn <waf-arn> --rule-metric-name ecommerce-prod-waf --scope CLOUDFRONT --time-window StartTime=<start>,EndTime=<end> --max-items 100

# 5. Check CloudTrail for unauthorized access
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=ConsoleLogin --start-time <start> --end-time <end>

# 6. Redeploy with updated secrets
kubectl rollout restart deployment -n ecommerce
```

## Backup Schedule

| Resource      | Backup Type        | Frequency  | Retention |
|--------------|--------------------|------------|-----------|
| RDS          | Automated snapshot | Daily      | 7 days    |
| RDS          | Manual snapshot    | Weekly     | 30 days   |
| Terraform State| S3 versioning    | Every apply| Indefinite|
| Container Images| ECR             | Every build| 30 images |
