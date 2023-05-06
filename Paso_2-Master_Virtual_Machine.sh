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