output "my_vpc_id" {
  value = aws_vpc.new-vpc.id
}

output "my_subnet_ids" {
  value = aws_subnet.my_vpc_subnets[*].id
}
