# Log groups
resource "aws_cloudwatch_log_group" "app" {
  name              = "/placemux/app"
  retention_in_days = 30
  tags              = { Name = "app-logs" }
}

resource "aws_cloudwatch_log_group" "inference" {
  name              = "/placemux/inference"
  retention_in_days = 30
  tags              = { Name = "inference-logs" }
}

resource "aws_cloudwatch_log_group" "database" {
  name              = "/placemux/database"
  retention_in_days = 90
  tags              = { Name = "database-logs" }
}

# SNS topic for alarm notifications
resource "aws_sns_topic" "alerts" {
  name = "placemux-alerts"
}

resource "aws_sns_topic_subscription" "alert_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "your-email@gmail.com"
}

# CPU high alarm - triggers scale up
resource "aws_cloudwatch_metric_alarm" "inference_high_cpu" {
  alarm_name          = "inference-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Inference CPU above 70% - scaling up"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn, aws_sns_topic.alerts.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.inference.name
  }
}

# CPU low alarm - triggers scale down
resource "aws_cloudwatch_metric_alarm" "inference_low_cpu" {
  alarm_name          = "inference-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 30
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.inference.name
  }
}

# RDS CPU alarm
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "rds-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 120
  statistic           = "Average"
  threshold           = 75
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgres.id
  }
}

# RDS storage alarm
resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  alarm_name          = "rds-low-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 5368709120
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgres.id
  }
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "placemux-overview"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "Inference CPU %"
          metrics = [["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", aws_autoscaling_group.inference.name]]
          period  = 60
          stat    = "Average"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "RDS CPU %"
          metrics = [["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", aws_db_instance.postgres.id]]
          period  = 60
          stat    = "Average"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title   = "RDS Free Storage"
          metrics = [["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", aws_db_instance.postgres.id]]
          period  = 300
          stat    = "Average"
        }
      }
    ]
  })
}