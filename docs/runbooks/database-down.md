# Runbook: Database Unavailable

## Trigger
App cannot connect to RDS

## Impact
Complete application outage

## Steps
1. Check AWS Console → RDS → check instance status
2. Check security group allows port 5432 from app_sg
3. Check RDS logs in CloudWatch → /placemux/database
4. If RDS crashed → it auto-restarts in 5 minutes, wait
5. If data corrupted → restore from latest backup
6. Escalate if not resolved in 15 minutes