# OpenShift en CentOS
Usaremos [origin](https://github.com/openshift/origin), que es la implementación de código abierto de Red Hat y mencionar que el nombre del proyecto se cambia a [okd](https://github.com/okd-project/okd) desde la versión anterior 3.10.

### Entorno

```
-------------------+-------------------     -------------------+-------------------
enp0s3             |      192.168.0.101     enp0s3             |      192.168.0.102
+------------------+------------------+     +------------------+------------------+
|         [master.example.lan]        |     |         [master.example.lan]        |
|        Master Virtual Machine       |     |        Worker Virtual Machine       |
+-------------------------------------+     +-------------------------------------+
```

