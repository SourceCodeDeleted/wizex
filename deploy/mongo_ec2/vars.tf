

# variable "backup_bucket_name" {
#   description = "Name of the S3 bucket used for MongoDB backups."
#   type        = string
# }


variable "k8s_private_subnets" {
  description = "List of private subnet CIDRs for the Kubernetes cluster."
  type        = list(string)
}


variable "my_public_ip" {
  description = "Your public IP in CIDR notation (e.g. 203.0.113.5/32)"
  type        = string
  default     = "0.0.0.0/0" # only if needed
}


variable "egress_cidr" {
  description = "CIDR allowed for outbound traffic."
  type        = string
  default     = "0.0.0.0/0"
}


variable "outdated_linux_ami" {
  description = "AMI ID for outdated Linux OS."
  type        = string
}


variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
