---
title: Linux软件安装 - YUM软件安装
date: 2023-01-14 15:55:26
categories:
- Linux
tags:
- Linux YUM
marp: true
---



- hadoop   tar.gz(tar文件放入箱子里面，gzip 把箱子压缩)
- jdk           rpm
- mysql     yum
- redis       源码编译

## YUM

YUM(全称为 Yellow dog Updater Modified)是一个在Fedora和RedHat以及CentOS中的Shell前端软件包管理器。**基于RPM包管理**，能够从指定的服务器**自动下载RPM包**并且安装，可以**自动处理依赖性关系**，并且一**次安装所有依赖的软件包**，无须繁琐地一次次下载、安装。yum提供了查找、安装、删除某一个、一组甚至全部软件包的命令，而且命令简洁而又好记。


### yum安装/卸载软件

-   yum -y install 软件名 			#安装，升级软件包，-y表示自动确认，-q表示静默安装

-   yum -y remove/erase 软件名           #卸载软件包，可自动解决其依赖关系

-   yum -y update 软件名                       #升级软件包

### yum查询软件包 

-   yum list                                          #查询软件包列表

-   yum list installed                           #查询系统中已安装的软件包

-   yum list available                          #查询仓库中尚未安装的软件包

-   yum list updates                           #查询可以升级版本的软件包



### [安装MySQL](#install_mysql)

> <https://dev.mysql.com/doc/mysql-yum-repo-quick-guide/en/>



#### MySQL 8

```bash
# 下载mysql的rpm安装包，只有11.22k
[root@localhost ~]# wget https://dev.mysql.com/get/mysql80-community-release-el8-2.noarch.rpm

# 安装rpm包
[root@localhost ~]# rpm -i mysql80-community-release-el8-2.noarch.rpm 
```

#### MySQL 5.7

```bash
# 创建repo文件
[root@localhost zhangsan]# vim /etc/yum.repos.d/mysql-community.repo 
# 填入mysql57的下载地址
[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/$basearch/
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
```

#### YUM在线安装

```shell
# 安装MySQL数据库服务器
[root@localhost ~]# yum install mysql-community-server

# 查看MySQL状态 
[root@localhost ~]# systemctl status mysqld

# 启动MySQL服务
[root@localhost ~]# systemctl start mysqld

# 查看MySQL状态
[root@localhost ~]# systemctl status mysqld

# 查看初始密码
[root@localhost ~]# grep "password" /var/log/mysqld.log 
2021-11-23T00:06:08.324728Z 1 [Note] A temporary password is generated for root@localhost: q3!QeyRpjfff

# 使用生成的初始密码登录，然后修改密码
[root@localhost zhangsan]# mysql -u root -p

# MySQL对密码要求至少8为，修改设置，调整密码策略（可选）
# MySQL 8 无法使用下面的方法设置密码策略。
mysql>  set global validate_password_policy=0;
mysql>  set global validate_password_length=6;

# 修改密码
mysql> alter user 'root'@'localhost' identified by '123456';
Query OK, 0 rows affected (0.06 sec)

mysql> SHOW VARIABLES LIKE 'validate_password%';

mysql> use mysql;

# 设置root从非本机也可以访问
mysql> update user set host='%' where user='root';

# 刷新权限
mysql> flush privileges;

# 退出
mysql> quit;

```



### MySQL 客户端工具

```http
https://www.navicat.com.cn/download/navicat-premium-lite
```

