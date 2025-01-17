# Security Group for NGINX
resource "aws_security_group" "nginx_sg" {
  name        = "nginx-sg"
  description = "Allow HTTP and HTTPS traffic to the NGINX server"
  vpc_id      = module.vpc.vpc_id ## if we are grabbing it from vars var.vpc_id or can be also extracted from data 

  # Allow inbound HTTP and HTTPS traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//data "aws_ami" "ubuntu" {
//  most_recent = true
//
//  filter {
//    name   = "name"
//    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
//  }
//
//  filter {
//    name   = "virtualization-type"
//    values = ["hvm"]
//  }
//
//  owners = ["099720109477"] # Canonical
//}

module "ec2_instances" {
    source = "terraform-aws-modules/ec2-instance/aws"
    count = 1

    name = "ec2-nginx-test"
    ###after 100000 of try we will go with default
    #ami = "ami-0427090fd1714168b" #"ami-0582e4fe9b72a5fe1"
    instance_type = var.instance_type
    vpc_security_group_ids = [aws_security_group.nginx_sg.id]
    subnet_id              = module.vpc.public_subnets[0]
    #key_name = "Nginxtest"#var.key_name
    user_data = file("userdata.tpl")

    tags = {
        Name = "Nginxtest"
    }
}

