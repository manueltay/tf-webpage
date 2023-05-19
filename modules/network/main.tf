locals {
  mytags = {
    Env   = var.environment == "qa" ? "ESQA" : var.environment
    Owner = "mtay"
    New   = "tag"
  }
  test = "value"
}

data "aws_availability_zones" "available" {
  state = "available"
}

#VPC
resource "aws_vpc" "example" {
  cidr_block = var.vpc_cidr
  tags       = merge(local.mytags, { custom = "tag" })
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.example.id

  tags = local.mytags
}


### Public Subnets
resource "aws_subnet" "public" {
  count      = length(data.aws_availability_zones.available.zone_ids)
  vpc_id     = aws_vpc.example.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)

  tags = merge(local.mytags, { Name = "Public Subnet ${count.index}" })
}

resource "aws_subnet" "private" {
  count      = var.if_private_subnets ? length(data.aws_availability_zones.available.zone_ids) : 0
  vpc_id     = aws_vpc.example.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + length(aws_subnet.public))

  tags = merge(local.mytags, { Name = "Private Subnet ${count.index}" })
}

## Nat

resource "aws_eip" "nat" {
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(local.mytags, { Name = "NAT GW" })

  depends_on = [aws_internet_gateway.gw]
}

## Route Table
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = local.mytags
}

resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = local.mytags
}

resource "aws_route_table_association" "public" {
  count          = length(data.aws_availability_zones.available.zone_ids)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "private" {
  count          = length(data.aws_availability_zones.available.zone_ids)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.rt_private.id
}
