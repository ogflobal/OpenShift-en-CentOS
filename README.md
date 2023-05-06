# OpenShift en CentOS
Cosas que necesita saber para usar OpenShift en CentOS. Este ejemplo se basa en el entorno de la siguiente manera:

```
-------------------+-------------------     -------------------+-------------------
enp0s3             |      192.168.0.100     enp0s3             | 192.168.0.101
+------------------+------------------+     +------------------+------------------+
|              [mns.tek.lan]          |     |              [wns.tek.lan]          |
|       Master Node Server            |     |       Worker Node Server            |
+-------------------------------------+     +-------------------------------------+

```

### Configuración del sistema

####SELinux

Verifique que SELinux esté habilitado y aplicado, con tipo específico. Al revisar el archivo `/etc/selinux/config` debería verse así (verifique dos veces que `SELINUX` y `SELINUXTYPE` coincidan con los comentarios anteriores):

```bash
# Este archivo controla el estado de SELinux en el sistema.
# SELINUX= puede tomar uno de estos tres valores:
# enforcing: se aplica la política de seguridad de SELinux.
# permisivo: SELinux imprime advertencias en lugar de aplicarlas.
# disabled: no se carga ninguna política de SELinux.
SELINUX=hacer cumplir
# SELINUXTYPE= puede tomar uno de tres dos valores:
# dirigido: los procesos dirigidos están protegidos,
# mínimo: modificación de la política específica. Solo los procesos seleccionados están protegidos.
# mls - Protección de seguridad multinivel.
SELINUXTYPE=orientado  
```
