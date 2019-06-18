terraform {
  required_version = ">=0.11"
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3"{ 
      bucket         = "natali-terraform-state"
      key            = "metabase.terraform.tfstate"
      region         = "eu-west-1"
      encrypt        = true
    }
}

variable "aws_region" {}
variable "aws_vpc" {}

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.20"
}

data "aws_vpc" "metabase" {
  id = "${var.aws_vpc}"
}

data "aws_availability_zones" "available" {}

data "aws_subnet_ids" "public" {
  vpc_id = "${var.aws_vpc}"

  tags = {
    Environment = "Public"
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = "${var.aws_vpc}"

  tags = {
    Tier = "Private"
  }
}



#data "aws_ssm_parameter" "daltix_general_db_username" {
#  name = "daltix_general_db_username"
#}

#data "aws_ssm_parameter" "daltix_general_db_password" {
#  name = "daltix_general_db_password"
#}

resource "aws_security_group" "alb" {
  name        = "metabase-alb-sg-${terraform.workspace}"
  description = "Security group to allow access to metabase application load balancer"
  vpc_id      = "${data.aws_vpc.metabase.id}"
  

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "6"
    cidr_blocks = ["94.62.190.103/32"]
    description = "Lisbon Office"
    }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
  tags = {
    Name      = "metabase-alb-sg-${terraform.workspace}"
  }
}

resource "aws_security_group" "fargate" {
  name        = "metabase-fargate-sg-${terraform.workspace}"
  description = "Security group to allow access to metabase fargate container"
  vpc_id      = "${data.aws_vpc.metabase.id}"
  

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "6"
    security_groups = ["${aws_security_group.alb.id}"]
    description = "application load balancer"
    }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "metabase-fargate-sg-${terraform.workspace}"
  }
}

resource "aws_security_group" "postgres" {
  name        = "metabase-postgres-sg-${terraform.workspace}"
  description = "Security group to allow access to metabase RDS instance"
  vpc_id      = "${data.aws_vpc.metabase.id}"
  

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "6"
    cidr_blocks     = ["0.0.0.0/0"]
    description = "fargate container"
    }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
  tags = {
    Name      = "metabase-postgres-sg-${terraform.workspace}"
  }
}

resource "aws_db_subnet_group" "metabase-rds-subnet-group" {
  name       = "metabase-postgres-subnet-${terraform.workspace}"
  subnet_ids = ["${data.aws_subnet_ids.private.ids}", "${data.aws_subnet_ids.private.ids}" ]

  tags = {
    Name = "metabase-DB-subnetgroup"
  }
}

resource "aws_db_instance" "metabase-rds-postgres" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "11.2"
  instance_class         = "db.t3.medium"
  name                   = "metabase"
  username               = "metabase"
  password               = "metabase"
  parameter_group_name   = "default.postgres11"
  db_subnet_group_name   = "${aws_db_subnet_group.metabase-rds-subnet-group.id}"
  deletion_protection    = "false"
  maintenance_window     = "Mon:00:00-Mon:03:00"
  vpc_security_group_ids = ["${aws_security_group.postgres.id}"]
  backup_retention_period = "7"
  backup_window           = "04:00-05:00"
  final_snapshot_identifier = "finalsnaphsot"
  publicly_accessible     = "true"

  tags = {
    Name = "metabase-rds-postgres-${terraform.workspace}"
  }
}

resource "aws_lb" "metabase" {
  name               = "metabase-alb-${terraform.workspace}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.alb.id}"]
  subnets            = ["${data.aws_subnet_ids.public.ids}", "${data.aws_subnet_ids.public.ids}" ]
  ip_address_type    = "ipv4"

  tags = {
    Name = "metabase-alb-${terraform.workspace}"
  }
}

resource "aws_lb_target_group" "metabase-fargate-container" {
  name        = "metabase-tg-${terraform.workspace}"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${var.aws_vpc}"

  tags = {
    Name = "metabase-tg-${terraform.workspace}"
  }

}

resource "aws_lb_listener" "metabase-target-group" {
  load_balancer_arn = "${aws_lb.metabase.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.metabase-fargate-container.arn}"
  }
}