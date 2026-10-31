---
title: Linux - NetCat
date: 2026-03-14 21:36:26
categories:
- Linux
tags:
- Linux
- NetCat
---



## 删除`GNU Netcat`

```bash
[zhangsan@node2 ~]$ whereis nc
nc: /usr/local/bin/nc

[zhangsan@node2 ~]$ nc --version
netcat (The GNU Netcat) 0.7.1

[root@node2 zhangsan]# rm -f /usr/local/bin/nc
```

## 安装nmap NetCat

```bash
[root@node1 hadoop]# yum install epel-release -y

[root@node1 hadoop]#  yum install nc -y

[root@node1 zhangsan]# nc --version
Ncat: Version 7.50 ( https://nmap.org/ncat )

[root@node1 zhangsan]# nc -lk 9999
```

