provider "aws" {
  access_key = "${var.ACCESS_KEY_08}"
  secret_key = "${var.SECRET_KEY_08}"
  region     = "eu-west-1"
}

resource "aws_vpc" "teraform-aba" {
  cidr_block = "172.23.0.0/16"
}
