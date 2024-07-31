
# # Create a security group for the RDS instance
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allow database traffic"
  vpc_id      = module.vpc.vpc_id #module.vpc.

  # Allow inbound traffic from the NGINX security group on PostgreSQL port (5432)
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.nginx_sg.id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a DB Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = tolist(module.vpc.private_subnets)
  tags = {
    Name = "my-db-subnet-group"
  }
}

# Example RDS Instance
#https://docs.aws.amazon.com/AmazonRDS/latest/PostgreSQLReleaseNotes/postgresql-versions.html#postgresql-version17
resource "aws_db_instance" "db" {
  allocated_storage    = 5
  engine               = "postgres"
  engine_version       = "16.3"
  instance_class         = "db.t3.micro"
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  username             = var.db_username
  password             = var.db_password
  skip_final_snapshot  = true
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  tags = {
    Name = "mydatabase"
  }
}

#example with modification to private subnets was kindly borrowed from here https://developer.hashicorp.com/terraform/tutorials/aws/aws-rds