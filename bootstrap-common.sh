#!/bin/bash

#=========================
#   Install Docker
#=========================
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# TODO: Docker Version
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Set Cgroup Driver
cat <<EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
sudo systemctl restart docker

# Install cri-dockerd
curl -OL https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.11/cri-dockerd_0.3.11.3-0.ubuntu-focal_amd64.deb
sudo dpkg -i cri-dockerd_0.3.11.3-0.ubuntu-focal_amd64.deb
sudo systemctl enable cri-docker.service
sudo systemctl enable --now cri-docker.socket