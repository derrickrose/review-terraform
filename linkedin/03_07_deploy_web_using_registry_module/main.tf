data "aws_vpc" "default" { # data is actually resouces already existing in aws
  default = true
}

data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  tags = {
    Name = "web"
  }

  # security_groups = [aws_security_group.web.name] #deprecated 
  #   vpc_security_group_ids = [aws_security_group.web.id]
  vpc_security_group_ids = [module.web_new_sg.security_group_id] # we need to pass the security group id from the module to the instance so it can be associated with the instance

}

# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/5.3.0
module "web_new_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name   = "web_new_sg"
  vpc_id = data.aws_vpc.default.id # we need to pass the vpc id to the module so it can create the security group in the correct vpc

  # as shown on the documentation of the module, we can define some predefined rules for our security group, in this case we want to allow http and https traffic, and also allow all outbound traffic
  # HTTP 
  # http-80-tcp   = [80, 80, "tcp", "HTTP"]
  # http-8080-tcp = [8080, 8080, "tcp", "HTTP"]
  # # HTTPS
  # https-443-tcp  = [443, 443, "tcp", "HTTPS"]
  # https-8443-tcp = [8443, 8443, "tcp", "HTTPS"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"] # we can use some predefined rules from the module, in this case we want to allow http and https traffic
  ingress_cidr_blocks = ["0.0.0.0/0"]                    # we want to allow traffic from all ipv4 addresses

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

# this will be replaced by the module
resource "aws_security_group" "web" {
  name        = "web"
  description = "Allow http, https in, everything out"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "allow_http_in" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # defines what networks can access this port, in this case all ipv4 addresses
  security_group_id = aws_security_group.web.id
}


resource "aws_security_group_rule" "allow_https_in" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "allow_everything_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
}