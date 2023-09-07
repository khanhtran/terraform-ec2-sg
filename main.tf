# Get the list of official Canonical Ubuntu 16.04 AMIs
data "aws_ami" "ubuntu-20" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "startup" {
  template = "${file("${path.module}/templates/startup.sh.tpl")}"
}

resource "aws_key_pair" "mykey" {
  key_name   = "${var.namespace}-key"
  public_key = "${file("${var.public_key_path}")}"
}

resource "aws_security_group" "sg-1" {
  name_prefix = "group1"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_instance" "host-1" {
  ami           = "${data.aws_ami.ubuntu-20.id}"
  instance_type = var.instance_type
  key_name      = "${aws_key_pair.mykey.id}"

  subnet_id              = var.subnet_ids[0]
  vpc_security_group_ids = ["${aws_security_group.sg-1.id}"]
  user_data              = "${data.template_file.startup.rendered}"  
}

resource "aws_security_group" "sg-2" {
  name_prefix = "group2"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_instance" "host-2" {
  vpc_security_group_ids = ["${aws_security_group.sg-2.id}"]
  ami           = "${data.aws_ami.ubuntu-20.id}"
  instance_type = var.instance_type
  key_name      = "${aws_key_pair.mykey.id}"
  subnet_id              = var.subnet_ids[0]
  user_data              = "${data.template_file.startup.rendered}"
}

# allow 1 to 1 send ping package to 2
resource "aws_vpc_security_group_egress_rule" "sg1-egress" {
  security_group_id = aws_security_group.sg-1.id
  ip_protocol = "icmp"
  from_port   = 0
  to_port     = 0
  referenced_security_group_id = aws_security_group.sg-2.id
}

resource "aws_vpc_security_group_ingress_rule" "sg2-ingress" {
  security_group_id = aws_security_group.sg-2.id
  ip_protocol = "icmp"
  from_port   = 0
  to_port     = 0
  referenced_security_group_id = aws_security_group.sg-1.id  
}

# # allow ssh
resource "aws_vpc_security_group_ingress_rule" "sg1-ssh" {
  security_group_id = aws_security_group.sg-1.id
  from_port   = 22
  to_port     = 22  
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "sg2-ssh" {
  security_group_id = aws_security_group.sg-2.id
  from_port   = 22
  to_port     = 22  
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "tcp"
}







