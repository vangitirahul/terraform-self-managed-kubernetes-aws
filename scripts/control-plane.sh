# Initialize Kubernetes control plane
kubeadm init \
  --apiserver-advertise-address=10.0.1.10 \
  --pod-network-cidr=192.168.0.0/16 \
  --service-cidr=10.96.0.0/12 \
  --cri-socket=unix:///run/containerd/containerd.sock

# Configure kubectl for ec2-user
mkdir -p /home/ec2-user/.kube

cp /etc/kubernetes/admin.conf \
  /home/ec2-user/.kube/config

chown -R ec2-user:ec2-user /home/ec2-user/.kube

chmod 600 /home/ec2-user/.kube/config

# Configure kubectl for root
export KUBECONFIG=/etc/kubernetes/admin.conf

# Install Calico
kubectl apply -f \
  https://raw.githubusercontent.com/projectcalico/calico/v3.31.7/manifests/calico.yaml

echo "Control plane initialization completed"
