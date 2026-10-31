---
title: Linux网络管理
date: 2023-01-14 15:55:26
categories:
- Linux
tags:
- Linux网络管理
- 防火墙设置
marp: true
---

# 网络管理

## 常用命令

### hosts文件

```shell
[zhangsan@localhost ~]$ cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
```

### ifconfig命令

Linux `ifconfig`命令用于显示或设置网络设备。`ifconfig`可设置网络设备的状态，或是显示目前的设置。

```shell
[zhangsan@localhost ~]$ ifconfig
ens160: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.179.128  netmask 255.255.255.0  broadcast 192.168.179.255
        inet6 fe80::20c:29ff:fef6:60fb  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:f6:60:fb  txqueuelen 1000  (Ethernet)
        RX packets 54852  bytes 76232529 (72.7 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 9042  bytes 546819 (534.0 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        
# inet 192.168.179.128 - ip地址
# ether 00:0c:29:f6:60:fb - MAC地址
# lo - 本地环回地址
lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 74  bytes 5480 (5.3 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 74  bytes 5480 (5.3 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        
# 关闭网卡 
[root@localhost zhangsan]# ifconfig ens160 down

# 启动网卡
[root@localhost zhangsan]# ifconfig ens160 up
```

环回地址lo是主机用于向自身发送通信的一个特殊地址（也就是一个特殊的目的地址）。

- Q:  本机和本机Socket通信会走网卡吗？
- A:  不走网卡，不走物理设备，但是走虚拟设备，loopback device环回. 本机发给本机的数据，在网络层就可以判别是本机，不需要往外转发。

### ping命令

`ping`命令用来测试主机之间网络的连通性。执行`ping`指令会使用ICMP传输协议，发出要求回应的信息，若远端主机的网络功能没有问题，就会回应该信息，因而得知该主机运作正常。

```shell
[root@localhost zhangsan]# ping www.baidu.com
PING www.a.shifen.com (39.156.66.14) 56(84) bytes of data.
64 bytes from 39.156.66.14 (39.156.66.14): icmp_seq=1 ttl=128 time=24.6 ms
64 bytes from 39.156.66.14 (39.156.66.14): icmp_seq=2 ttl=128 time=31.6 ms
64 bytes from 39.156.66.14 (39.156.66.14): icmp_seq=3 ttl=128 time=30.6 ms
64 bytes from 39.156.66.14 (39.156.66.14): icmp_seq=4 ttl=128 time=31.2 ms
64 bytes from 39.156.66.14 (39.156.66.14): icmp_seq=5 ttl=128 time=28.9 ms
64 bytes from 39.156.66.14 (39.156.66.14): icmp_seq=6 ttl=128 time=26.7 ms
64 bytes from 39.156.66.14 (39.156.66.14): icmp_seq=7 ttl=128 time=22.8 ms
^C
--- www.a.shifen.com ping statistics ---
7 packets transmitted, 7 received, 0% packet loss, time 6012ms
rtt min/avg/max/mdev = 22.792/28.064/31.619/3.200 ms
```

### netstat命令

`netstat` 命令用于显示各种网络相关信息，如网络连接，路由表，接口状态 (Interface Statistics) 连接，多播成员 (Multicast Memberships) 等等。

```shell
-a (all)显示所有选项，默认不显示LISTEN相关
-t (tcp)仅显示tcp相关选项
-u (udp)仅显示udp相关选项
-n 拒绝显示别名，能显示数字的全部转化成数字。
-p 显示建立相关链接的程序名

# 查看3306端口状态
[root@localhost zhangsan]# netstat -atnp |grep 3306
tcp6       0      0 :::3306                 :::*                    LISTEN      64472/mysqld 
```

---



## 防火墙规则配置

### 查看防火墙状态

```bash
[root@localhost ~]# firewall-cmd --state
running
```

### 列出开放端口

```
[root@localhost ~]# firewall-cmd --list-port
80/tcp 3306/tcp
```

### [添加端口](#firewall_add_port)

```bash
# 添加端口3306
[root@localhost ~]# firewall-cmd --zone=public --add-port=3306/tcp  --permanent
success
```

参数详解：

- --zone  作用域
- --add-port=80/tcp  添加端口， 格式为：  端口/ 通讯协议
- --permanent   永久生效，没有此参数，重启失效

### 删除端口

```bash
[root@localhost ~]# firewall-cmd --zone=public --remove-port=3306/tcp --permanent
```

### 重载防火墙

```
[root@localhost ~]# firewall-cmd --reload
success
```

