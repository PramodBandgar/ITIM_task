provider "aws" {
  region     = "ap-south-1"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

# Creating two EC2 instances using count
resource "aws_instance" "Webserver" {
  count         = 2  # Creates two instances
  ami           = "ami-0fd05997b4dff7aac" # Example AMI ID for Amazon Linux 2
  instance_type = "t2.micro"

  tags = {
    Name = "Webserver-${count.index}"  # Unique name for each instance
  }
}

output "instance_ids" {
  value = aws_instance.example[*].id  # Outputs the IDs of both instances
}
