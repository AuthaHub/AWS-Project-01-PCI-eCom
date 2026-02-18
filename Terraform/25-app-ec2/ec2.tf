data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64*"]
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y nginx
              systemctl enable nginx
              echo "<h1>${var.project_prefix} - App Placeholder</h1><p>ALB -> EC2 is working.</p>" > /usr/share/nginx/html/index.html
              systemctl start nginx
              EOF

  tags = merge(local.tags, {
    Name = "${var.project_prefix}-app-ec2"
  })
}

resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.app.private_ip
  port             = 80
}
