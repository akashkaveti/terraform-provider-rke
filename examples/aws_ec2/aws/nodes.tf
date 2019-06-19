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
    from_port   = 2376
    to_port     = 2376
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10254
    to_port     = 10254
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2379
    to_port     = 2379
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2380
    to_port     = 2380
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8472
    to_port     = 8472
    protocol    = "UDP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9099
    to_port     = 9099
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "TCP"
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

data "template_file" "node_userdata" {
  template = "${file("${path.module}/templates/node_userdata.tpl")}"
}

resource "aws_instance" "rke-node" {
  count = 4

  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.key_name}"
  iam_instance_profile   = "${aws_iam_instance_profile.rke-aws.name}"
  vpc_security_group_ids = ["${aws_security_group.allow-all.id}"]
  tags                   = "${local.cluster_id_tag}"

  # user_data              = "${data.template_file.node_userdata.rendered}"

  provisioner "remote-exec" {
    connection {
      host        = "${coalesce(self.public_ip, self.private_ip)}"
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("${path.module}/rke_node_key.pem")}"
    }

    inline = [
      "sudo apt-get update",
      "curl https://releases.rancher.com/install-docker/18.06.sh | sh",
      "sudo usermod -a -G docker ubuntu",
    ]

    # https://github.com/hashicorp/terraform/issues/1025#issuecomment-84139959
  }
}
