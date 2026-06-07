resource "aws_ssm_parameter" "db_password" {
  name  = "/placemux/db_password"
  type  = "SecureString"
  value = "demo-password"
}

resource "aws_ssm_parameter" "api_key" {
  name  = "/placemux/api_key"
  type  = "SecureString"
  value = "demo-api-key"
}