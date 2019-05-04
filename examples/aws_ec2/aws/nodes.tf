locals {
  cluster_id_tag = {
    "kubernetes.io/cluster/${var.cluster_id}" = "owned"
  }
}

data "aws_availability_zones" "az" {}

resource "aws_default_subnet" "default" {
  availability_zone = "ap-south-1a"
  tags              = "${local.cluster_id_tag}"

  # count             = "length(${data.aws_availability_zones.az.names})"
}

resource "aws_security_group" "allow-all" {
  name        = "rke-default-security-group"
  description = "rke"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${local.cluster_id_tag}"
}

resource "aws_instance" "rke-node" {
  count = 4

  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${aws_key_pair.rke-node-key.key_name}"
  iam_instance_profile   = "${aws_iam_instance_profile.rke-aws.name}"
  vpc_security_group_ids = ["${aws_security_group.allow-all.id}"]
  tags                   = "${local.cluster_id_tag}"

  provisioner "remote-exec" {
    connection {
      host        = "coalesce(${self.public_ip}, ${self.private_ip})"
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${tls_private_key.node-key.private_key_pem}"
    }

    inline = [
      "curl releases.rancher.com/install-docker/1.12.sh | bash",
      "sudo usermod -a -G docker ubuntu",
    ]
  }
}
