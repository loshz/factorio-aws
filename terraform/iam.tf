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

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.factorio.id
}

resource "aws_iam_instance_profile" "factorio" {
  name = "FactorioServerInstanceProfile"
  role = aws_iam_role.factorio.id
}
