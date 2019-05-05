resource "tls_private_key" "node-key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "rke-node-key" {
  key_name   = "rke-node-key"
  public_key = "${tls_private_key.node-key.public_key_openssh}"
}

resource "local_file" "private_key" {
  content  = "${tls_private_key.node-key.private_key_pem}"
  filename = "${path.module}/rke-node-key_1.pem"
}
