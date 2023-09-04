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

resource "aws_security_group" "default" {
  name_prefix = "${var.namespace}"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ssh_host" {
  ami           = "${data.aws_ami.ubuntu-20.id}"
  instance_type = var.instance_type
  key_name      = "${aws_key_pair.mykey.id}"

  subnet_id              = var.subnet_ids[0]
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  user_data              = "${data.template_file.startup.rendered}"

}
