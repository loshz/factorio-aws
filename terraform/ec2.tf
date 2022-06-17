data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "random_password" "server" {
  length      = 32
  upper       = true
  numeric     = true
  special     = true
  min_special = 8
}

data "cloudinit_config" "factorio" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    filename     = "start.sh"
    content      = templatefile("${path.module}/scripts/start.sh", { version = var.factorio_version })
  }

  part {
    content_type = "text/cloud-config"
    filename     = "cloud-config.yaml"
    content = <<EOF
#cloud-config
${jsonencode({
    write_files = [
      {
        path        = "/opt/factorio/data/server-settings.json"
        permissions = "0644"
        owner       = "factorio:factorio"
        encoding    = "b64"
        content     = base64encode(templatefile("${path.module}/factorio/server-settings.json", { password = random_password.server.result }))
      },
    ]
})}
EOF
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

  user_data                   = data.cloudinit_config.factorio.rendered
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
