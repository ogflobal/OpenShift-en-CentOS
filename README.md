# Cómo instalar y configurar OpenShift Origin v3.11.0 en un servidor CentOS 7 localmente
Es importante mencionar que el nombre del proyecto ha cambiado a [OKD](https://github.com/okd-project/okd) y ahora se considera un upstream.

A continuación, procederemos a descargar [CentOS](https://archive.org/download/cent-os-7-dvd-x8664/CentOS-7-x86_64-DVD-2009.iso) para comenzar.

### VirtualBox

Preparamos una máquina virtual similar como la que se muestra en imagen.

![image](https://github.com/ogflobal/My-OpenShift-Origin-v3.11.0-on-Centos-7-locally/assets/74718043/2d327cf1-77a4-41d3-9b03-e8abfa644121)

### Shell

Ejecutamos o editamos según corresponda.

```bash
hostnamectl set-hostname test.192.168.0.100.nip.io
```

```bash
cat > /etc/hosts << "EOF"
127.0.0.1   localhost
::1         localhost
192.168.0.100   test.192.168.0.100.nip.io
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
GATEWAY="192.168.0.1"
PEERDNS="no"
DNS1="8.8.8.8"
IPV6_PRIVACY="no"
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
```

</p>
</details>

```bash
reboot
```

```bash
yum install -y centos-release-openshift-origin
```

```bash
yum install -y wget git net-tools bind-utils iptables-services bridge-utils bash-completion origin-clients
```

```bash
yum install -y docker
```

```bash
sed -i '/OPTIONS=.*/c\OPTIONS="--selinux-enabled --insecure-registry 172.30.0.0/16"' /etc/sysconfig/docker
```

```bash
systemctl enable docker
```

```bash
systemctl start docker
```

<details>
<summary>vi /etc/containers/registries.conf</summary>
<p>

```
...
[registries.insecure]
registries = ['172.30.0.0/16']
...
```

</p>
</details>

```bash
systemctl daemon-reload
```

```bash
systemctl restart docker
```

```bash
systemctl is-active docker
```

```bash
docker network inspect -f "{{range .IPAM.Config }}{{ .Subnet }}{{end}}" bridge
```

```bash
firewall-cmd --permanent --new-zone dockerc

```

```bash
firewall-cmd --permanent --zone dockerc --add-source 172.17.0.0/16
```

```bash
firewall-cmd --permanent --zone dockerc --add-port 8443/tcp
```

```bash
firewall-cmd --permanent --zone dockerc --add-port 53/udp
```

```bash
firewall-cmd --permanent --zone dockerc --add-port 8053/udp
```

```bash
firewall-cmd --reload
```

```bash
oc cluster up --public-hostname=192.168.0.100.nip.io --routing-suffix=192.168.0.100.nip.io
```

```bash
oc cluster down
```

<details>
<summary>vi ./openshift.local.clusterup/openshift-controller-manager/openshift-master.kubeconfig</summary>
<p>

```
apiVersion: v1
clusters:
- cluster:
...
server: https://192.168.0.100.nip.io:8443
name: 127-0-0-1:8443
...
```

</p>
</details>

<details>
<summary>vi .kube/config</summary>
<p>

```
apiVersion: v1
clusters:
- cluster:
...
server: https://192.168.0.100.nip.io:8443
name: 127-0-0-1:8443
...
```

</p>
</details>

```bash
oc cluster up --public-hostname=192.168.0.100.nip.io --routing-suffix=192.168.0.100.nip.io
```

### Ejemplos
```bash
oc login

oc new-project proyecto-de-ejemplo --display-name="Proyecto de ejemplo" --description="Servidores web"

oc new-app centos/nginx-112-centos7~https://github.com/sclorg/nginx-ex --name=nginx 

oc expose service nginx

oc get svc

oc login -u system:admin -n proyecto-de-ejemplo

oadm policy add-cluster-role-to-user cluster-admin test

oc login

oc get namespaces

oc get pods --all-namespaces

oc get pods --all-namespaces | grep ngin

oc get pods -o wide

oc get namespaces
```

### Problemas y solución
Problema 01: Reading docker config from /root/.docker/config.json failed: open /root/.docker/config.json: no such file or directory, will attempt to pull image docker.io/openshift/origin-control-plane:v3.11 anonymously
error: error pulling Docker image openshift/origin-control-plane:v3.11

Solución 01: docker login --username=tu_usuario_(https://hub.docker.com/)

