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


virt-install --name=worker01 \
--vcpus=2 \
--memory=2048 \
--cdrom=/home/mohsen/Downloads/ubuntu-20.04.4-live-server-amd64.iso \
--disk size=50 \
--os-variant=ubuntu20.04 \
--network bridge=br0


virt-install --name=worker02 \
--vcpus=2 \
--memory=2048 \
--cdrom=/home/mohsen/Downloads/ubuntu-20.04.4-live-server-amd64.iso \
--disk size=50 \
--os-variant=ubuntu20.04 \
--network bridge=br0


virt-install --name=worker03 \
--vcpus=2 \
--memory=2048 \
--cdrom=/home/mohsen/Downloads/ubuntu-20.04.4-live-server-amd64.iso \
--disk size=50 \
--os-variant=ubuntu20.04 \
--network bridge=br0
~~~


