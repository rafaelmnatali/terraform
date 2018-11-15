#This template creates a VPC, a Internet Gateway, 3 Public Subnets, 3 Private Subnets, and 3 database Private Subnets in us-west-2 region.

resource "aws_vpc" "devVPC" {
  cidr_block  = "10.0.0.0/16"

  tags {
    Name  = "devVPCTerraform"
  }
}

resource "aws_internet_gateway" "devIGWTerraform" {
  vpc_id = "${aws_vpc.devVPC.id}"
  
  tags {
    Name  = "devIGWTerraform"
  }
}

resource "aws_route_table" "PublicRoute" {
  vpc_id  = "${aws_vpc.devVPC.id}"
  
  route {
    cidr_block  =   "0.0.0.0/0"
    gateway_id  =   "${aws_internet_gateway.devIGWTerraform.id}"  
  }

  tags {
    Name  = "devPublicRoute"
  }
}

variable "az" {
  type = "map"
  description = "map aws_availability_zones"
  default = {
    "0" = "us-west-2a"
    "1" = "us-west-2b"
    "2" = "us-west-2c"
  }
}

variable "cidr_public" {
  type = "map"
  description = "map public subnet cidr_block per availability_zone"
  default = {
    "0" = "10.0.128.0/20"
    "1" = "10.0.144.0/20"
    "2" = "10.0.160.0/20"
  }
}

resource "aws_subnet" "devPublicSubnet" {
  count             = "3"
  availability_zone = "${lookup(var.az,count.index)}"
  vpc_id            = "${aws_vpc.devVPC.id}"
  cidr_block        = "${lookup(var.cidr_public,count.index)}"
  
   tags {
     Name  = "Public"
   }
}

data "aws_subnet_ids" "public" {
  depends_on = ["aws_subnet.devPublicSubnet"]
  vpc_id = "${aws_vpc.devVPC.id}"

  tags {
    Name = "Public"
  }
}

resource "aws_route_table_association" "rt_public_association" {
  depends_on = ["aws_subnet.devPublicSubnet"]
  count           =   "3"
  subnet_id       =   "${element(data.aws_subnet_ids.public.ids, count.index)}"
  route_table_id  =   "${aws_route_table.PublicRoute.id}"
}

variable "cidr_private" {
  type = "map"
  description = "map private subnet cidr_block per availability_zone"
  default = {
    "0" = "10.0.0.0/19"
    "1" = "10.0.32.0/19"
    "2" = "10.0.64.0/19"
  }
}

resource "aws_subnet" "devPrivateSubnet" {
  count             = "3"
  availability_zone = "${lookup(var.az,count.index)}"
  vpc_id            = "${aws_vpc.devVPC.id}"
  cidr_block        = "${lookup(var.cidr_private,count.index)}"
  
   tags {
     Name  = "Private"
   }
}

variable "cidr_dbprivate" {
  type = "map"
  description = "map database private subnet cidr_block per availability_zone"
  default = {
    "0" = "10.0.192.0/21"
    "1" = "10.0.200.0/21"
    "2" = "10.0.208.0/21"
  }
}

resource "aws_subnet" "devDBPrivateSubnet" {
  count             = "3"
  availability_zone = "${lookup(var.az,count.index)}"
  vpc_id            = "${aws_vpc.devVPC.id}"
  cidr_block        = "${lookup(var.cidr_dbprivate,count.index)}"
  
   tags {
     Name  = "DBPrivate"
   }
}
