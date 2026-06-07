## Infrastructure
- [x] VPC with public/private subnets created
- [x] 3 environments exist (dev, staging, prod)
- [x] NAT Gateway configured
- [x] No security group has 0.0.0.0/0 except ALB

## Secrets & Security
- [x] Zero secrets in code
- [x] All secrets in AWS Secrets Manager
- [x] Secrets rotation enabled (30 days)
- [x] .gitignore excludes terraform state and secrets

## Data & Backups
- [x] RDS automated backups enabled (7 day retention)
- [x] AWS Backup plan running (daily + weekly)
- [x] S3 proctoring bucket encrypted
- [x] S3 public access blocked
- [x] S3 versioning enabled

## Monitoring
- [x] CloudWatch Dashboard created
- [x] CPU alarms configured
- [x] RDS storage alarm configured
- [x] SLO alarms configured
- [x] SNS email alerts configured
- [x] X-Ray tracing enabled

## CI/CD
- [x] Dev pipeline auto deploys on push to main
- [x] Staging pipeline on release/* branch
- [x] Production pipeline manual trigger only
- [x] Rollback documented in promotion runbook

## Performance
- [x] Autoscaling configured min=1 max=10
- [x] Load test harness ready (k6)
- [x] Scale up triggers at 70% CPU

## Cost Control
- [x] Monthly budget alert $100
- [x] GPU inference budget alert $50
- [x] Cost tags on all resources

## Operations
- [x] Promotion runbook documented
- [x] On-call schedule defined
- [x] Incident runbooks written