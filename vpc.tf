
data "aws_availability_zones" "available" {}

####this is for smooth run also will work
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  #version = "2.77.0"

  name                 = "main-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  private_subnets      =  ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}


# # Create a VPC
# resource "aws_default_vpc" "main" {
#   #cidr_block = "10.0.0.0/16"
#   enable_dns_support = true
#   enable_dns_hostnames = true
#   tags = {
#     Name = "main-vpc"
#   }
# }

# # Create a subnet
# resource "aws_subnet" "main" {
#   vpc_id                  = aws_default_vpc.main.id
#   #cidr_block              = "10.0.1.0/24"
#   availability_zone       = "us-east-1a"
#   map_public_ip_on_launch = true
#   tags = {
#     Name = "main-subnet"
#   }
# }
# # Create the second subnet for database
# resource "aws_subnet" "db_a" {
#   vpc_id                  = aws_default_vpc.main.id
#   #cidr_block              = "10.0.4.0/24"
#   availability_zone       = "us-east-1a"  
#   map_public_ip_on_launch = false          # Database subnets typically don't need public IPs
#   tags = {
#     Name = "db-subnet-a"
#   }
# }

# resource "aws_subnet" "db_b" {
#   vpc_id                  = aws_default_vpc.main.id
#  # cidr_block              = "10.0.3.0/24"
#   availability_zone       = "us-east-1b"  
#   map_public_ip_on_launch = false          # Database subnets typically don't need public IPs
#   tags = {
#     Name = "db-subnet-b"
#   }
# }

# # Create an internet gateway
# # resource "aws_internet_gateway" "main" {
# #   vpc_id = aws_default_vpc.main.id
# #   tags = {
# #     Name = "main-igw"
# #   }
# # }

# # # Create a route table
# # resource "aws_route_table" "main" {
# #   vpc_id = aws_default_vpc.main.id

# #   route {
# #     cidr_block = "0.0.0.0/0"
# #     gateway_id = aws_internet_gateway.main.id
# #   }

# #   tags = {
# #     Name = "main-route-table"
# #   }
# # }

# # Associate the route table with the subnet
# # resource "aws_route_table_association" "main" {
# #   subnet_id      = aws_subnet.main.id
# #   route_table_id = aws_route_table.main.id
# # }
