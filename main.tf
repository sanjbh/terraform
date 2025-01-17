provider "aws" {
  region = "us-east-1"
}


resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}


resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_instance" "example" {
  ami                    = "ami-0df8c184d5f6ae949"
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.instance.id]
  key_name               = aws_key_pair.terraform-example-key.key_name

  user_data = <<-EOF
    #!/bin/sh
    dnf update -y
    dnf install -y busybox
    echo "Hello, world" > index.xhtml
    nohup busybox httpd -f -p ${var.server_port} &
  EOF

  user_data_replace_on_change = true

  tags = {
    Name = "terraform-example"
  }

}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_key_pair" "terraform-example-key" {
  key_name   = "terraform-example-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}
