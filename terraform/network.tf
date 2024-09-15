
# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.default_tags, { "Name" = "Devops" })

}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = var.default_tags
}

# NAT Gateway EIP
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = var.default_tags
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnets[0].id
  tags          = var.default_tags
}

# Public Subnets
resource "aws_subnet" "public_subnets" {
  for_each = { for idx, cidr in var.public_subnets : idx => cidr }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = element(var.availability_zones, each.key)
  tags              = merge(var.default_tags, { "Name" = "${element(var.public_subnet_names, each.key)}" })
}

# Private Subnets
resource "aws_subnet" "private_subnets" {
  for_each = { for idx, cidr in var.private_subnets : idx => cidr }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = element(var.availability_zones, each.key)
  tags              = merge(var.default_tags, { "Name" = "${element(var.private_subnet_names, each.key)}" })
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.default_tags, { "Name" = "public-route-table" })
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(var.default_tags, { "Name" = "private-route-table" })
}

# Route Table Associations
resource "aws_route_table_association" "public_subnets" {
  for_each = aws_subnet.public_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_subnets" {
  for_each = aws_subnet.private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

