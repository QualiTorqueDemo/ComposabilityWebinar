output "mysql-dns" {
  value = aws_instance.sandbox_mysql_instance.private_dns
}
