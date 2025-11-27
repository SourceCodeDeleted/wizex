# S3 buckets must have unique names globally
resource "random_id" "bucket_suffix" {
  byte_length = 8
}