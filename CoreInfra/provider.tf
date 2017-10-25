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
    cidr_blocks = ["${aws_vpc.vpc-aba.cidr_block}"]
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

resource "aws_instance" "instance-aba" {
  ami			      = "${data.aws_ami.ubuntu.id}"
  availability_zone           = "eu-west-1a"
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.deployer.id}"
  user_data = "${data.template_file.data-aba.rendered} "
  vpc_security_group_ids      = ["${aws_security_group.nat-aba.id}"]
  subnet_id                   = "${aws_subnet.subnet-pub-eu-west-1a.id}"
  associate_public_ip_address = true
  source_dest_check           = false

  tags {
    Name = "instance-aba"
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

output "public_ip" {  
  value = "${aws_instance.instance-aba.public_ip}"
}

data "template_file" "data-aba" {
  template = "${file("${path.module}/userdata.tpl")}"
  vars {
    username = "A. BALDE"
   }
}
