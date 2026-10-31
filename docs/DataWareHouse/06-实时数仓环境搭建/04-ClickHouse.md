

# ClickHouse的安装

## 准备工作

### 确定防火墙处于关闭状态

```bash
[root@node1 ~]# systemctl status firewalld
```

### CentOS取消打开文件数限制

**1）在node1的  /etc/security/limits.conf文件的末尾加入以下内容**

​    注意：以下操作会修改 Linux 系统配置，如果操作不当可能导致虚拟机无法启动，建议在执行以下操作之前给虚拟机分别打个快照。（快照拍摄需要在关机状态下执行）

```bash
[root@node1 ~]# sudo vim /etc/security/limits.conf
* soft nofile 65536 
* hard nofile 65536 
* soft nproc 131072 
* hard nproc 131072
```

**2）在node1的/etc/security/limits.d/20-nproc.conf文件的末尾加入以下内容**

```bash
[root@node1 ~]# sudo vim /etc/security/limits.d/20-nproc.conf
* soft nofile 65536 
* hard nofile 65536 
* soft nproc 131072 
* hard nproc 131072
```

### 安装依赖

```bash
[root@node1 ~]# sudo yum install -y libtool
[root@node1 ~]# sudo yum install -y *unixODBC*     
```

### CentOS取消SELINUX 

**1）修改/etc/selinux/config中的SELINUX=disabled** 

```bash
[root@node1 ~]# sudo vim /etc/selinux/config 
SELINUX=disabled
```

**2）执行同步操作**

略，我们此次实验采用单节点。

**3）重启服务器**

```bash
[root@node1 ~]# sudo reboot
```

## 单机安装

### 在node1的/opt/software下创建clickhouse目录

```bash
[root@node1 ~]# cd /opt/software/
[root@node1 software]$ mkdir clickhouse
```

### 将4个rpm文件上传到node1的/opt/software/clickhouse目录下

```bash
[zhangsan@node1 clickhouse]$ ll
总用量 1262276
-rw-rw-r-- 1 zhangsan zhangsan      56708 4月   7 12:42 clickhouse-client-20.4.5.36-2.noarch.rpm
-rw-rw-r-- 1 zhangsan zhangsan  117222435 4月   7 12:42 clickhouse-common-static-20.4.5.36-2.x86_64.rpm
-rw-rw-r-- 1 zhangsan zhangsan 1175204526 4月   7 12:42 clickhouse-common-static-dbg-20.4.5.36-2.x86_64.rpm
-rw-rw-r-- 1 zhangsan zhangsan      78318 4月   7 12:42 clickhouse-server-20.4.5.36-2.noarch.rpm
```

### 安装这4个rpm文件

```bash
[zhangsan@node1 clickhouse]$ sudo rpm -ivh *.rpm
警告：clickhouse-client-20.4.5.36-2.noarch.rpm: 头V4 RSA/SHA1 Signature, 密钥 ID e0c56bd4: NOKEY
准备中...                          ################################# [100%]
正在升级/安装...
   1:clickhouse-common-static-20.4.5.3################################# [ 25%]
   2:clickhouse-client-20.4.5.36-2    ################################# [ 50%]
   3:clickhouse-server-20.4.5.36-2    ################################# [ 75%]
Created symlink from /etc/systemd/system/multi-user.target.wants/clickhouse-server.service to /etc/systemd/system/clickhouse-server.service.
Path to data directory in /etc/clickhouse-server/config.xml: /var/lib/clickhouse/
   4:clickhouse-common-static-dbg-20.4################################# [100%]
```

查看安装情况

```bash
[zhangsan@node1 clickhouse]$ sudo rpm -qa|grep clickhouse
clickhouse-client-20.4.5.36-2.noarch
clickhouse-common-static-20.4.5.36-2.x86_64
clickhouse-server-20.4.5.36-2.noarch
clickhouse-common-static-dbg-20.4.5.36-2.x86_64
```

### 修改配置文件

```bash
[zhangsan@node1 clickhouse]$ sudo vim /etc/clickhouse-server/config.xml
```

**1）配置允许被外部节点访问**

把 <listen_host>::</listen_host> 的注释打开，这样的话才能让ClickHouse被除本机以外的服务器访问

**2）分发配置文件**

单机版，跳过此处。

```bash
[zhangsan@node1 clickhouse]$ sudo /home/zhangsan/bin/xsync /etc/clickhouse-server/config.xml
```

在这个文件中，有ClickHouse的一些默认路径配置，比较重要的

Ø 数据文件路径：<path>/var/lib/clickhouse/</path>

Ø 日志文件路径：<log>/var/log/clickhouse-server/clickhouse-server.log</log>

### 启动ClickServer

```bash
[zhangsan@node1 clickhouse]$ sudo systemctl start clickhouse-server
```

注意：如果安装过zabbix，需要禁用一些服务的开机自启

### 关闭开机自启

```bash
[zhangsan@node1 clickhouse]$ sudo systemctl disable clickhouse-server 
```

### 使用client连接server

```bash
[zhangsan@node1 clickhouse]$ clickhouse-client -m
```

-m :可以在命令窗口输入多行命令