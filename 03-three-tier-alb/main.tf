provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  name     = var.project_name
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
  vpc_id = module.vpc.vpc_id

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
  vpc_id = module.vpc.vpc_id

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
  instance_type          = var.instance_type
  subnet_id = module.vpc.private_subnet_ids[0]
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
  instance_type          = var.instance_type
  subnet_id = module.vpc.private_subnet_ids[1]
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
  subnets = module.vpc.public_subnet_ids
  security_groups    = [aws_security_group.alb.id]

  tags = { Name = "tf-alb"}

}
resource "aws_lb_target_group" "web" {
  name     = "tf-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

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
