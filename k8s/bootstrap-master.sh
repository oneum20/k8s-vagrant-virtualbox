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

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

#=========================
#   Install k8s
#=========================
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet=${KUBE_VERSION} kubeadm=${KUBE_VERSION} kubectl=${KUBE_VERSION}
sudo apt-mark hold kubelet kubeadm kubectl

# Swap off
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

export KUBE_VERSION=$(kubelet --version | awk '{print $2}')
cat /vagrant/kubeadm-config.yaml | sed -e 's/$KUBE_VERSION/'${KUBE_VERSION}'/g; s/$IP_ADDR/'${IP_ADDR}'/g' > ~/kubeadm-config.yaml

# init
sudo kubeadm init --config ~/kubeadm-config.yaml

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

export KUBECONFIG=/etc/kubernetes/admin.conf

# Install CNI
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# join cmd
kubeadm token create --print-join-command > /vagrant/join-command