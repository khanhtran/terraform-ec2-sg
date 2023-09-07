output "host-1" {
  value = "${aws_instance.host-1.public_ip}"
}

output "host-2" {
  value = "${aws_instance.host-2.public_ip}"
}
