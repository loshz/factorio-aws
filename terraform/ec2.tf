data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "factorio" {
  ami                         = data.aws_ami.amazon_linux_2.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.factorio.id
  instance_type               = var.ec2_instance_type
  monitoring                  = true
  subnet_id                   = aws_subnet.factorio_public.id
  vpc_security_group_ids      = [aws_security_group.factorio.id]

  user_data                   = templatefile("${path.module}/start.sh", { version = var.factorio_version })
  user_data_replace_on_change = true

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_type = "gp2"
    volume_size = var.ec2_volume_size
  }

  tags = merge(
    { Name = "factorio" },
    local.tags,
  )
}
