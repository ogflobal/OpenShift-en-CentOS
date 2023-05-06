# OpenShift en CentOS
Para el ejemplo usaré [origin](https://github.com/openshift/origin) v3.11.0 que es la implementación de código abierto de Red Hat conocido así hasta agosto de 2018. Mencionar que el nombre del proyecto ha cambiado a [okd](https://github.com/okd-project/okd) el cual es ahora un upstream.

Enlace para descargar CentOS 7 [aquí](https://archive.org/download/cent-os-7-dvd-x8664/CentOS-7-x86_64-DVD-2009.iso).



### VirtualBox

```
-------------------+-------------------     -------------------+-------------------
enp0s3             |      192.168.0.101     enp0s3             |      192.168.0.102
+------------------+------------------+     +------------------+------------------+
|         [master.example.lan]        |     |         [worker.example.lan]        |
|        Master Virtual Machine       |     |        Worker Virtual Machine       |
|    Conectado a: Adaptador puente    |     |    Conectado a: Adaptador puente    |
|RAM 8192 MB · CPUs 2 · SATA 100.00 GB|     |RAM 8192 MB · CPUs 2 · SATA 100.00 GB|
+-------------------------------------+     +-------------------------------------+
```

### Ejecutar

El Paso 1 y Paso 2 puede hacerlo en paralalelo si lo desea.

Paso 1: Master Virtual Machine.

```bash
hostnamectl set-hostname "master"
hostnamectl set-hostname "master.example.lan" --static
MYIP=$(ip addr show $(ip route | awk '/default/ { print $5 }') | grep "inet" | head -n 1 | awk '/inet/ {print $2}' | cut -d'/' -f1)
sed -i "s|$MYIP|192.168.0.101|g" /etc/sysconfig/network-scripts/ifcfg-enp0s3
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

Paso 2: Worker Virtual Machine.

```bash
hostnamectl set-hostname "worker"
hostnamectl set-hostname "worker.example.lan" --static
sed -i "s|192.168.0.xxx|192.168.0.102|g" /etc/sysconfig/network-scripts/ifcfg-enp0s3
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
