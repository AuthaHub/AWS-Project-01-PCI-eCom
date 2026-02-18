resource "aws_cloudtrail" "main" {
  name                          = "${var.project_prefix}-trail"
  s3_bucket_name                = aws_s3_bucket.logs.id
  s3_key_prefix                 = "cloudtrail-logs"
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_log_file_validation    = true

  tags = merge(local.tags, {
    Name = "${var.project_prefix}-trail"
  })

  depends_on = [aws_s3_bucket_policy.logs]
}