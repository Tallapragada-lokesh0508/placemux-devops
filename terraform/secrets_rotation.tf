resource "aws_iam_role" "lambda_rotation" {
  name = "placemux-rotation-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "rotation_basic" {
  role       = aws_iam_role.lambda_rotation.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "rotation_secrets" {
  role       = aws_iam_role.lambda_rotation.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_lambda_function" "rotation" {
  function_name    = "placemux-secret-rotation"
  runtime          = "python3.11"
  handler          = "handler.rotate"
  role             = aws_iam_role.lambda_rotation.arn
  filename         = "../lambda_inference.zip"
  source_code_hash = filebase64sha256("../lambda_inference.zip")
  timeout          = 30
  tags             = { Name = "secret-rotation" }
}

resource "aws_secretsmanager_secret" "db_password" {
  name                    = "placemux/dev/db-password"
  description             = "PlaceMux database password"
  recovery_window_in_days = 7
  tags                    = { Name = "db-password" }
}

resource "aws_secretsmanager_secret_rotation" "db_password" {
  secret_id           = aws_secretsmanager_secret.db_password.id
  rotation_lambda_arn = aws_lambda_function.rotation.arn
  rotation_rules {
    automatically_after_days = 30
  }
}