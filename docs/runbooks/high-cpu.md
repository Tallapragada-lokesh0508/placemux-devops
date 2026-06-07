# Runbook: High CPU Alert

## Trigger
inference-high-cpu alarm fires

## Impact
Slow AI proctoring responses

## Steps
1. Check AWS Console → EC2 → Auto Scaling Groups
2. Verify scale-up is happening automatically
3. If not scaling manually run:
   aws autoscaling set-desired-capacity \
   --auto-scaling-group-name placemux-inference-asg \
   --desired-capacity 5
4. Monitor CPU — should drop within 5 minutes
5. If CPU stays above 90% after 10 minutes → escalate