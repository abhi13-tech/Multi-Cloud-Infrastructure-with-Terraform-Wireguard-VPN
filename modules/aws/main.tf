resource "aws_vpc" "main" { cidr_block = var.vpc_cidr }
resource "aws_security_group" "wireguard" {}
