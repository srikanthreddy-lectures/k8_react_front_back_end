#!/bin/bash
sudo apt-get update && sudo apt-get install docker.io -y

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl


curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

sudo -i
curl -LO "https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz"
sudo mkdir -p "/opt/cni/bin"
sudo tar -xf "cni-plugins-linux-amd64-v1.3.0.tgz" -C "/opt/cni/bin"
rm "cni-plugins-linux-amd64-v1.3.0.tgz"

sudo sysctl fs.protected_regular=0

apt install conntrack

wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.26.0/crictl-v1.26.0-linux-amd64.tar.gz
sudo tar zxvf crictl-v1.26.0-linux-amd64.tar.gz -C /usr/local/bin

git clone https://github.com/Mirantis/cri-dockerd.git


wget https://storage.googleapis.com/golang/getgo/installer_linux
chmod +x ./installer_linux
./installer_linux
source ~/.bash_profile
cd cri-dockerd
mkdir bin
go build -o bin/cri-dockerd
mkdir -p /usr/local/bin
sudo install -o root -g root -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd
sudo cp -a packaging/systemd/* /etc/systemd/system
sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
sudo systemctl daemon-reload
sudo systemctl enable cri-docker.service
sudo systemctl enable --now cri-docker.socket
cd ..

minikube start --vm-driver=none
minikube status
