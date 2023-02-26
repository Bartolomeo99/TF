resource "aws_security_group" "bastion" {
  vpc_id = aws_vpc.vpc.id
  name   = "allow-ssh-inbound-${local.bastion_tag}"

  ingress {
    description = "HTTP from Internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-ssh-inbound-${local.bastion_tag}"
  }
}

resource "aws_security_group" "ec2-from-bastion" {
  vpc_id = aws_vpc.vpc.id
  name   = "private-${local.bastion_tag}"

  ingress {
    description = "HTTP from Internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [ aws_security_group.bastion.id ]
  }

  egress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-ssh-inbound-from-${local.bastion_tag}"
  }
}
