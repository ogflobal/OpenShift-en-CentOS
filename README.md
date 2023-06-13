# Mi OpenShift Origin v3.11.0 en Centos 7 localmente
Para este ejemplo, utilizaremos [Origin](https://github.com/openshift/origin), la implementación de código abierto de Red Hat. Es importante mencionar que el nombre del proyecto ha cambiado a [OKD](https://github.com/okd-project/okd) y ahora se considera un upstream. A continuación, procederemos a descargar e instalar [CentOS](https://archive.org/download/cent-os-7-dvd-x8664/CentOS-7-x86_64-DVD-2009.iso) para comenzar.

### VirtualBox

Preparamos una máquina virtual similar como la que se muestra en imagen.

![image](https://github.com/ogflobal/OpenShift-Origin-v3.11.0-quickstart-on-Centos-7-locally/assets/74718043/5b0e990c-5989-4329-bbe7-3ff0acff686b)

### Shell

Ejecutamos o editamos según corresponda.

```bash
hostnamectl set-hostname nombredeequipo.nombrededominio.nip.io
```

```bash
cat > /etc/hosts << "EOF"
127.0.0.1   localhost 
::1         localhost
192.168.0.100   nombredeequipo.nombrededominio.nip.io
EOF
```

<details>
<summary>vi /etc/NetworkManager/NetworkManager.conf</summary>
<p>

```
...
[main]
...
dns=none
...
```

</p>
</details>

<details>
<summary>vi /etc/sysconfig/network-scripts/ifcfg-enp0s3</summary>
<p>

```
...
PEERDNS="no"
DNS1="8.8.8.8"
IPV6_PRIVACY="no"
...
```

</p>
</details>

```bash
reboot
```

<details>
<summary>vi /etc/resolv.conf</summary>
<p>

```
...
search nip.io
nameserver 8.8.8.8
...
```

</p>
</details>

```bash
yum install -y centos-release-openshift-origin
yum install -y wget git net-tools bind-utils iptables-services bridge-utils bash-completion origin-clients 
yum install -y docker
```

```bash
sed -i '/OPTIONS=.*/c\OPTIONS="--selinux-enabled --insecure-registry 172.30.0.0/16"' /etc/sysconfig/docker
```

```bash
systemctl enable docker
systemctl start docker
systemctl is-active docker
```

<details>
<summary>vi /etc/containers/registries.conf</summary>
<p>

```
...
registries = ['172.30.0.0/16']
...
```

</p>
</details>

```bash
systemctl daemon-reload
systemctl restart docker
```

```bash
docker network inspect -f "{{range .IPAM.Config }}{{ .Subnet }}{{end}}" bridge
```

```bash
firewall-cmd --permanent --new-zone dockerc
firewall-cmd --permanent --zone dockerc --add-source 172.17.0.0/16
firewall-cmd --permanent --zone dockerc --add-port 8443/tcp
firewall-cmd --permanent --zone dockerc --add-port 53/udp
firewall-cmd --permanent --zone dockerc --add-port 8053/udp
firewall-cmd --reload
```

```bash
oc cluster up --public-hostname=nombrededominio.nip.io --routing-suffix=nombrededominio.nip.io
oc cluster down
```

<details>
<summary>vi ./openshift.local.clusterup/openshift-controller-manager/openshift-master.kubeconfig</summary>
<p>

```
...
server: https://nombrededominio.nip.io:8443
...
```

</p>
</details>

<details>
<summary>vi .kube/config</summary>
<p>

```
...
server: https://nombrededominio.nip.io:8443
...
```

</p>
</details>

```bash
oc cluster up --public-hostname=nombrededominio.nip.io --routing-suffix=nombrededominio.nip.io
oc status
```
