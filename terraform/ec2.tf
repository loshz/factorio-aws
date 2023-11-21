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
  ami                    = data.aws_ami.amazon_linux_2.id
  iam_instance_profile   = aws_iam_instance_profile.factorio.id
  instance_type          = var.ec2_instance_type
  monitoring             = true
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.factorio.id]

  user_data                   = templatefile("../scripts/ec2.sh", { bucket = var.s3_bucket, version = var.factorio_version })
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint = "enabled"
    # Requiring session tokens will enable IMDSv2 and disable IMDSv1.
    http_tokens = "required"
  }

  root_block_device {
    volume_size = var.ec2_volume_size
    volume_type = "gp3"
  }

  tags = { Name = "factorio" }
}

# Create an Elastic IP for public access.
resource "aws_eip" "factorio" {
  instance = aws_instance.factorio.id
  domain   = "vpc"
}
