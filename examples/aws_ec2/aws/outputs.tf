output "private_key" {
  value = "${file("${path.module}/rke_node_key.pem")}"
}

output "ssh_username" {
  value = "ubuntu"
}

output "addresses" {
  value = ["${aws_instance.rke-node.*.public_dns}"]
}
