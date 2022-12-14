module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "monolithic-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2b"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  public_subnets  = ["10.0.1.0/24"]

  # enable_nat_gateway     = true
  # single_nat_gateway     = true
  # one_nat_gateway_per_az = false

  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


# bastion_EC2 security group. CIDR and port ingress can be changed as required.
resource "aws_security_group" "bastion" {
  name   = "for_bastion"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "bastion"
    Environment = "dev"
  }
}

# monolithic_EC2 security group. CIDR and port ingress can be changed as required.
resource "aws_security_group" "monolithic" {
  name   = "for_monolithic"
  vpc_id = module.vpc.vpc_id

  egress {
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "monolithic"
    Environment = "dev"
  }
}

resource "aws_security_group_rule" "sg_ingress_rule_to_monolithic_http" {
  type              = "ingress"
  description       = "Allow from anyone on port 80"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.monolithic.id
}

resource "aws_security_group_rule" "sg_ingress_rule_to_monolithic_https" {
  type              = "ingress"
  description       = "Allow from anyone on port 22"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.monolithic.id
}

resource "aws_security_group_rule" "sg_ingress_rule_to_monolithic_ssh" {
  type              = "ingress"
  description       = "Allow from anyone on port 22"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.monolithic.id
}


# RDS security group. CIDR and port ingress can be changed as required.
resource "aws_security_group" "rds" {
  name   = "for_rds"
  vpc_id = module.vpc.vpc_id
  
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "rds"
    Environment = "dev"
  }
}