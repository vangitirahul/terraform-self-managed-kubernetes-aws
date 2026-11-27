#!/bin/bash
set -euo pipefail

# Install dependencies
dnf install -y containerd iproute-tc conntrack-tools \
  socat iptables ethtool

# Disable swap
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

# Configure kernel modules
cat <<EOF > /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Configure networking
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system

# Configure containerd
mkdir -p /etc/containerd

containerd config default > /etc/containerd/config.toml

sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' \
  /etc/containerd/config.toml

systemctl enable --now containerd
systemctl restart containerd

# Configure Kubernetes repository
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.34/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.34/rpm/repodata/repomd.xml.key
EOF

# Install Kubernetes packages
dnf install -y kubelet kubeadm kubectl

systemctl enable --now kubelet
