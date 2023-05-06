# OpenShift en CentOS
Para el ejemplo usaremos [origin](https://github.com/openshift/origin) v3.11.0 que es la implementación de código abierto de Red Hat conocido así hasta agosto de 2018. Mencionar que el nombre del proyecto ha cambiado a [okd](https://github.com/okd-project/okd) el cual es ahora un upstream.

Enlace para descargar CentOS 7 [aquí](https://archive.org/download/cent-os-7-dvd-x8664/CentOS-7-x86_64-DVD-2009.iso).



### VirtualBox
![Virtual machines](https://user-images.githubusercontent.com/74718043/236634207-5de3d406-1455-42d8-b53c-3e2cbbdc515d.png)

### Máquinas virtuales

```
-------------------+-------------------     -------------------+-------------------
enp0s3             |      192.168.0.101     enp0s3             |      192.168.0.102
+------------------+------------------+     +------------------+------------------+
|         [master.example.lan]        |     |         [master.example.lan]        |
|        Master Virtual Machine       |     |        Worker Virtual Machine       |
+-------------------------------------+     +-------------------------------------+
```

### Inicio rápido

Paso 1: Master.

```bash
hostnamectl set-hostname "master"
hostnamectl set-hostname "master.example.lan" --static
sed -i "s|192.168.0.100|192.168.0.101|g" /etc/sysconfig/network-scripts/ifcfg-enp0s3
systemctl restart network.service
cat << EOF > /etc/hosts
127.0.0.1   localhost 
::1         localhost
192.168.0.101   master.example.lan   master
192.168.0.102   worker.example.lan   worker
EOF
yum update -y
yum install -y  wget git zile nano net-tools docker-1.13.1 bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct openssl-devel httpd-tools NetworkManager python-cryptography python2-pip python-devel  python-passlib java-1.8.0-openjdk-headless "@Development Tools"
yum -y install epel-release
sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo
systemctl | grep "NetworkManager.*running" 
if [ $? -eq 1 ]; then systemctl start NetworkManager systemctl enable NetworkManager; fi
yum -y --enablerepo=epel install pyOpenSSL
yum -y --enablerepo=epel install https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.6.5-1.el7.ans.noarch.rpm
```
