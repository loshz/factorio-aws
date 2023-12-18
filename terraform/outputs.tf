output "ec2_instance_id" {
  value = aws_instance.factorio.arn
}

output "ec2_instance_state" {
  value = aws_instance.factorio.instance_state
}

output "ec2_instance_public_ipv4" {
  value = aws_eip.factorio.public_ip
}

output "ec2_instance_public_ipv6" {
  value = aws_instance.factorio.ipv6_addresses[0]
}
