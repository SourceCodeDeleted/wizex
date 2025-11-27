# Couldn't create a public bucket because account permissions root account wasn't allowed to.

I had to add a dependency before adding the policy.

```
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.mongo_backups.id

  depends_on = [
    aws_s3_account_public_access_block.account
  ]

```
