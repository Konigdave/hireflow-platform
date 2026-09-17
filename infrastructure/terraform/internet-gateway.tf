resource "aws_internet_gateway" "hireflow" {
  vpc_id = aws_vpc.hireflow.id

  tags = {
    Name = "hireflow-igw"
  }
}
