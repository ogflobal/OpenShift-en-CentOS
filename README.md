# OpenShift en CentOS
Para el ejemplo usaremos [origin](https://github.com/openshift/origin) v3.11.0, que es la implementación de código abierto de Red Hat y mencionar que el nombre del proyecto se cambia a [okd](https://github.com/okd-project/okd).
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

