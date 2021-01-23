provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}




resource "aws_vpc" "example_vpc" {
  cidr_block       = "10.0.0.0/27"
  instance_tenancy = "default"


  tags = {
    Name = "example_vpc"
  }
}

resource "aws_internet_gateway" "example_gw" {
  vpc_id = aws_vpc.example_vpc.id

  tags = {
    Name = "example_gw"
  }
}


resource "aws_subnet" "example_subnet" {
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = "10.0.0.0/28"

  tags = {
    Name = "example_subnet"
  }
}


resource "aws_route_table" "example_route_table" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_gw.id
  }


  tags = {
    Name = "example_route_table"
  }
}

resource "aws_main_route_table_association" "a" {
  vpc_id       = aws_vpc.example_vpc.id
  route_table_id = aws_route_table.example_route_table.id
}



resource "aws_instance" "example_ec2_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.example_subnet.id
  associate_public_ip_address = true
  security_groups = [
    aws_security_group.allow_ssh.id]
  key_name = aws_key_pair.example_ssh_key.key_name


  tags = {
    Name = "example_ec2_instance"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "aws_security_group to enable ssh"
  vpc_id = aws_vpc.example_vpc.id


  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "allow_http" {
  name = "allow_http"
  description = "aws_security_group to allow http"
  vpc_id = aws_vpc.example_vpc.id


  ingress {
    description = "SSH"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]

  }
  tags = {
    Name = "allow_http"
  }
}
resource "aws_security_group" "allow_https" {
  name = "allow_https"
  description = "aws_security_group to allow https"
  vpc_id = aws_vpc.example_vpc.id

  ingress {
    description = "SSH"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    Name = "allow_https"
  }
}

resource "aws_key_pair" "example_ssh_key" {
  key_name   = "example-ssh-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqAqQ1zlaPjPkn1ummyO16ma5CGJD6M1L9T5Yee3iACPnsjCcUpQi0QrO8wXnsHJL4cFQ1viRvIYwn/ZwyG6WcmOkhXS6lYGxw/mZ8iWJiBL06DafAH1/iC4bFwbfhWqzrFsajTry1X4a7hBdknw4cpZ19yUlJiuqARtru1cJWPWNhF0pyQiZWK0TW90Jc6L7YBeZli1U6lcoaslkwSy9xoYRIeYMOZJh0dY38zwcF4b6qzNqwtZhCKJhdymubV1VkTLklGnzlsPnk4iV/mGIF0Rrhjdji7tE+Z8IIhRN9DyT75J4DRDUoKGhuidGdfic/W1ROc9kSuwuqlshhaCnf steffenweitkamp11@gppglemail.com"
}




output "public_ip" {
  value = aws_instance.example_ec2_instance.public_ip
}
# resource "aws_route_table" "example_route_table"
output "route_table_id" {
  value = aws_route_table.example_route_table.id
}
