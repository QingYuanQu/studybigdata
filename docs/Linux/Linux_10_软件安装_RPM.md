---
title: Linux软件安装 - RPM
date: 2023-01-14 15:55:26
categories:
- Linux
tags:
- Linux RPM软件包安装
marp: true
---

# RPM包安装

rpm命令是RPM软件包的管理工具。

RPM有多种基本的模式：它们是安装、查询、验证、删除等。

- 安装模式：rpm –i

- 查询模式：rpm -q

- 验证模式：rpm –V或 -verify

- 删除模式：rpm –e

- --nodeps 如果该RPM包的安装依赖其它包，即使其它包没装，也强迫安装。



## 卸载OpenJDK

> CentOS Desktop版本 默认携带OpenJDK。 
>
> CentOS minimal版本 未携带OpenJDK，无需卸载。

```shell
# 看一下java版本号，可以发现系统自带openjdk
[root@localhost ~]# java -version
openjdk version "1.8.0_282"
OpenJDK Runtime Environment (build 1.8.0_282-b08)
OpenJDK 64-Bit Server VM (build 25.282-b08, mixed mode)

# 查看已安装软件列表中带有jdk的软件包
[root@localhost ~]# rpm -qa|grep jdk
copy-jdk-configs-3.7-4.el8.noarch
java-1.8.0-openjdk-1.8.0.282.b08-4.el8.x86_64
java-1.8.0-openjdk-headless-1.8.0.282.b08-4.el8.x86_64

# 卸载掉openjdk，但是提示这个openjdk被其他软件包依赖
[root@localhost ~]# rpm -e java-1.8.0-openjdk-1.8.0.282.b08-4.el8.x86_64
error: Failed dependencies:
 java-1.8.0-openjdk is needed by (installed) icedtea-web-1.8.4-4.el8.x86_64
 
# 不管它，--nodeps 强制卸载
[root@localhost ~]# rpm -e --nodeps java-1.8.0-openjdk-1.8.0.282.b08-4.el8.x86_64
[root@localhost ~]# rpm -e --nodeps java-1.8.0-openjdk-headless-1.8.0.282.b08-4.el8.x86_64

# 再次查看，已安装软件列表内已经没有了openjdk
[root@localhost ~]# rpm -qa|grep jdk
copy-jdk-configs-3.7-4.el8.noarch
```

---



## [安装Oracle JDK](#install_jdk_rpm)

### 上传rpm安装包

略。

### 安装JDK

```shell
[root@node1 ~]# ll
total 112652
-rwxrw-rw-. 1 zhangsan zhangsan 115315748 Nov 22 04:19 jdk-8u311-linux-x64.rpm
```

### 使用rpm -i 安装jdk

```bash
[root@node1 ~]# rpm -i jdk-8u311-linux-x64.rpm 
warning: jdk-8u311-linux-x64.rpm: Header V3 RSA/SHA256 Signature, key ID ec551f03: NOKEY
Unpacking JAR files...
 tools.jar...
 plugin.jar...
 javaws.jar...
 deploy.jar...
 rt.jar...
 jsse.jar...
 charsets.jar...
 localedata.jar...
```

### 查看版本

```
[root@localhost ~]# java -version
java version "1.8.0_311"
Java(TM) SE Runtime Environment (build 1.8.0_311-b11)
Java HotSpot(TM) 64-Bit Server VM (build 25.311-b11, mixed mode)
```

### 配置环境变量

```shell
[root@node1 ~]# vim /etc/profile
export JAVA_HOME=/usr/java/default
```

### 让环境变量生效

```shell
[root@node1 ~]# source /etc/profile
```



---



## 安装WPS

```shell
# 在WPS官网下载RPM安装包 

# 使用rpm -i 安装提示缺少依赖 
[zhangsan@localhost ~]$ rpm -i wps-office-11.1.0.10702-1.x86_64.rpm
error: Failed dependencies:
 libGLU.so.1()(64bit) is needed by wps-office-11.1.0.10702-1.x86_64
 libXss.so.1()(64bit) is needed by wps-office-11.1.0.10702-1.x86_64

# 安装依赖libGLU
[root@localhost zhangsan]# yum install mesa-libGLU
Last metadata expiration check: 2:07:11 ago on Thu 18 Nov 2021 10:24:16 PM PST.
Dependencies resolved.   
Installed products updated.
Installed:
  mesa-libGLU-9.0.0-15.el8.x86_64                                                                                               
Complete!


# 安装依赖libXScrnSaver
[root@localhost zhangsan]# yum install libXss*
Last metadata expiration check: 2:12:23 ago on Thu 18 Nov 2021 10:24:16 PM PST.
Is this ok [y/N]: y
Downloading Packages:
libXScrnSaver-1.2.3-1.el8.x86_64.rpm                                                                                             
Installed:
  libXScrnSaver-1.2.3-1.el8.x86_64                                                                                                                                                                                 

Complete!


# 安装完依赖，安装wps
[root@localhost zhangsan]# rpm -i wps-office-11.1.0.10702-1.x86_64.rpm 
[root@localhost zhangsan]# 


# 查询安装的软件
[root@localhost nginx-1.21.4]# rpm -qa 

# 查询安装的wps
[root@localhost nginx-1.21.4]# rpm -qa | grep wps
wps-office-11.1.0.10702-1.x86_64

# 卸载wps
[root@localhost nginx-1.21.4]# rpm -e wps-office-11.1.0.10702-1.x86_64
[root@localhost nginx-1.21.4]# rpm -qa wps*
```

>   WPS 2019 安装后无法启动