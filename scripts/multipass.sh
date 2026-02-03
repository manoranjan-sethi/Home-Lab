# 1. Check if your CPU supports Virtualization
egrep -c '(vmx|svm)' /proc/cpuinfo
# (If the number is 1 or higher, you are good to go)

# 2. Install Multipass
sudo snap install multipass

# 3. Create your 3-node "Virtual Infrastructure"
multipass launch --name k8s-master --cpus 2 --mem 4G --disk 20G
multipass launch --name k8s-worker-1 --cpus 1 --mem 4G --disk 20G
multipass launch --name k8s-worker-2 --cpus 1 --mem 4G --disk 20G

# 4. Verify the created instances
multipass list

# 5. Access the master node
multipass shell k8s-master

# 6. Prepare the nodes to install Containerd and Kubernetes

# 7. Update and install basic dependencies
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# 8. Disable Swap (K8s requirement)
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# 9. Load Kernel Modules for Networking
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

# 10. Set Sysctl params
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

# 11. Install containerd
sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd

# 12. Install Kubernetes Tools
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
