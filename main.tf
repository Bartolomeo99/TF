data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "latest-amazon-linux-image"{
  most_recent = true
  owners = ["amazon"]
  filter{
      name = "name"
      values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "template_file" "user_data" {
  template = file("./user-data.yaml")
}

locals {
  bastion_tag = "bastion"
}

resource "aws_key_pair" "keys" {
  key_name   = "keypair-${local.bastion_tag}"
  public_key = file(var.public_key)
}
