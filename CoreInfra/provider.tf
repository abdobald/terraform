provider "aws" {
  access_key = "${var.ACCESS_KEY_08}"
  secret_key = "${var.SECRET_KEY_08}"
  region     = "eu-west-1"
}

resource "aws_vpc" "vpc-aba" {
  cidr_block = "${var.cidr_block}"
  tags {
    Name = "vpc-aba"
  }
}

resource "aws_subnet" "subnet-pub-eu-west-1a" {
  vpc_id                  = "${aws_vpc.vpc-aba.id}"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
  cidr_block              = "172.23.0.0/24"
  tags {
    Name = "subnet-aba-1a"
  }
}

resource "aws_subnet" "subnet-pub-eu-west-1b" {
  vpc_id                  = "${aws_vpc.vpc-aba.id}"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1b"
  cidr_block              = "172.23.1.0/24"
  tags {
    Name = "subnet-aba-1b"
  }
}

resource "aws_internet_gateway" "aba-igw" {
  vpc_id = "${aws_vpc.vpc-aba.id}"
}

resource "aws_security_group" "nat-aba" {
  name        = "vpc_nat"
  description = "Allow traffic from the public subnet to the internet"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.vpc-aba.cidr_block}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.vpc-aba.cidr_block}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.vpc-aba.id}"

  tags {
    Name = "aba-nat-sg"
  }
}

resource "aws_route_table" "route-aba" {
  vpc_id = "${aws_vpc.vpc-aba.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.aba-igw.id}"
  }
 tags{
   Name = "route-table-aba"
 }
}

resource "aws_route_table_association" "route-assoc-1a-aba" {
  subnet_id      = "${aws_subnet.subnet-pub-eu-west-1a.id}"
  route_table_id = "${aws_route_table.route-aba.id}"
}

resource "aws_route_table_association" "route-assoc-1b-aba" {
  subnet_id      = "${aws_subnet.subnet-pub-eu-west-1b.id}"
  route_table_id = "${aws_route_table.route-aba.id}"
}

