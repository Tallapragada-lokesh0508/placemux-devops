resource "aws_db_instance" "postgres" {
  identifier        = "placemux-dev-db"
  engine            = "postgres"
  engine_version    = "15.4"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  username            = "admin"
  password            = "Password123!"
  publicly_accessible = false

  backup_retention_period = 7

  skip_final_snapshot = true
}