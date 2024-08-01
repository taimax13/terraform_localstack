variable "region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "The instance type for the NGINX server."
  type        = string
  default     = "t2.micro"
}

variable "db_instance_class" {
  description = "The instance class for the PostgreSQL database."
  type        = string
  default     = "db.t2.micro"
}

variable "db_name" {
  description = "The name of the PostgreSQL database."
  type        = string
}

##set/export TF_VAR_db_password=your_db_password and db_username, possible also vault or other dentity-based secrets and encryption management system 
###mycase $env:TF_VAR_db_password = "your_db_password" tested :: echo $env:TF_VAR_db_password
variable "db_username" {
  description = "The username for the PostgreSQL database."
  type        = string
}

variable "db_password" {
  description = "The password for the PostgreSQL database."
  type        = string 
  sensitive   = true
}

variable "bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
  default     = "my-app-bucket"
}

variable "devops_role_name" {
  description = "The name of the DevOps IAM role."
  type        = string
  default     = "devops_role"
}

variable "vpc_id" {
  description = "VPC id"
  type = string
  default = "main-vpc"
}
