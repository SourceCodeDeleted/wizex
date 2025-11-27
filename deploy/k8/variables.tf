variable "region" {
  default = "us-east-1"
}

variable "profile" {
  default = "default"
}


variable "my_public_ip" {
  description = "Your public IP address to allow SSH and MongoDB access"
  type        = string
}

variable "egress_cidr" {
  description = "CIDR block for egress traffic"
  type        = string
}