resource "aws_security_group" "alb" {
  name        = "hireflow-alb-sg"
  description = "Security group for the HireFlow load balancer"
  vpc_id      = aws_vpc.hireflow.id

  tags = {
    Name = "hireflow-alb-sg"
  }
}

resource "aws_security_group" "app" {
  name        = "hireflow-app-sg"
  description = "Security group for HireFlow application workloads"
  vpc_id      = aws_vpc.hireflow.id

  tags = {
    Name = "hireflow-app-sg"
  }
}

resource "aws_security_group" "data" {
  name        = "hireflow-data-sg"
  description = "Security group for HireFlow PostgreSQL and Redis"
  vpc_id      = aws_vpc.hireflow.id

  tags = {
    Name = "hireflow-data-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.alb.id

  from_port   = 8000
  to_port     = 8000
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_app" {
  security_group_id            = aws_security_group.data.id
  referenced_security_group_id = aws_security_group.app.id

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "redis_from_app" {
  security_group_id            = aws_security_group.data.id
  referenced_security_group_id = aws_security_group.app.id

  from_port   = 6379
  to_port     = 6379
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_all" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_egress_rule" "app_all" {
  security_group_id = aws_security_group.app.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_egress_rule" "data_all" {
  security_group_id = aws_security_group.data.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}
