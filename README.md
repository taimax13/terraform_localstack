# Document for decisions and reasononing

## Supporting Multiple Environments:

To effectively manage multiple environments (e.g., development, staging, production), To use the following approaches:

###  Terraform Workspaces: Terraform workspaces allow you to maintain multiple state files and configurations within a single configuration directory. Each workspace has its own state, making it suitable for managing different environments. For example, To create workspaces for dev, staging, and prod and switch between them as needed.

```bash
terraform workspace new dev
terraform workspace select dev

```

### Separate State Files: Another approach is to use separate state files for each environment. This method involves having distinct configuration files and state files for each environment. For example, you could have dev.tfvars, staging.tfvars, and prod.tfvars files with environment-specific settings.

### Configuration Files: Maintain separate configuration files or directories for each environment. This separation ensures that changes in one environment do not inadvertently affect another. To structure your directory as follows:
```bash
├── dev
│   ├── main.tf
│   ├── variables.tf
│   └── dev.tfvars
├── staging
│   ├── main.tf
│   ├── variables.tf
│   └── staging.tfvars
└── prod
    ├── main.tf
    ├── variables.tf
    └── prod.tfvars
```

## Supporting Dev Environments on Demand

To create and manage dev environments on demand, consider using Terraform modules and CI/CD pipelines:

Terraform Modules: Encapsulate reusable infrastructure components into modules. This allows you to create consistent and repeatable environments. For example, you might have modules for setting up an NGINX server, PostgreSQL database, and S3 bucket.

```bash
module "nginx" {
  source = "./modules/nginx"
  # Variables for the NGINX module
}
```
CI/CD Pipelines: Integrate Terraform with CI/CD pipelines (e.g., GitHub Actions, Jenkins) to automate the creation and destruction of environments. Pipelines can be configured to trigger Terraform commands based on code changes or deployment schedules.

Variables: Use variables to pass environment-specific configurations to your Terraform modules. This allows you to customize each environment without duplicating code.

```bash 
    variable "environment" {
    description = "The environment for which to deploy."
    type        = string
        }
    terraform apply -var "environment=dev"
```
## Scaling Considerations
To handle scaling for millions of users and their activity:

Auto Scaling for NGINX: Use an Auto Scaling group for the NGINX server to automatically adjust the number of instances based on traffic. This helps manage load and ensures high availability.
```bash
resource "aws_autoscaling_group" "nginx_asg" {
  launch_configuration = aws_launch_configuration.nginx.id
  min_size             = 1
  max_size             = 10
  desired_capacity     = 2
  # Scaling policies and other configurations
}
```
Database Scaling: Use Amazon RDS with read replicas to handle read-heavy workloads. This improves performance and scalability by distributing read traffic.

```bash
resource "aws_db_instance" "db" {
  instance_class = "db.t3.medium"
  engine          = "postgres"
  # Additional configurations
}

resource "aws_db_instance" "db_replica" {
  instance_class = "db.t3.medium"
  engine          = "postgres"
  # Additional configurations for read replica
}
```
Photo Storage: S3 is well-suited for handling large volumes of data. Implement lifecycle policies to manage old data and optimize storage costs.

```bash
resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    id     = "expire-old-photos"
    status = "Enabled"

    expiration {
      days = 365
    }
  }
}
```
###  Using Amazon S3 is a great approach for storing user pictures. To achieve user-specific access and thread safety by following these steps:

Bucket Structure: Organize your S3 bucket with a structure like s3://your-bucket/user-id/pictures. This way, each user's pictures are stored in their own directory.

IAM Roles and Policies: Create IAM roles and policies that restrict access to specific directories. For instance, each user could have a policy that allows them to only access s3://your-bucket/user-id/*.

Cognito Identity Pools: Use AWS Cognito to manage user authentication and map users to IAM roles. This way, each authenticated user gets temporary AWS credentials with permissions defined by their IAM role.

Here’s a simplified outline of the process:

Create an S3 bucket.
Set up IAM policies to allow access to specific directories.
Use AWS Cognito to authenticate users and assign the appropriate IAM roles dynamically.
_____________________________________________
### To obtain the user ID through the authentication process. If you're using AWS Cognito, the user ID is typically part of the user attributes stored in the Cognito User Pool. Here's a basic overview:

User Registration/Login: Users register and log in through Cognito.
Cognito User Pool: Upon successful authentication, Cognito provides a unique identifier for each user, known as the sub attribute.
Access User ID: This sub attribute can be used as the user ID. It's included in the ID token that Cognito returns after authentication.
Here’s how to access the user ID in a typical flow:

User authenticates via Cognito and receives an ID token.
Parse the ID token to extract the sub attribute, which is the user ID.
For example, in a web application, you might use AWS Amplify, which simplifies working with Cognito:

```bash
import { Auth } from 'aws-amplify';

Auth.currentAuthenticatedUser()
  .then(user => {
    const userId = user.attributes.sub; // This is the unique user ID
    console.log(userId);
  })
  .catch(err => console.log(err));
```
#### Summary of Onboarding for a new user
Objective: Onboard a new user by creating an S3 bucket object (directory), an IAM policy granting access to this directory, and an IAM role to attach this policy.

Steps
Create a Unique User Directory in the S3 Bucket: Create a directory for the new user in the existing S3 bucket.
Define IAM Policy for the User: Create an IAM policy that allows the user to manage objects in their directory.
Create and Attach IAM Role for the User: Create an IAM role for the user and attach the newly created policy to this role.

```bash
    terraform apply -target=aws_s3_bucket_object.user_folder --var=user_id="new-user-id"
    terraform apply -target=aws_iam_policy.user_s3_policy --var=user_id="new-user-id"
    terraform apply -target=aws_iam_role.user_role --var=user_id="new-user-id"
    terraform apply -target=aws_iam_role_policy_attachment.user_policy_attachment --var=user_id="new-user-id"

```
Please NOTE! on current code the random - plays role of user_id, so we are not using var.user
To use it just adjust the code by creating var.user_id and replacing ref in s3.tf from random_id.unique_id.hex to var.user_id