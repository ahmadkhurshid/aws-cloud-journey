provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "tf-vpc"
  }
}

resource "aws_subnet" "public_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.16.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "tf-public-1a"
  }
}
resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.16.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "tf-private-1a"
  }
}

resource "aws_subnet" "public_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.16.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "tf-public-1b"
  }
}

resource "aws_subnet" "private_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.16.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "tf-private-1b"
  }
}

resource "aws_subnet" "private_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.16.6.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "tf-private-1c"
  }

}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "tf-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "tf-public-rt"
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
# Find the latest Amazon Linux 2023 image
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Security group for the load balancer
resource "aws_security_group" "alb" {
  name   = "tf-alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
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

  tags = { Name = "tf-alb-sg" }
}

# Security group for the web servers
resource "aws_security_group" "web" {
  name   = "tf-web-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "tf-web-sg" }
}

resource "aws_instance" "web_1a" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_1a.id
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello from server 1a" > /index.html
    cd / && nohup python3 -m http.server 80 &
  EOF

  tags = { Name = "tf-web-1a" }
}

resource "aws_instance" "web_1b" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_1b.id
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello from server 1b" > /index.html
    cd / && nohup python3 -m http.server 80 &
  EOF

  tags = { Name = "tf-web-1b" }
}
resource "aws_lb" "main" {
  name               = "tf-alb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_1a.id, aws_subnet.public_1b.id]
  security_groups    = [aws_security_group.alb.id]

  tags = { Name = "tf-alb" }
}

resource "aws_lb_target_group" "web" {
  name     = "tf-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }

  tags = { Name = "tf-web-tg" }
}

resource "aws_lb_target_group_attachment" "web_1a" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web_1a.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web_1b" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web_1b.id
  port             = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

output "alb_url" {
  value = "http://${aws_lb.main.dns_name}"
}

output "vpc_id" {
  value = "http://${aws_vpc.main.id}"
}