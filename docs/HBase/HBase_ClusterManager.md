---
title: HBase集群管理
date: 2022-03-23 15:55:26
categories:
- HBase
tags:
- HBase

---

# HBase集群管理

## 新增Hadoop节点

##### Master

- `slaves`新增`node4`
- 配置分发( hosts, slaves )

##### node4

启动DataNode和NodeManager

```shell
[zhangsan@node4 default]$ sbin/hadoop-daemon.sh start datanode
[zhangsan@node4 default]$ sbin/yarn-daemon.sh start nodemanager
```



##### 刷新节点状态

```shell
[zhangsan@node1 ~]$ hdfs dfsadmin -refreshNodes
```



##### 负载均衡

```shell
# 设置负载均衡带宽
[zhangsan@node1 ~]$ hdfs dfsadmin -setBalancerBandwidth bytes
# 磁盘使用率阈值，单位为百分比。此命令会产生一个进程，并在logs目录输出日志；负载均衡完毕，进程结束。
# -threshold
# 默认值:10%。该值确保每个DataNode上的磁盘使用率与集群整体使用率的差距不超过10%。
[zhangsan@node1 ~]$ start-balancer.sh -threshold 1
```

> https://partners-intl.aliyun.com/help/en/e-mapreduce/latest/hdfs-balancer



## 移除Hadoop节点

##### Master配置排除节点列表

`hdfs-site.xml`

```xml
<property>
    <name>dfs.hosts.exclude</name>
    <value>/opt/bigdata/hadoop/hadoop-2.7.3/etc/hadoop/datanode-excludes</value>
</property>
```

datanode-excludes (一行一个)

```
node4
```

`yarn-site.xml`

```xml
<property>
    <name>yarn.hosts.exclude</name>
    <value>/opt/bigdata/hadoop/hadoop-2.7.3/etc/hadoop/nodemanager-excludes</value>
</property>
```

nodemanager-excludes (一行一个)

```shell
node4
```

##### 刷新节点状态

`Decommission In Progress --> Decommissioned`

```shell
[zhangsan@node1 hadoop]$ hdfs dfsadmin -refreshNodes
[zhangsan@node1 hadoop]$ yarn rmadmin -refreshNodes
```

##### 停止守护进程

```shell
[zhangsan@node4 ~]$ hadoop-daemon.sh stop datanode
[zhangsan@node4 ~]$ yarn-daemon.sh stop nodemanager
```

##### 查看下线情况

```shell
[zhangsan@node1 ~]$ hdfs dfsadmin -report
[zhangsan@node1 ~]$ yarn node -list
```

## 新增RegionServer

##### Master

修改`conf/regionserver`，并分发配置。

##### node4

`hbase-deamon.sh start`

##### 负载均衡

```shell
# Enable/Disable balancer. Returns previous balancer state.
hbase(main):003:0> balance_switch true
true 
# 负载均衡
hbase(main):004:0> balancer
true   
```



## 移除RegionServer

##### hbase-daemon.sh stop regionserver

由`HMaster`分配停止节点的`Region`

##### graceful_stop node4

被停止节点主动转移`Region`。