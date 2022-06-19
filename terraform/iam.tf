# Create a base IAM role for access to EC2.
resource "aws_iam_role" "factorio" {
  name = "FactorioServerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = local.tags
}

# Attach the managed SSM policy to the base role.
resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.factorio.id
}

# Create a custom S3 read/write policy to our bucket.
resource "aws_iam_policy" "s3_read_write" {
  name = "FactorioServerS3ReadWrite"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ListObjectsInBucket",
        Effect   = "Allow",
        Action   = ["s3:ListBucket"],
        Resource = ["arn:aws:s3:::${var.s3_bucket}"]
      },
      {
        Sid      = "AllObjectActions",
        Effect   = "Allow",
        Action   = "s3:*Object",
        Resource = ["arn:aws:s3:::${var.s3_bucket}/factorio/*"]
      }
    ]
  })

  tags = local.tags
}

# Attach the S3 read/write policy to the base IAM role.
resource "aws_iam_role_policy_attachment" "s3_read_write" {
  role       = aws_iam_role.factorio.id
  policy_arn = aws_iam_policy.s3_read_write.arn
}

# Create an EC2 instance profile with the base IAM role.
resource "aws_iam_instance_profile" "factorio" {
  name = "FactorioServerInstanceProfile"
  role = aws_iam_role.factorio.id

  tags = local.tags
}
