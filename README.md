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

### Ejecutar

master.sh
```bash
hostnamectl set-hostname "master"
hostnamectl set-hostname "master.example.lan" --static
sed -i "s|192.168.0.100|192.168.0.101|g" /etc/sysconfig/network-scripts/ifcfg-enp0s3
systemctl restart network.service
cat << EOD > /etc/hosts
127.0.0.1   localhost 
::1         localhost
192.168.0.101   master.example.lan   master
192.168.0.102   worker.example.lan   worker
EOD
yum update -y
yum install -y  wget git zile nano net-tools docker-1.13.1 bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct openssl-devel httpd-tools NetworkManager python-cryptography python2-pip python-devel  python-passlib java-1.8.0-openjdk-headless "@Development Tools"
yum -y install epel-release
sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo
systemctl | grep "NetworkManager.*running" 
if [ $? -eq 1 ]; then systemctl start NetworkManager systemctl enable NetworkManager; fi
yum -y --enablerepo=epel install pyOpenSSL
yum -y --enablerepo=epel install https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.6.5-1.el7.ans.noarch.rpm
ssh-keygen
for host in master.example.lan worker.example.lan; do ssh-copy-id -i ~/.ssh/id_rsa.pub $host; done
export ANSIBLE_HOST_KEY_CHECKING=False
git clone https://github.com/openshift/openshift-ansible.git && cd openshift-ansible && git fetch && git checkout release-3.11 && cd ..
touch inventory.ini
cat << EOD > inventory.ini
[OSEv3:children]
masters
nodes
etcd 
[masters]
master.example.lan 
[etcd]
master.example.lan 
[nodes]
master.example.lan openshift_node_group_name="node-config-master-infra"
worker.example.lan openshift_node_group_name="node-config-compute" 
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
openshift_public_hostname=console.master.example.lan
openshift_master_default_subdomain=apps.master.example.lan
openshift_master_api_port=8443
openshift_master_console_port=8443
EOD
sed -i -e "s/{{ hostvars[inventory_hostname] | certificates_to_synchronize }}/{{ hostvars[inventory_hostname]['ansible_facts'] | certificates_to_synchronize }}/" openshift-ansible/roles/openshift_master_certificates/tasks/main.yml
sed -i -e "s/logging_elasticsearch_rollout_override | bool/logging_elasticsearch_rollout_override | default(False) | bool/" openshift-ansible/roles/openshift_logging_elasticsearch/handlers/main.yml
ansible-playbook -vv -i inventory.ini openshift-ansible/playbooks/prerequisites.yml
ansible-playbook -vv -i inventory.ini openshift-ansible/playbooks/deploy_cluster.yml
htpasswd -b /etc/origin/master/htpasswd admin admin
oc adm policy add-cluster-role-to-user cluster-admin admin
```
