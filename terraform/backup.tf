resource "aws_iam_role" "backup" {
  name = "placemux-backup-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "backup.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_backup_vault" "main" {
  name = "placemux-backup-vault"
  tags = { Name = "backup-vault" }
}

resource "aws_backup_plan" "main" {
  name = "placemux-backup-plan"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 3 * * ? *)"
    start_window      = 60
    completion_window = 180
    lifecycle {
      delete_after = 30
    }
  }

  rule {
    rule_name         = "weekly-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 3 ? * SUN *)"
    start_window      = 60
    completion_window = 180
    lifecycle {
      delete_after = 90
    }
  }

  tags = { Name = "backup-plan" }
}

resource "aws_backup_selection" "rds" {
  name         = "rds-backup"
  iam_role_arn = aws_iam_role.backup.arn
  plan_id      = aws_backup_plan.main.id
  resources    = [aws_db_instance.postgres.arn]
}