# Declare the AWS Access Key and Secret Key variables
variable "access_key" {
  description = "AWS Access Key"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "AWS Secret Key"
  type        = string
  sensitive   = true
}

#provider "aws" {
# region     = "ap-south-1"
#  access_key = var.access_key
#  secret_key = var.secret_key
#}
