resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "hireflow-nat-eip"
  }
}

resource "aws_nat_gateway" "hireflow" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name = "hireflow-nat"
  }

  depends_on = [aws_internet_gateway.hireflow]
}
