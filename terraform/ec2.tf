# Get the latest Amazon Linux 2 AMI.
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Create a single EC2 instance with a public ip.
resource "aws_instance" "factorio" {
  ami                         = try(var.ec2_ami, data.aws_ami.amazon_linux_2023.id)
  iam_instance_profile        = aws_iam_instance_profile.factorio.id
  instance_type               = var.ec2_instance_type
  monitoring                  = true
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.factorio.id]
  user_data_replace_on_change = true

  user_data = <<EOF
#!/bin/bash
curl --proto '=https' --tlsv1.2 -LsSf https://github.com/loshz/factorio-aws/releases/download/0.11.0/factorioctl -o /tmp/factorioctl
chmod +x /tmp/factorioctl
sudo mv /tmp/factorioctl /bin/factorioctl
factorioctl install
factorioctl start
EOF

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
