resource "aws_elasticache_subnet_group" "main" {
  name       = "placemux-cache-subnets"
  subnet_ids = [aws_subnet.private_app.id]
}

resource "aws_security_group" "redis_sg" {
  name   = "placemux-redis-sg"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }
  tags = { Name = "redis-sg" }
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "placemux-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [aws_security_group.redis_sg.id]
  tags                 = { Name = "placemux-redis" }
}