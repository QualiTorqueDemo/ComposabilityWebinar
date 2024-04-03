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

# MySQL App
resource "aws_instance" "sandbox_mysql_instance" {
  ami = "ami-016587dea5af03adb"
  instance_type = var.instance_type
  key_name = var.keypair_name
  subnet_id = var.sandbox_app_subnet_a_id
  security_groups = [ aws_security_group.MySQL_Security_Group.id, var.Default_Security_Group_id ]
  user_data = "${replace(file("mysql.sh"), "#SET_ENVIRONMENT_VARIABLES", local.set_params)}"
  tags = {Name = "MySQL"}
}


# MySQL SG
resource "aws_security_group" "MySQL_Security_Group" {
  name = "MySQL Security Group"
  description = "mysql Security Group"
  vpc_id = var.sandbox_vpc_id  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [var.Default_Security_Group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

