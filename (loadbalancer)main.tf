resource "aws_vpc" "dev_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "dev_vpc"
  }
}

# 2. Internet Gateway
resource "aws_internet_gateway" "dev_gw" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "dev_gw"
  }
}

# 3. Create Custom Route Table
resource "aws_route_table" "dev_rt" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.dev_gw.id
  }

  tags = {
    Name = "dev_rt"
  }
}
# 4. Create a subnet
resource "aws_subnet" "dev_pubsubnet1" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "dev_pubsubnet"
  }
}

resource "aws_subnet" "dev_privsubnet1" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "dev_privsubnet"
  }
}

resource "aws_subnet" "dev_pubsubnet2" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.0.30.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "dev_pubsubnet2"
  }
}

resource "aws_subnet" "dev_privsubnet2" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.0.40.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "dev_privsubnet2"
  }
}

# 5. Associate subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.dev_pubsubnet1.id
  route_table_id = aws_route_table.dev_rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.dev_pubsubnet2.id
  route_table_id = aws_route_table.dev_rt.id
}

# 6. Create Security Group to allow port 22, 80, 443
resource "aws_security_group" "dev_lb_sg" {
  name        = "dev_lb_sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.dev_vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
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

  tags = {
    Name = "dev_lb_sg"
  }
}
# 7. Create a network interface with ip in the subnet that was created in step 4
resource "aws_network_interface" "dev_eni" {
  subnet_id       = aws_subnet.dev_privsubnet1.id
  private_ips     = ["10.0.20.50"]
  security_groups = [aws_security_group.dev_lb_sg.id]

}

# 8. Assign an elastic IP to network interface created in step 7
resource "aws_eip" "dev_eip" {
  vpc                       = true
  network_interface         = aws_network_interface.dev_eni.id
  associate_with_private_ip = "10.0.20.50"
  depends_on                = [aws_internet_gateway.dev_gw]

}


