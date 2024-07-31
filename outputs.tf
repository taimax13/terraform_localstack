output "vpc_id" {
  description = "VPC_ID"
  value       = module.vpc.vpc_id
}
output "user_policy" {
  description = "Policy for user to access his path"
  value       = aws_iam_policy.user_s3_policy.arn
}