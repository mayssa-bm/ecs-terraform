# network.tf

resource "aws_vpc" "first-vpc" {
  cidr_block = "172.10.0.0/16"
}

# availability zones in current region 
data "aws_availability_zones" "available" {
}


# Create  private subnets  in different AZ
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.first-vpc.id
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.first-vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
}

# Create  public subnets in different AZ
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.first-vpc.id
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.first-vpc.cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
}

# Internet Gateway for  public subnet
resource "aws_internet_gateway" "test-igw" {
  vpc_id = aws_vpc.first-vpc.id
}

# Route  public subnet traffic through IGW
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.first-vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.test-igw.id
}

# Create a NAT GW with an Elastic IP for  private subnets to get internet connectivity
resource "aws_eip" "test-eip" {
  count      = var.az_count
  vpc        = true
  depends_on = [aws_internet_gateway.test-igw]
}

resource "aws_nat_gateway" "test-natgw" {
  count         = var.az_count
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.test-eip.*.id, count.index)
}

# Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.first-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.test-natgw.*.id, count.index)
  }
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}