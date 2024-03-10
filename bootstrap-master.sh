#!/bin/bash

#=========================
#   Install k8s
#=========================
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/${KUBE_VERSION}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBE_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Node IP
echo "KUBELET_EXTRA_ARGS=\"--node-ip=${IP_ADDR}\"" > /etc/default/kubelet

# swap off
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# kubeadm init
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=${IP_ADDR} --cri-socket "unix:///var/run/cri-dockerd.sock"

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

DEFAULT_USER=vagrant
DEFAULT_USER_HOME=/home/$DEFAULT_USER
mkdir -p $DEFAULT_USER_HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $DEFAULT_USER_HOME/.kube/config
sudo chown -R $(id -u $DEFAULT_USER):$(id -g $DEFAULT_USER) $DEFAULT_USER_HOME/.kube

# install CNI
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

# join cmd
rm -f /vagrant/join-command && \
kubeadm token create --print-join-command > /vagrant/join-command && \
sed -i 's|$|  --cri-socket "unix:///var/run/cri-dockerd.sock"|' join-command