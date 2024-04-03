# require provideres block
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~>4.0.0"
        }
    }  
}

# Provider block
provider "aws" {
    region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available" 
}

locals {
  wordpress_vars = {
          "DB_PASS": var.DB_PASS, 
          "DB_USER": var.DB_USER, 
          "DB_NAME": var.DB_NAME
         }
  set_params = join("\n", [for param, value in local.wordpress_vars : "export ${param}=${value}"])
}


# Wordpress App
resource "aws_instance" "sandbox_wordpress_instance" {
  ami = "ami-016587dea5af03adb"
  count = var.instance_count
  instance_type = var.instance_type
  key_name = var.keypair_name
  subnet_id = var.sandbox_app_subnet_a_id
  security_groups = [ aws_security_group.Wordpress_Security_Group.id, var.Default_Security_Group_id ]
  user_data = "${replace(file("wordpress.sh"), "#SET_ENVIRONMENT_VARIABLES", "${local.set_params}\nexport DB_HOSTNAME=${var.sandbox_mysql_instance_private_dns}")}"
  tags = {Name = "Wordpress"}
}

# Wordpress SG
resource "aws_security_group" "Wordpress_Security_Group" {
  name = "Wordpress Security Group"
  description = "wordpress Security Group"
  vpc_id = var.sandbox_vpc_id  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.ALB_Security_Group.id, var.Default_Security_Group_id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ALB SG
resource "aws_security_group" "ALB_Security_Group" {
  name = "MainALBSG"
  description = "ALB security Group for access to instances"
  vpc_id = var.sandbox_vpc_id  
  ingress {
    description = "public port access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Target Group - wordpress - TODO
resource "aws_lb_target_group" "Wordpress_tg" {
  name     = "Wordpress-LB-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id = var.sandbox_vpc_id
  health_check {
    path = "/wp-includes/images/blank.gif"
    matcher = "200-299"
    healthy_threshold = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "wordpress_tg_attachment" {
  count = var.instance_count
  target_group_arn = aws_lb_target_group.Wordpress_tg.arn
  target_id        = aws_instance.sandbox_wordpress_instance[count.index].id
  port             = 80
}

# Target Group - Empty - TODO
resource "aws_lb_target_group" "Empty_tg" {
  name     = "Empty-LB-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id = var.sandbox_vpc_id
}

# ALB - Wordpress
resource "aws_lb" "Wordpress_alb" {
  name               = "wordpressALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALB_Security_Group.id]
  subnets            = [var.sandbox_app_subnet_a_id, var.sandbox_app_subnet_b_id]

  tags = {Name = "public-route-table"}
}

resource "aws_lb_listener" "worpdress_listener" {
  load_balancer_arn = aws_lb.Wordpress_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Wordpress_tg.arn
  }
}