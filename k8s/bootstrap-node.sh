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

# Set CgroupDriver
cat <<EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
sudo systemctl restart docker

#=========================
#   Install k8s
#=========================
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet=${KUBE_VERSION} kubeadm=${KUBE_VERSION} 
sudo apt-mark hold kubelet kubeadm

# Set node ip
# sudo sed -i 's|KUBELET_KUBEADM_ARGS="|KUBELET_KUBEADM_ARGS="--node-ip='${IP_ADDR}' |' /var/lib/kubelet/kubeadm-flags.env
echo "KUBELET_EXTRA_ARGS=\"--node-ip=${IP_ADDR}\"" > /etc/default/kubelet

# Swap off
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Join
bash -c "$(cat /vagrant/join-command) -v=5" > /vagrant/logs