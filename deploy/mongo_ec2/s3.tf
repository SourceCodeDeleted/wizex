# This will create an S3 bucket for MongoDB backups
# essentially  we will use a random module to define a unique suffix for the bucket name
# then as per requirements we will disable all public access blocking and set a public policy on the bucket
# at the bottom, you will see the public policy defined - 
# there are reasons why people might want this, such as hosting public data sets
# but this is insecure in general and should be used with caution
# Disable S3 Block Public Access at the account level

resource "aws_s3_account_public_access_block" "account" {
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket" "mongo_backups" {
  bucket = "wiz-bucket-${random_id.bucket_suffix.hex}"  # must be globally unique

  tags = {
    Name = "wiz-mongo-backups"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_unblock_public" {
  bucket = aws_s3_bucket.mongo_backups.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Public policy (intentionally insecure)
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.mongo_backups.id


  # this needs to be created first before applying the policy
  depends_on = [
    aws_s3_account_public_access_block.account
  ]


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "PublicRead"
        Effect   = "Allow"
        Principal = "*"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.mongo_backups.arn,
          "${aws_s3_bucket.mongo_backups.arn}/*"
        ]
      }
    ]
  })
}
