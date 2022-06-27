output "ec2_instance_id" {
  value = aws_instance.factorio.arn
}

output "ec2_instance_state" {
  value = aws_instance.factorio.instance_state
}

output "ec2_instance_public_ip" {
  value = aws_eip.factorio.public_ip
}
