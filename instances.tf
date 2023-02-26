resource "aws_instance" "bastion" {
  ami = data.aws_ami.latest-amazon-linux-image.arn
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id     = aws_subnet.public-subnet-1.id
  associate_public_ip_address = true
  user_data = data.template_file.user_data.rendered
  key_name = aws_key_pair.keys.key_name
  root_block_device {
    volume_size = 8
    delete_on_termination = true
    volume_type = "gp2"
    encrypted = true
  }  
  tags = {
      Name = "EC2-${local.bastion_tag}"
  } 
} 

resource "aws_instance" "ec2-2" {
  ami = data.aws_ami.latest-amazon-linux-image.arn
  instance_type = "t2.micro"
  security_groups = [aws_security_group.ec2-from-bastion.id]
  subnet_id     = aws_subnet.private-subnet-1.id
  user_data = data.template_file.user_data.rendered
  tags = {
      Name = "EC2"
  } 
}
