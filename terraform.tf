terraform {

    backend "s3" {
    bucket = "Bart-bucket-for-tf-state"
    key = "path/terraform.tfstate"
    region = "eu-east-1"
    dynamodb_table = "tf-state-remote-data"
    encrypt = true

  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-east-1"

}

# resource "aws_s3_bucket" "bucket" {
#   //bucket =""
#   force_destroy = true
#   versioning {
#     enabled = true
#   }
#   server_side_encryption_configuration {
#     rule{
#         apply_server_side_encryption_by_default {
#             sse_algorithm = "AES256"
#         }
#     }
#   }
  
# }


data "aws_ami" "latest-amazon-linux-image"{
  most_recent = true
  owners = ["amazon"]
  filter{
      name = "name"
      values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

locals {
  extra_tag = "extra-tag"
}

resource "aws_instance" "ec2" {

    ami = data.aws_ami.latest-amazon-linux-image.arn
    instance_type = "t2.micro"
    security_groups = [aws_security_group.]
    user_data = <<-EOF
            #!/bin/bash
            echo "Hello world" > index.html
            nohup busybox httpd -f -p 8080 &

            EOF

   tags = {
        name = "EC2"
        ExtraTag = local.extra_tag
   } 

} 

resource "aws_instance" "ec2-2" {

    ami = data.aws_ami.latest-amazon-linux-image.arn
    instance_type = "t2.micro"
    security_groups = [aws_security_group.]
    user_data = <<-EOF
            #!/bin/bash
            echo "Hello world" > index.html
            nohup busybox httpd -f -p 8080 &

            EOF

   tags = {
        name = "EC2 ${count.index}"
   } 
}

data "aws_vpc" "default_vpc" {
    default = true
}

data "aws_subnet_ids" "default_subnet" {
    vpc_id = data.aws_vpc.default_vpc.id
  
}

resource "aws_security_group" "instances" {
    name = "instance-security-group"
  
}

resource "aws_security_group_rule" "allow_http_inbound" {
    type = "ingress"
    security_group_id = aws_security_group.instances.id
    
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.load_balancer.arn

    port = 80

    protocol = "HTTP"

    default_action {
      type = "fixed-response"

      fixed_response{
        content_type = "text/plain"
        message_body = "404: page not found"
        status_code = 404
      }
    }  
}

resource "aws_lb_target_group" "instances" {

    name = "example-target-group"
    port = 8080
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default_vpc.id

    health_check {
      path              = "/" 
      protocol          = "HTTP"
      matcher           = "200"
      interval          = 15
      timeout           = 3
      healthy_threshold = 2
      unhealthy_threshold = 2

    }
}

resource "aws_lb_target_group_attachment" "first_instance" {
    target_group_arn = aws_lb_target_group.instances.arn
    target_id = aws_instance.ec2.id
    port = 8080

}

resource "aws_lb_target_group_attachment" "second_instance" {
    target_group_arn = aws_lb_target_group.instances.arn
    target_id = aws_instance.ec2-2.id
    port = 8080 
}

resource "aws_lb_listener_rule" "instances" {
    listener_arn = aws_lb_listener.http.arn
    priority = 100

    condition {
      path_pattern{
        values = ["*"]
      }
    }
    action {
      type = "forward"
      target_group_arn = aws_lb_target_group.instances.arn

    }
}

resource "aws_security_group" "alb" {
    name = "ALB_SG"
}

resource "aws_security_group_rule" "allow_alb_http_inbound" {
    type = "ingress"
    security_group_id = aws_security_group.alb.id

    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
}

resource "aws_security_group_rule" "allow_alb_outbond" {
    type = "egress"
    security_group_id = aws_security_group.alb.id

    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }


resource "aws_lb" "lb" {
    name = "web-lb"
    load_balancer_type = "application"
    subnets = data.aws_subnet_ids.default_subnet.ids
    security_groups = [aws_security_group.alb.id]
  
}

resource "aws_route53_record" "root" {
    zone_id = aws_route53_zone.primary.zone_id
    name = "bartolomeo1999.com"
    type = "A"

    alias {
      name = aws_lb.load_balancer.dns_name
      zone_id = aws_lb.load_balancer.zone_id
      evaluate_target_health = true
    }
  
}

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}
  

