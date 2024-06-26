output "wordpress-ip" {
  value = aws_instance.sandbox_wordpress_instance[0].public_ip
}

output "mysql-ip" {
  value = aws_instance.sandbox_mysql_instance.public_ip
}

output "wordpress-address" {
  value = "http://${aws_lb.Wordpress_alb.dns_name}"
}