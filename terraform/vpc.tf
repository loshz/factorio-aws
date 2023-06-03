# Create a single VPC with DNS support.
resource "aws_vpc" "factorio" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "factorio" }
}

# Create a single public subnet.
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.factorio.id
  cidr_block              = var.vpc_cidr
  map_public_ip_on_launch = true

  tags = { Name = "public" }
}

# Create an IGW to enable internet-routable traffic.
resource "aws_internet_gateway" "factorio" {
  vpc_id = aws_vpc.factorio.id

  tags = { Name = "factorio" }
}

# Create a single public route table to direct network traffic.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.factorio.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.factorio.id
  }

  tags = { Name = "factorio" }
}

# Associate the route table with the public subnet.
resource "aws_route_table_association" "factorio_public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create a security group with public egress and a single
# UDP ingress rule for the required Factorio port.
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
    cidr_blocks = var.ingress_cidrs
  }

  tags = { Name = "factorio" }
}
