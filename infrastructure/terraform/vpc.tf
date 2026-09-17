resource "aws_vpc" "hireflow" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "hireflow-vpc"
  }
}
