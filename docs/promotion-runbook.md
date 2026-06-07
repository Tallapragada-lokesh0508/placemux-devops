# Staging to Production Promotion Runbook

## Pre-promotion checklist
- [ ] All staging smoke tests passing
- [ ] No active alerts on CloudWatch
- [ ] Load test completed successfully
- [ ] Team lead approval obtained
- [ ] Rollback plan ready

## Promotion steps
1. Create release branch: git checkout -b release/v1.x.x
2. Push: git push origin release/v1.x.x
3. CI/CD deploys to staging automatically
4. Monitor staging CloudWatch for 30 minutes
5. Go to GitHub Actions → Deploy to Production → Run workflow
6. Type CONFIRM when prompted
7. Monitor production CloudWatch for 30 minutes

## Rollback steps
1. kubectl rollout undo deployment/placemux-app
2. Or redeploy previous Docker image tag from ECR