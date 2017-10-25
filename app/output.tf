output "public_ip" {
  value = "${aws_instance.instance-aba.public_ip}"
}
output "Public_DNS" {
  value = "${aws_elb.elb_aba.dns_name}"
}
