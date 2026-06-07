resource "aws_xray_sampling_rule" "placemux" {
  rule_name      = "placemux-sampling"
  priority       = 1000
  reservoir_size = 5
  fixed_rate     = 0.05
  url_path       = "*"
  host           = "*"
  http_method    = "*"
  service_type   = "*"
  service_name   = "*"
  resource_arn   = "*"
  version        = 1
}