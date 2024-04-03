variable DB_USER {
    description = "username of the wordpress database" 
    type = string
    default = "root"
}

variable DB_PASS {
    description = "password of the wordpress database" 
    type = string
    default = "12345"
}

variable DB_NAME {
    description = "name of the wordpress database" 
    type = string
    default = "wordpress_demo"
}

variable aws_region {
    description = "AWS Region in which to deploy" 
    type = string
    default = "eu-west-1"    
}

variable instance_type {
    description = "AWS instance type for each instance" 
    type = string
    default = "t3a.medium"
}

variable keypair_name {
    description = "Existing AWS Keypair to connect to VMs type for each instance" 
    type = string
    default = "TorqueSandbox"
}

variable "Default_Security_Group_id" {}

variable "sandbox_vpc_id" {}

variable "sandbox_app_subnet_a_id" {}