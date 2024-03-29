# Getting Started with Kubernetes
My personal introduction to kubernetes

## Nodes 

| Hostname | IP address |
| --- | --- |
| manager1 | 172.16.0.10 |
| worker01 | 172.16.0.11 |
| worker02 | 172.16.0.12 |
| worker03 | 172.16.0.13 |



## Deploy VMs 

### Network

- `/etc/network/interfaces` :
~~~
auto br0
iface br0 inet static
      address 172.16.0.1
      netmask 255.255.255.0
      network 172.16.0.0
      broadcast 172.16.0.255
      bridge_ports lo
      bridge_stp off
      bridge_maxwait 0
~~~

- SNAT:
~~~
iptables -t nat -A POSTROUTING --dst 172.16.0.0/24   -j ACCEPT
iptables -t nat -A POSTROUTING --src 172.16.0.0/24 -j MASQUERADE
iptables-save > /etc/iptables/rules.v4
systemctl enable netfilter-persistent.service
~~~

### KVM 

~~~
virt-install --name=manager1 \
--vcpus=2 \
--memory=4096 \
--cdrom=/home/mohsen/Downloads/ubuntu-20.04.4-live-server-amd64.iso \
--disk size=50 \
--os-variant=ubuntu20.04 \
--network bridge=br0
~~~

~~~
virt-install --name=worker01 \
--vcpus=2 \
--memory=2048 \
--cdrom=/home/mohsen/Downloads/ubuntu-20.04.4-live-server-amd64.iso \
--disk size=50 \
--os-variant=ubuntu20.04 \
--network bridge=br0
~~~

~~~
virt-install --name=worker02 \
--vcpus=2 \
--memory=2048 \
--cdrom=/home/mohsen/Downloads/ubuntu-20.04.4-live-server-amd64.iso \
--disk size=50 \
--os-variant=ubuntu20.04 \
--network bridge=br0
~~~

~~~
virt-install --name=worker03 \
--vcpus=2 \
--memory=2048 \
--cdrom=/home/mohsen/Downloads/ubuntu-20.04.4-live-server-amd64.iso \
--disk size=50 \
--os-variant=ubuntu20.04 \
--network bridge=br0
~~~

## Ansible
### inventory
~~~
[masters]
manager1 ansible_host=manager1.localkube

[workers]
worker01 ansible_host=worker01.localkube
worker02 ansible_host=worker02.localkube
worker03 ansible_host=worker03.localkube


[all:vars]
K8S_VERSION_APT = 1.25.9-1.1
K8S_VERSION_APT_repo = v1.25
host_key_checking = false
ansible_user=
ansible_ssh_port=22
# ansible_ssh_pass=
ansible_become=yes
ansible_ssh_private_key_file=
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
CONFIG_DIR_TASKS=../../configs/
CONFIG_DIR_PLAYS=../configs/
TASKS_DIR_PLAYS=./tasks/
master_endpoint=192.168.20.17:6443
# token=
# discovery_token_ca_cert_hash=
~~~

run these:
~~~
apt list -a kubeadm
cd ./ansible/plays/
ansible-playbook -i ../inventory install_containerd.yml
ansible-playbook -i ../inventory configure_containerd.yml
ansible-playbook -i ../inventory disable_swap.yml
~~~
check macs and product_uuids: (OPTIONAL only if you are using virtual machines)
~~~
cd ../../scripts/
./check_macs.sh   
./check_product_uuids.sh
~~~
run these: 
~~~
cd ../ansible/plays/
# ansible-playbook -i ../inventory set_shecan.yml # if needed
ansible-playbook -i ../inventory add_kube_apt.yml
ansible-playbook -i ../inventory install_kubectl.yml
ansible-playbook -i ../inventory install_kubelet.yml
ansible-playbook -i ../inventory install_kubeadm.yml
# ansible-playbook -i ../inventory config_file_kubeadm.yml # optional if you have a kubeadm config
ansible-playbook -i ../inventory enable_routing.yml
ansible-playbook -i ../inventory config_file_sysctl_kubernetes_cni.yml
~~~

### initiate the control plane node

I'd rather to do this one manually to see the logs for now. doing these will initiate the control plane node on `172.16.0.10`.
~~~
ssh mohsen@172.16.0.10 -i /home/mohsen/.ssh/github-mohsen-local-laptop -t sudo -i
kubeadm init  --apiserver-advertise-address=172.16.0.10  --pod-network-cidr=10.10.0.0/16 --kubernetes-version=1.25.9
# or # kubeadm init --config /etc/kubernetes/kubeadm-config.yaml
echo "KUBECONFIG=/etc/kubernetes/admin.conf" >> /etc/bash.bashrc
echo "cp /etc/kubernetes/admin.conf /root/.kube/config" >> /etc/bash.bashrc
~~~
you'll be prompted with the command to initiate the workers. **save** the `master_endpoint`, `token` and `discovery_token_ca_cert_hash` variables in the inventory file.

print join command:
~~~
kubeadm token create --print-join-command
~~~

before initiating the workers you need to deploy a pod network to the cluster:
### install flannel/calico network pod plugin
~~~
ansible-playbook -i ../inventory install_flannel.yml
~~~
or read the file `ansible/plays/install_calico.yml` to get an understanding of how to install calico.
> customize the calico config before `kubectl create -f ` on it.

### initiate workers
run:
~~~
ansible-playbook -i ../inventory initialize_the_workers.yml
~~~
