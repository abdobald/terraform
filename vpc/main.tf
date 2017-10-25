terraform {
  backend "s3" {
    bucket = "lab08-rlt"
    key    = "vpc/terraform.tfstate"
    region = "eu-west-1"
  }
}

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
  vpc_id            = "${aws_vpc.vpc-aba.id}"
  availability_zone = "eu-west-1a"
  cidr_block        = "172.23.0.0/24"
  tags {
    Name = "subnet-aba-1a"
  }
}

resource "aws_subnet" "subnet-pub-eu-west-1b" {
  vpc_id            = "${aws_vpc.vpc-aba.id}"
  availability_zone = "eu-west-1b"
  cidr_block        = "172.23.1.0/24"
  tags {
    Name = "subnet-aba-1b"
  }
}

resource "aws_internet_gateway" "aba-igw" {
  vpc_id = "${aws_vpc.vpc-aba.id}"
}

resource "aws_route_table" "route-aba" {
  vpc_id = "${aws_vpc.vpc-aba.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.aba-igw.id}"
  }

  tags {
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
