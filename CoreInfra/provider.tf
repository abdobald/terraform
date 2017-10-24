provider "aws" {
  access_key = "${var.ACCESS_KEY_08}"
  secret_key = "${var.SECRET_KEY_08}"
  region     = "eu-west-1"
}

resource "aws_vpc" "teraform-aba" {
  cidr_block = "172.23.0.0/16"

  tags {
    name = "aba"
  }
}

resource "aws_subnet" "subnet-pub-eu-west-1a" {
  vpc_id            = "${aws_vpc.teraform-aba.id}"
  availability_zone = "eu-west-1a"
  cidr_block        = "172.23.0.0/24"

  tags {
    name = "aba"
  }
}

resource "aws_subnet" "subnet-pub-eu-west-1b" {
  vpc_id            = "${aws_vpc.teraform-aba.id}"
  availability_zone = "eu-west-1b"
  cidr_block        = "172.23.1.0/24"

  tags {
    name = "aba"
  }
}
