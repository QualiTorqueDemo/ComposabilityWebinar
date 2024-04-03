output "mysql-ip" {
  value = aws_instance.sandbox_mysql_instance.public_ip
}

output "sandbox_mysql_instance_private_dns" {
  value = aws_instance.sandbox_mysql_instance.private_dns
}