# resource "tls_private_key" "node-key" {
#   algorithm = "RSA"
# }
# resource "local_file" "pub_key" {
#   content  = "${tls_private_key.node-key.public_key_openssh}"
#   filename = "${path.module}/rke-node-key_1_pub"
# }
# resource "aws_key_pair" "rke-node-key" {
#   key_name   = "rke-node-key"
#   public_key = "${file("${path.module}/rke_node_key.pem.pub")}"
# }
# resource "local_file" "private_key" {
#   content  = "${tls_private_key.node-key.private_key_pem}"
#   filename = "${path.module}/rke-node-key_1.pem"
# }

