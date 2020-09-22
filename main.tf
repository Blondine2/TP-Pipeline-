resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/16"
  
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}
resource "aws_route_table" "r" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "main"
  }
}
resource "aws_security_group" "sg" {
  name        = "sg"
  description = "Allow traffic on port 22, 8080 and 80"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "port22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "port8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    description = "port80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*"]
  }

  owners = ["amazon"]
}
resource "aws_instance" "instance" {
  instance_type = "t2.micro"
  key_name = "cles"
  ami           = data.aws_ami.ami.id
  user_data = <<-EOF
		#! /bin/bash
    sudo apt-get update
    sudo yum install httpd
    sudo service httpd start
		echo "<h1>This is my first instance with terraform </h1>" | sudo tee /var/www/html/index.html
	
	EOF

  tags = {
		Name = "Terraform"	
		Batch = "5AM"
	
  }
}


