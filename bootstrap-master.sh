#=========================
#   Install k8s
#=========================
# sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/kubernetes-archive-keyring.gpg add -
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet=${KUBE_VERSION} kubeadm=${KUBE_VERSION} kubectl=${KUBE_VERSION}
sudo apt-mark hold kubelet kubeadm kubectl

# Node IP
echo "KUBELET_EXTRA_ARGS=\"--node-ip=${IP_ADDR}\"" > /etc/default/kubelet

# swap off
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# kubeadm init
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=${IP_ADDR}

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
kubeadm token create --print-join-command > /vagrant/join-command