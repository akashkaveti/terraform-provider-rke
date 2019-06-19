variable "region" {
  default = "ap-south-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {}

variable "cluster_id" {
  default = "rke"
}

variable "ssh_key_path" {
  default = "${file(/Users/akaveti/rke-node-key)}"
}
