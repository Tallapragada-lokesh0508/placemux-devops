# Dead letter queue (catches failed messages)
resource "aws_sqs_queue" "assessment_dlq" {
  name                      = "placemux-assessment-dlq"
  message_retention_seconds = 1209600
  tags                      = { Name = "assessment-dlq" }
}

# Main event queue
resource "aws_sqs_queue" "assessment_events" {
  name                       = "placemux-assessment-events"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.assessment_dlq.arn
    maxReceiveCount     = 3
  })
  tags = { Name = "assessment-events" }
}

# SNS topic for broadcasting events
resource "aws_sns_topic" "assessment_notifications" {
  name = "placemux-assessment-notifications"
  tags = { Name = "assessment-notifications" }
}

# Subscribe SQS to SNS
resource "aws_sns_topic_subscription" "sqs_sub" {
  topic_arn = aws_sns_topic.assessment_notifications.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.assessment_events.arn
}