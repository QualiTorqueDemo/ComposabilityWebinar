output "mysql-ip" {
  value = aws_instance.sandbox_mysql_instance.public_ip
}
