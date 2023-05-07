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
#reboot
