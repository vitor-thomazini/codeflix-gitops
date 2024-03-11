data "aws_availability_zones" "available" {}

resource "aws_vpc" "codeflix_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.prefix}-vpc"
  }
}

resource "aws_subnet" "codeflix_vpc_subnets" {
  count = 2
  availability_zone = data.aws_availability_zones.available.names[count.index]

  vpc_id = aws_vpc.codeflix_vpc.id
  cidr_block = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-subnet-${count.index}"
  }
}

# resource "aws_subnet" "codeflix_vpc_subnet_1" {
#   vpc_id = aws_vpc.codeflix_vpc.id
#   cidr_block = "10.0.0.0/24"
#   availability_zone = "us_east_1a"

#   tags = {
#     Name = "${var.prefix}-subnet-1"
#   }
# }

# resource "aws_subnet" "codeflix_vpc_subnet_2" {
#   vpc_id = aws_vpc.codeflix_vpc.id
#   cidr_block = "10.0.0.0/24"
#   availability_zone = "us_east_1b"

#   tags = {
#     Name = "${var.prefix}-subnet-2"
#   }
# }

resource "aws_internet_gateway" "codeflix_igw" {
  vpc_id = aws_vpc.codeflix_vpc.id

  tags = {
    Name = "${var.prefix}-igw"
  }
}

resource "aws_route_table" "codeflix_rtb" {
  vpc_id = aws_vpc.codeflix_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.codeflix_igw.id
  }

  tags = {
    Name = "${var.prefix}-rtb"
  }
}

resource "aws_route_table_association" "codeflix_rtb_association" {
  count = 2
  route_table_id = aws_route_table.codeflix_rtb.id
  subnet_id = aws_subnet.codeflix_vpc_subnets.*.id[count.index]
}


# resource "aws_route_table_association" "codeflix_rtb_association_1" {
#   count = 2
#   route_table_id = aws_route_table.codeflix_rtb.id
#   subnet_id = aws_subnet.codeflix_vpc_subnet_1.id
# }

# resource "aws_route_table_association" "codeflix_rtb_association_2" {
#   count = 2
#   route_table_id = aws_route_table.codeflix_rtb.id
#   subnet_id = aws_subnet.codeflix_vpc_subnet_2.id
# }


