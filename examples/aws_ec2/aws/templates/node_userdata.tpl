#!/bin/bash
# Install docker
curl https://releases.rancher.com/install-docker/17.03.sh | sh
sudo usermod -a -G docker ubuntu
