
module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  bucket = "${var.bucket_name}-${random_id.unique_id.hex}"
  policy = aws_iam_policy.user_s3_policy.arn #jsonencode(each.value.policy)
  block_public_acls   = true
  block_public_policy = true
}


### in module it is missing folder structure object -> below the creation of the folder structure
resource "aws_s3_bucket_object" "folder" {
  bucket = "${var.bucket_name}-${random_id.unique_id.hex}"
  acl    = "private"
  key    = "${random_id.unique_id.hex}/"
  depends_on = [ module.s3-bucket ]
}


resource "random_id" "unique_id" {
  byte_length = 8
}

resource "aws_iam_policy" "user_s3_policy" {
  name        = "UserS3Policy-${random_id.unique_id.hex}"
  description = "IAM policy for allowing user to manage his S3 bucket objects"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = ["arn:aws:s3:::${var.bucket_name}/${random_id.unique_id.hex}", "arn:aws:s3:::${var.bucket_name}/${random_id.unique_id.hex}/*"]
      }
    ]
  })
}

# Create a Lifecycle Policy for the S3 bucket
resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  bucket = "${var.bucket_name}-${random_id.unique_id.hex}"
  rule {
    id     = "expire-old-photos"
    status = "Enabled"

    expiration {
      days = 365
    }
  }
  depends_on = [ module.s3-bucket ]
}