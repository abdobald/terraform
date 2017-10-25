terraform {
  backend "s3" {
    bucket = "lab08-rlt"
    key    = "app/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = "eu-west-1"
}

data "terraform_remote_state" "vpc_output" {
  backend = "s3"

  config {
    bucket = "lab08-rlt"
    key    = "vpc/terraform.tfstate"
    region = "eu-west-1"
  }
}

resource "aws_security_group" "nat-aba" {
  name        = "vpc_nat"
  description = "Allow traffic from the public subnet to the internet"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    #cidr_blocks = ["${data.terraform_remote_state.vpc_output.cidr_block}"]
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
 egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

  vpc_id = "${data.terraform_remote_state.vpc_output.vpc_aba}"
#  vpc_id = "${aws_vpc.vpc-aba.id}"

  tags {
    Name = "aba-nat-sg"
  }
}

resource "aws_route_table_association" "route-assoc-1b-aba" {
  subnet_id      = "${data.terraform_remote_state.vpc_output.subnet_pub_west_1b_aba}"
  #subnet_id      = "${aws_subnet.subnet-pub-eu-west-1b.id}"
  route_table_id = "${data.terraform_remote_state.vpc_output.route_table_aba}"
}

resource "aws_instance" "instance-aba" {
  ami			      = "${data.aws_ami.ubuntu.id}"
  availability_zone           = "eu-west-1a"
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.deployer.id}"
  user_data = "${data.template_file.data-aba.rendered} "
  security_groups             = ["${aws_security_group.nat-aba.id}"]
  subnet_id                   = "${data.terraform_remote_state.vpc_output.subnet_pub_west_1a_aba}"
  #subnet_id                  = "${aws_subnet.subnet-pub-eu-west-1a.id}"
  associate_public_ip_address = true
  source_dest_check           = false
  tags {
    Name = "instance-aba"
  }
  lifecycle {
    create_before_destroy = "true"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "aba-key"
  public_key = "${file(var.aba_key)}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "data-aba" {
  template = "${file("${path.module}/userdata.tpl")}"
  vars {
    username = "A. BALDE"
   }
}

resource "aws_elb" "elb_aba" {
  name            = "AbaWebsite"
  subnets         = ["${data.terraform_remote_state.vpc_output.subnets}"]
  security_groups = ["${aws_security_group.nat-aba.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 2
    target              = "HTTP:80/"
    interval            = 5
  }
}
