# API Gateway for AI/ML inference endpoint
resource "aws_api_gateway_rest_api" "inference" {
  name        = "placemux-inference-api"
  description = "PlaceMux AI Model Inference Endpoint"
  tags        = { Name = "inference-api" }
}

resource "aws_api_gateway_resource" "predict" {
  rest_api_id = aws_api_gateway_rest_api.inference.id
  parent_id   = aws_api_gateway_rest_api.inference.root_resource_id
  path_part   = "predict"
}

resource "aws_api_gateway_method" "post_predict" {
  rest_api_id   = aws_api_gateway_rest_api.inference.id
  resource_id   = aws_api_gateway_resource.predict.id
  http_method   = "POST"
  authorization = "NONE"
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "placemux-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda function for inference
resource "aws_lambda_function" "inference" {
  function_name    = "placemux-inference"
  runtime          = "python3.11"
  handler          = "handler.predict"
  role             = aws_iam_role.lambda_role.arn
  filename         = "../lambda_inference.zip"
  source_code_hash = filebase64sha256("../lambda_inference.zip")
  timeout          = 30
  memory_size      = 1024
  environment {
    variables = {
      ENVIRONMENT = "dev"
    }
  }
  tags = { Name = "inference-lambda" }
}

# Output the endpoint URL for AI/ML team
output "inference_endpoint" {
  value       = "https://${aws_api_gateway_rest_api.inference.id}.execute-api.ap-south-1.amazonaws.com/prod/predict"
  description = "Share this URL with AI/ML team"
}