# Store the current Factorio version as an SSM paramater.
resource "aws_ssm_parameter" "factorio" {
  name = "factorio"
  type = "String"
  value = jsonencode({
    version   = var.factorio_version
    s3_bucket = var.s3_bucket
  })
}
