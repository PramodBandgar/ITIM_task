provider "aws" {
  region = "ap-south-1"  # Specify your AWS region (Mumbai)
}

# Use the default VPC
data "aws_vpc" "default" {
  default = true
}

# Subnet CIDRs
variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["192.168.1.0/24", "192.168.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDR values"
  default     = ["192.168.3.0/24", "192.168.4.0/24"]
}

# Availability Zones (specify the AZs for your region)
variable "aws_azs" {
  type        = list(string)
  description = "Availability Zones for Subnets"
  default     = ["ap-south-1a", "ap-south-1b"]  # Update AZs based on your region
}

# Public Subnets using the default VPC
resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnet_cidrs)
  vpc_id = data.aws_vpc.default.id
  availability_zone = element(var.aws_azs, count.index)
  cidr_block = element(var.public_subnet_cidrs, count.index)

  tags = {
    Name = "public_subnet-${count.index + 1}"
  }
}

# Private Subnets using the default VPC
resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_cidrs)
  vpc_id = data.aws_vpc.default.id
  availability_zone = element(var.aws_azs, count.index)
  cidr_block = element(var.private_subnet_cidrs, count.index)

  tags = {
    Name = "private_subnet-${count.index + 1}"
  }
}

# Key pair (using existing key pair 'WebServer' from AWS account)
resource "aws_key_pair" "ec2_key" {
  key_name = "WebServer"  # Replace with your key name if different
}

# Security Group for the instances
resource "aws_security_group" "ec2_security_group" {
  name_prefix = "my-ec2-sg-"
  description = "Allow inbound and outbound traffic for EC2"

  # Inbound Rule (Allow SSH on port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound Rule (Allow HTTP on port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Rule (Allow all outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Fetch Debian AMI for ap-south-1 (Mumbai)
data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"]  # Debian's official AWS account ID

  filter {
    name   = "name"
    values = ["debian-11-amd64-*"]  # Debian 11 (Bullseye) AMI filter
  }

  # Ensure we are using an AMI that's suitable for EC2 instances in Mumbai (ap-south-1)
  region = "ap-south-1"
}

# Launch WebServer-1 EC2 instance with Debian
resource "aws_instance" "webserver_1" {
  ami           = data.aws_ami.debian.id  # Using Debian 11 AMI
  instance_type = "t2.micro"  # Replace with your preferred instance type
  key_name      = aws_key_pair.ec2_key.key_name
  security_groups = [aws_security_group.ec2_security_group.name]
  subnet_id     = aws_subnet.public_subnets[0].id  # Assign to the first public subnet

  tags = {
    Name = "webserver-1"
  }

  associate_public_ip_address = true
}

# Launch WebServer-2 EC2 instance with Debian
resource "aws_instance" "webserver_2" {
  ami           = data.aws_ami.debian.id  # Using Debian 11 AMI
  instance_type = "t2.micro"  # Replace with your preferred instance type
  key_name      = aws_key_pair.ec2_key.key_name
  security_groups = [aws_security_group.ec2_security_group.name]
  subnet_id     = aws_subnet.public_subnets[1].id  # Assign to the second public subnet

  tags = {
    Name = "webserver-2"
  }

  associate_public_ip_address = true
}

# Output the instance IDs and public IP addresses
output "webserver_1_id" {
  value = aws_instance.webserver_1.id
}

output "webserver_2_id" {
  value = aws_instance.webserver_2.id
}

output "webserver_1_public_ip" {
  value = aws_instance.webserver_1.public_ip
}

output "webserver_2_public_ip" {
  value = aws_instance.webserver_2.public_ip
}
