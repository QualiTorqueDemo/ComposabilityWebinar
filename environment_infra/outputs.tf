output "sandbox_app_subnet_a_id" {
  value = aws_subnet.sandbox_app_subnet_a.id
}

output "sandbox_app_subnet_a_id" {
  value = aws_subnet.sandbox_app_subnet_b.id
}

output "Default_Security_Group_id" {
  value = aws_security_group.Default_Security_Group.id
}

output "sandbox_vpc_id" {
  value = aws_vpc.sandbox_vpc.id
}
