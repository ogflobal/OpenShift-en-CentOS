# Inicio rápido local de OpenShift Origin v3.11.0 en Centos 7
Para el ejemplo, utilizaremos [Origin](https://github.com/openshift/origin), que es la implementación de código abierto de Red Hat conocida así hasta agosto de 2018. Es importante mencionar que el nombre del proyecto ha cambiado a [OKD](https://github.com/okd-project/okd), el cual ahora es considerado como un upstream. Descarguemos e instalemos [CentOS](https://archive.org/download/cent-os-7-dvd-x8664/CentOS-7-x86_64-DVD-2009.iso) y empecemos.

![Screenshot](https://github.com/ogflobal/OpenShift-Origin-v3.11.0-local-quickstart/assets/74718043/5b55a175-d72e-4819-9dec-dbd1ccb2c95e)

### VirtualBox

```
-------------------+-------------------
enp0s3             |      192.168.0.100
+------------------+------------------+
|           [tvm.example.lan]        |
|         Test  Virtual Machine       |
|    Conectado a: Adaptador puente    |
|RAM 16384 MB · CPU 2 · SATA 100.00 GB|
+-------------------------------------+
```

### Shell

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

<details>
<summary>vi /etc/named.conf</summary>
<p>

```
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

</p>
</details>

```bash
cat > /var/named/example.lan.db << "EOF"
$TTL 86400

@       IN        SOA      tvm.example.lan.        root.example.lan. (
        2023010101         ;Serial
        3600               ;Refresh
        1800               ;Retry
        604800             ;Expire
        86400              ;Minimum TTL
)

;Name Server Information
@       IN        NS       tvm.example.lan.

;IP address of Name Server
tvm     IN        A        192.168.0.100

;Mail exchanger
example.lan.      IN       MX                      10        mail.example.lan.

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
        2023010101         ;Serial
        3600               ;Refresh
        1800               ;Retry
        604800             ;Expire
        86400              ;Minimum TTL
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
systemctl enable --now named
```

<details>
<summary>vi /etc/sysconfig/network-scripts/ifcfg-enp0s3</summary>
<p>

```
...
PEERDNS="no"
...
```

</p>
</details>

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

```bash
reboot
```

<details>
<summary>vi /etc/resolv.conf</summary>
<p>

```
...
nameserver 192.168.0.100
...
```

</p>
</details>

```bash
dig tvm.example.lan.
dig -x 192.168.0.100
```

```bash
ping tvm
ping 192.168.0.100
ping tvm.example.lan
ping www.example.lan
```

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
oc cluster up --public-hostname=www.example.lan --routing-suffix=example.lan
oc cluster down
```

<details>
<summary>vi ./openshift.local.clusterup/openshift-controller-manager/openshift-master.kubeconfig</summary>
<p>

```
...
server: https://www.example.lan:8443
...
```

</p>
</details>

<details>
<summary>vi .kube/config</summary>
<p>

```
...
server: https://www.example.lan:8443
...
```

</p>
</details>

```bash
oc cluster up --public-hostname=www.example.lan --routing-suffix=example.lan
oc status
```
