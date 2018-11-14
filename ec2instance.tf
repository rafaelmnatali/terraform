#This template creates 3 EC2 instances (linux) in 3 differente AZs for the us-west-2 region. It uses the latest AMI from Amazon. 

variable "az" {
  type = "map"
  description = "map aws_availability_zones"
  default = {
    "0" = "us-west-2a"
    "1" = "us-west-2b"
    "2" = "us-west-2c"
  }
}

data "aws_ami" "linux" {
  most_recent       =   true
  
  filter {
    name   =    "owner-alias"
    values =    ["amazon"]
  }

  filter {
    name   =    "description"
    values =    ["Amazon Linux 2 AMI*"]
  }

  filter {
    name    =   "virtualization-type"
    values  =   ["hvm"]
  }

  filter {
    name    =   "block-device-mapping.volume-type"
    values  =   ["gp2"]
  }
}


resource "aws_instance" "example" {
  count             = "3"
  ami               = "${data.aws_ami.linux.id}"
  instance_type     = "t2.micro"
  availability_zone = "${lookup(var.az,count.index)}"

  tags {
     Name  = "LinuxTF_${lookup(var.az,count.index)}"
  }

}
