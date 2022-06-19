# Get the latest Amazon Linux 2 AMI.
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# Create a single EC2 instance with a public ip.
resource "aws_instance" "factorio" {
  ami                         = data.aws_ami.amazon_linux_2.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.factorio.id
  instance_type               = var.ec2_instance_type
  monitoring                  = true
  subnet_id                   = aws_subnet.factorio_public.id
  vpc_security_group_ids      = [aws_security_group.factorio.id]

  user_data                   = templatefile("${path.module}/scripts/start.sh", { bucket = var.s3_bucket, version = var.factorio_version })
  user_data_replace_on_change = true

  tags = merge(
    { Name = "factorio" },
    local.tags,
  )
}
