output "nat_gateway_ip" {
  value = aws_eip.eip.public_ip
}

output "public_ip" {
  value = aws_instance.bastion.public_ip
}
