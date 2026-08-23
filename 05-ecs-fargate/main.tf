provider "aws" {

  region = "us-east-1"

}

resource "aws_vpc" "main" {

  cidr_block = "192.168.0.0/16"

  tags = {
    Name = "ecs-app-vpc"
  }

}

resource "aws_subnet" "public_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "ecs-app-public-1a"
  }

}

resource "aws_subnet" "public_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "ecs-app-public-1b"
  }
}

resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.11.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "ecs-app-private-1a"
  }

}
resource "aws_subnet" "private_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.12.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "ecs-app-private-1b"
  }
}
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ecs-app-igw"
  }

}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id

  }
  tags = {
    Name = "ecs-app-public-rt"
  }

}
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id

}

resource "aws_route_table_association" "public_1b" {
  subnet_id      = aws_subnet.public_1b.id
  route_table_id = aws_route_table.public.id

}
