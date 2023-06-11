# OpenShift Origin v3.11.0 Quickstart
Para el ejemplo, utilizaremos [Origin](https://github.com/openshift/origin) v3.11.0 , que es la implementación de código abierto de Red Hat conocida así hasta agosto de 2018. Es importante mencionar que el nombre del proyecto ha cambiado a [OKD](https://github.com/okd-project/okd), el cual ahora es considerado como un upstream.

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

Llamaremos a nuestro equipo Máquina Virtual de Prueba `tvm` en un dominio `example.lan` to disable the checksum
database for the vendoring update:

```bash
hostnamectl set-hostname tvm.example.lan
```
```bash
cat > /etc/hosts << "EOF"
127.0.0.1   localhost 
::1         localhost
EOF
```
```bash
yum check-update
```
```bash
yum groupinstall -y "Server with GUI"
systemctl set-default graphical
```
```bash
yum -y install bind bind-utils
```
`vi /etc/named.conf`
```bash
...
acl internal-network {
        192.168.0.0/24;
};
...
listen-on port 53 { any; };
listen-on-v6 port 53 { any; }
...
allow-query     { localhost; internal-network; };
allow-transfer  { localhost; };
...
zone "example.lan" IN {
        type master;
        file "/var/named/example.lan.db";
        allow-update { none; };
};

zone "0.168.192.in-addr.arpa" IN {
        type master;
        file "/var/named/0.168.192.in-addr.arpa.db";
        allow-update { none; };
};
....
```
```bash
cat > /var/named/example.lan.db << "EOF"
$TTL 86400

@       IN        SOA      tvm.example.lan.        root.example.lan. (
        2023010101  ;Serial
        3600        ;Refresh
        1800        ;Retry
        604800      ;Expire
        86400       ;Minimum TTL
)

;Name Server Information
@       IN        NS       tvm.example.lan.

;IP address of Name Server
tvm     IN        A        192.168.0.100

;Mail exchanger
example.lan.      IN       MX        10        mail.example.lan.

;A - Record HostName To IP Address
www     IN        A        192.168.0.100
mail    IN        A        192.168.0.100

;CNAME record
ftp     IN        CNAME    www.example.lan.
EOF
```
```bash
cat > /var/named/0.168.192.in-addr.arpa.db << "EOF"
$TTL 86400

@       IN        SOA      tvm.example.lan.        root.example.lan. (
        2023010101  ;Serial
        3600        ;Refresh
        1800        ;Retry
        604800      ;Expire
        86400       ;Minimum TTL
)

;Name Server Information
@       IN        NS       tvm.example.lan.

;Reverse lookup for Name Server
100     IN        PTR      tvm.example.lan.

;PTR Record IP address to HostName
100     IN        PTR      www.example.lan.
100     IN        PTR      mail.example.lan.
EOF
```
```bash

```

Paso 1: En Master Virtual Machine y en Worker Virtual Machine.

>Master Virtual Machine "[Paso_1-Master_Virtual_Machine.sh](Paso_1-Master_Virtual_Machine.sh)".
```bash
#!/bin/bash

#
# Paso 1 - Master Virtual Machine
# By: Oscar Guillermo Flores Balladares <oky.pe>
#

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
yum install -y  epel-release
sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo
systemctl | grep "NetworkManager.*running" 
if [ $? -eq 1 ]; then systemctl start NetworkManager docker systemctl enable NetworkManager docker; fi
yum -y --enablerepo=epel install pyOpenSSL
yum -y --enablerepo=epel install https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.6.5-1.el7.ans.noarch.rpm
reboot
```

>Worker Virtual Machine "[Paso_1-Worker_Virtual_Machine.sh](Paso_1-Worker_Virtual_Machine.sh)".
```bash
#!/bin/bash

#
# Paso 1 - Worker Virtual Machine
# By: Oscar Guillermo Flores Balladares <oky.pe>
#

hostnamectl set-hostname "worker"
hostnamectl set-hostname "worker.example.lan" --static
MYIP=$(ip addr show $(ip route | awk '/default/ { print $5 }') | grep "inet" | head -n 1 | awk '/inet/ {print $2}' | cut -d'/' -f1)
sed -i "s|$MYIP|192.168.0.102|g" /etc/sysconfig/network-scripts/ifcfg-enp0s3
systemctl restart network.service
cat << EOF > /etc/hosts
127.0.0.1   localhost 
::1         localhost
192.168.0.101   master.example.lan   master
192.168.0.102   worker.example.lan   worker
EOF
yum update -y
yum install -y  wget git zile nano net-tools docker-1.13.1 bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct openssl-devel httpd-tools NetworkManager python-cryptography python2-pip python-devel  python-passlib java-1.8.0-openjdk-headless "@Development Tools"
yum install -y  epel-release
sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo
systemctl | grep "NetworkManager.*running" 
if [ $? -eq 1 ]; then systemctl start NetworkManager docker systemctl enable NetworkManager docker; fi
yum -y --enablerepo=epel install pyOpenSSL
yum -y --enablerepo=epel install https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.6.5-1.el7.ans.noarch.rpm
reboot
```

Paso 2: En Master Virtual Machine.

>Master Virtual Machine "[Paso_2-Master_Virtual_Machine.sh](Paso_2-Master_Virtual_Machine.sh)".
```bash
#!/bin/bash

#
# Paso 2 - Master Virtual Machine
# By: Oscar Guillermo Flores Balladares <oky.pe>
#

ssh-keygen
for host in master.example.lan worker.example.lan; do ssh-copy-id -i ~/.ssh/id_rsa.pub $host; done
export ANSIBLE_HOST_KEY_CHECKING=False
git clone https://github.com/openshift/openshift-ansible.git && cd openshift-ansible && git fetch && git checkout release-3.11 && cd ..
touch inventory.ini
cat << EOF > inventory.ini
[OSEv3:children]
masters
nodes
etcd 
[masters]
192.168.0.101 
[etcd]
192.168.0.101 
[nodes]
192.168.0.101 openshift_node_group_name="node-config-master"
192.168.0.102 openshift_node_group_name="node-config-infra" 
[OSEv3:vars]
openshift_additional_repos=[{'id': 'centos-paas', 'name': 'centos-paas', 'baseurl' :'https://buildlogs.centos.org/centos/7/paas/x86_64/openshift-origin311', 'gpgcheck' :'0', 'enabled' :'1'}] 
ansible_ssh_user=root
ansible_ssh_pass=1
enable_excluders=False
enable_docker_excluder=False
ansible_service_broker_install=False 
containerized=True
os_sdn_network_plugin_name='redhat/openshift-ovs-multitenant'
openshift_disable_check=disk_availability,memory_availability 
deployment_type=origin
openshift_deployment_type=origin 
template_service_broker_selector={"region":"infra"}
openshift_metrics_image_version="v3.11"
openshift_logging_image_version="v3.11"
openshift_logging_elasticsearch_proxy_image_version="v1.0.0"
openshift_logging_es_nodeselector={"node-role.kubernetes.io/infra":"true"}
logging_elasticsearch_rollout_override=false
osm_use_cockpit=true 
openshift_uninstall_images=false
openshift_metrics_install_metrics=false
openshift_logging_install_logging=false 
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider'}] 
openshift_public_hostname=console.192.168.0.101
openshift_master_default_subdomain=apps.192.168.0.101
openshift_master_api_port=8443
openshift_master_console_port=8443
EOF
sed -i -e "s/{{ hostvars[inventory_hostname] | certificates_to_synchronize }}/{{ hostvars[inventory_hostname]['ansible_facts'] | certificates_to_synchronize }}/" openshift-ansible/roles/openshift_master_certificates/tasks/main.yml
sed -i -e "s/logging_elasticsearch_rollout_override | bool/logging_elasticsearch_rollout_override | default(False) | bool/" openshift-ansible/roles/openshift_logging_elasticsearch/handlers/main.yml
ansible-playbook -vv -i inventory.ini openshift-ansible/playbooks/prerequisites.yml
ansible-playbook -vv -i inventory.ini openshift-ansible/playbooks/deploy_cluster.yml
htpasswd -b /etc/origin/master/htpasswd admin admin
oc adm policy add-cluster-role-to-user cluster-admin admin
```
