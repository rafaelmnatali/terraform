provider "postgresql" {
  host            = "${aws_db_instance.metabase-rds-postgres.address}"
  port            = 5432
  database        = "${aws_db_instance.metabase-rds-postgres.name}"
  username        = "${aws_db_instance.metabase-rds-postgres.username}"
  password        = "${aws_db_instance.metabase-rds-postgres.password}"
  sslmode         = "require"
  connect_timeout = 15
}

resource "postgresql_database" "my_db" {
  name              = "my_db"
}

variable "customer" {}

resource "postgresql_database" "my_natali" {
  name              = "my_db_${var.customer}"
}