output "vpc_aba" {
  value = "${aws_vpc.vpc-aba.id}"
}
output "subnet_pub_west_1a_aba"{
  value = "${aws_subnet.subnet-pub-eu-west-1a.id}"
}
output "subnet_pub_west_1b_aba"{
  value = "${aws_subnet.subnet-pub-eu-west-1b.id}"
}
output "route_table_aba"{
  value = "${aws_route_table.route-aba.id}"
}
output "cidr_block"{
  value = "${var.cidr_block}"
}
output "subnets"{
  value = ["${aws_subnet.subnet-pub-eu-west-1a.id}","${aws_subnet.subnet-pub-eu-west-1b.id}"]
}
