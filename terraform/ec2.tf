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
  iam_instance_profile        = aws_iam_role.factorio.id
  instance_type               = var.ec2_instance_type
  monitoring                  = true
  subnet_id                   = aws_subnet.factorio_public.id
  vpc_security_group_ids      = [aws_security_group.factorio.id]

  tags = merge(
    { Name = "factorio" },
    local.tags,
  )
}
