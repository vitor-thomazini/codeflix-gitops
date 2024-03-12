data "aws_availability_zones" "available" {}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.prefix}-vpc"
  }
}

resource "aws_subnet" "my_vpc_subnets" {
  count = 2
  availability_zone = data.aws_availability_zones.available.names[count.index]

  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.prefix}-igw"
  }
}

resource "aws_route_table" "my_rtb" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "${var.prefix}-rtb"
  }
}

resource "aws_route_table_association" "my_rtb_association" {
  count = 2
  route_table_id = aws_route_table.my_rtb.id
  subnet_id = aws_subnet.my_vpc_subnets.*.id[count.index]
}
