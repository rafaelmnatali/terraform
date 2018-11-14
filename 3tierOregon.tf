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

data "aws_availability_zones" "us-west-2" {}

resource "aws_subnet" "devPublicSubnet2a" {
  availability_zone = "${data.aws_availability_zones.us-west-2.names[0]}"
  vpc_id            = "${aws_vpc.devVPC.id}"
  cidr_block        = "10.0.128.0/20"
  
   tags {
     Name  = "Public"
   }
}

resource "aws_subnet" "devPublicSubnet2b" {
  availability_zone = "${data.aws_availability_zones.us-west-2.names[1]}"
  vpc_id            = "${aws_vpc.devVPC.id}"
  cidr_block        = "10.0.144.0/20"
  
   tags {
     Name  = "Public"
   }
}

resource "aws_subnet" "devPublicSubnet2c" {
  availability_zone = "${data.aws_availability_zones.us-west-2.names[2]}"
  vpc_id            = "${aws_vpc.devVPC.id}"
  cidr_block        = "10.0.160.0/20"
  
   tags {
     Name  = "Public"
   }
}

resource "aws_route_table_association" "rt_public_association" {
  subnet_id       =   "${aws_subnet.devPublicSubnet2a.id}"
  route_table_id  =   "${aws_route_table.PublicRoute.id}"
}

resource "aws_route_table_association" "rt_public_association_2b" {
  subnet_id       =   "${aws_subnet.devPublicSubnet2b.id}"
  route_table_id  =   "${aws_route_table.PublicRoute.id}"
}

resource "aws_route_table_association" "rt_public_association_2c" {
  subnet_id       =   "${aws_subnet.devPublicSubnet2c.id}"
  route_table_id  =   "${aws_route_table.PublicRoute.id}"
}

resource "aws_subnet" "devPrivateSubnet2a" {
  availability_zone = "${data.aws_availability_zones.us-west-2.names[0]}"
  vpc_id            = "${aws_vpc.devVPC.id}"
  cidr_block        = "10.0.0.0/19"
  
   tags {
     Name  = "Private"
   }
}

resource "aws_subnet" "devPrivateSubnet2b" {
  availability_zone = "${data.aws_availability_zones.us-west-2.names[1]}"
  vpc_id            = "${aws_vpc.devVPC.id}"
  cidr_block        = "10.0.32.0/19"
  
   tags {
     Name  = "Private"
   }
}

resource "aws_subnet" "devPrivateSubnet2c" {
  availability_zone = "${data.aws_availability_zones.us-west-2.names[2]}"
  vpc_id            = "${aws_vpc.devVPC.id}"
  cidr_block        = "10.0.64.0/19"
  
   tags {
     Name  = "Private"
   }
}

resource "aws_subnet" "devDBPrivateSubnet2a" {
  availability_zone = "${data.aws_availability_zones.us-west-2.names[0]}"
  vpc_id            = "${aws_vpc.devVPC.id}"
  cidr_block        = "10.0.192.0/21"
  
   tags {
     Name  = "DBPrivate"
   }
}

resource "aws_subnet" "devDBPrivateSubnet2b" {
  availability_zone = "${data.aws_availability_zones.us-west-2.names[1]}"
  vpc_id            = "${aws_vpc.devVPC.id}"
  cidr_block        = "10.0.200.0/21"
  
   tags {
     Name  = "DBPrivate"
   }
}

resource "aws_subnet" "DBPrivateSubnet2c" {
  availability_zone = "${data.aws_availability_zones.us-west-2.names[2]}"
  vpc_id            = "${aws_vpc.devVPC.id}"
  cidr_block        = "10.0.208.0/21"
  
   tags {
     Name  = "DBPrivate"
   }
}
