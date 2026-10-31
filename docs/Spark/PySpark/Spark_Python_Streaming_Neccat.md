---
title: NetCat工具安装
date: 2022-03-23 15:55:26
categories:
- PySpark
---

## NetCat

##### 安装依赖

```shell
[root@node0 netcat-0.7.1]# yum install gcc
```

##### 下载

```shell
[root@node0 zhangsan]# curl -O -L http://sourceforge.net/projects/netcat/files/netcat/0.7.1/netcat-0.7.1.tar.gz
```

##### 解压

```shell
[root@node0 zhangsan]# tar -zxf netcat-0.7.1.tar.gz 
```

```shell
[root@node0 zhangsan]# cd netcat-0.7.1
```

##### 配置

```shell
[root@node0 netcat-0.7.1]# ./configure 
```

##### 编译

```shell
[root@node0 netcat-0.7.1]# make
```

##### 安装

```shell
[root@node0 netcat-0.7.1]# make install
```

##### 使用

```shell
[root@node0 netcat-0.7.1]# netcat -lp 9999
```



