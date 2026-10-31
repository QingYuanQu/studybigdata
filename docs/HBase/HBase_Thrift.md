---
title: HBase Thrift
date: 2022-10-14 09:55:26
categories:
- HBase
tags:
- HBase Thrift
---


##### 前期准备


>https://thrift.apache.org/docs/install/centos.html

Git clone失败，可以跳过，直接下载源码包。

##### 下载源码包

https://www.apache.org/dyn/closer.cgi?path=/thrift/0.16.0/thrift-0.16.0.tar.gz

##### 编译安装

```shell
(python37) [zhangsan@node0 thrift-0.16.0]$ cd /opt/bigdata/thrift/
(python37) [zhangsan@node0 thrift-0.16.0]$ cd thrift-0.16.0
(python37) [zhangsan@node0 thrift-0.16.0]$ ./bootstrap.sh
(python37) [zhangsan@node0 thrift-0.16.0]$ ./configure
(python37) [zhangsan@node0 thrift-0.16.0]$ make
```



```shell
[root@node0 thrift-0.16.0]# make install
[root@node0 thrift-0.16.0]# thrift -version
Thrift version 0.16.0

```

