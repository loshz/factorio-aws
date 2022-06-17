resource "aws_vpc" "factorio" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    { Name = "factorio" },
    local.tags,
  )
}

resource "aws_subnet" "factorio_public" {
  vpc_id                  = aws_vpc.factorio.id
  cidr_block              = var.vpc_cidr
  map_public_ip_on_launch = true

  tags = merge(
    { Name = "factorio-public" },
    local.tags,
  )
}

resource "aws_internet_gateway" "factorio" {
  vpc_id = aws_vpc.factorio.id

  tags = merge(
    { Name = "factorio" },
    local.tags,
  )
}

resource "aws_route_table" "factorio_public" {
  vpc_id = aws_vpc.factorio.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.factorio.id
  }

  tags = merge(
    { Name = "factorio-public" },
    local.tags,
  )
}

resource "aws_route_table_association" "factorio_public" {
  subnet_id      = aws_subnet.factorio_public.id
  route_table_id = aws_route_table.factorio_public.id
}

resource "aws_security_group" "factorio" {
  vpc_id = aws_vpc.factorio.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 34197
    to_port     = 34197
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    { Name = "factorio" },
    local.tags,
  )
}
