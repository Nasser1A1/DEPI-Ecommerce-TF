#!/bin/bash
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io
systemctl enable docker
systemctl start docker
sudo usermod -aG docker $USER
newgrp docker
curl https://get.k3s.io | K3S_TOKEN=DEV sh
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
kubectl create secret docker-registry ecr-secret \
  --docker-server=274363548467.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region us-east-1) \
  --docker-email=you@example.com \
  -n default
