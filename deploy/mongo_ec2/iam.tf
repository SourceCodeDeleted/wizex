resource "aws_iam_role" "ec2_role" {
  name = "wiz-mongo-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

# Overly permissive (required by Wiz)
# This allows the role to be able to do anything in the account
resource "aws_iam_role_policy" "ec2_insecure_policy" {
  name = "wiz-mongo-ec2-insecure"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "*"
      Resource = "*"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "wiz-mongo-profile"
  role = aws_iam_role.ec2_role.name
}
