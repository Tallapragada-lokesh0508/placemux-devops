data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "inference" {
  name_prefix            = "placemux-inference-"
  image_id               = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    curl -sL https://rpm.nodesource.com/setup_18.x | bash -
    yum install -y nodejs
    echo "Inference node ready"
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "placemux-inference" }
  }
}

resource "aws_autoscaling_group" "inference" {
  name                = "placemux-inference-asg"
  min_size            = 1
  max_size            = 10
  desired_capacity    = 1
  vpc_zone_identifier = [aws_subnet.private_app.id]

  launch_template {
    id      = aws_launch_template.inference.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "placemux-inference"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  autoscaling_group_name = aws_autoscaling_group.inference.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 2
  cooldown               = 60
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down"
  autoscaling_group_name = aws_autoscaling_group.inference.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}