---
title: Hadoop NameNode HA
date: 2022-03-23 15:55:26
categories:
- Hadoop
tags:
- Hadoop
- 环境搭建
- NameNode HA
---

<div class="cover"><h1>Hadoop 部署（四）NameNode HA</h1><p>High Availability：用 JournalNode + ZooKeeper 消灭 NameNode 单点，一台挂了自动切另一台</p></div>

# Hadoop 环境部署 - NameNode HA

> **系列位置**：本篇是 Hadoop 环境部署系列的第四步（[架构导论](/Hadoop/00-Hadoop_Overview_Architecture) → [Linux 配置](/Hadoop/01-Hadoop_Environment_Setup_Linux_config) → [单机](/Hadoop/02-Hadoop_Environment_Setup_SingleNode) → [伪分布式](/Hadoop/03-Hadoop_Environment_Setup_Distributed_Pseudo) → [完全分布式](/Hadoop/04-Hadoop_Environment_Setup_Distributed_Fully) → **本篇** → [Windows](/Hadoop/06-Hadoop_Environment_Setup_Windows)）。在 04 篇完全分布式的基础上，给 NameNode 做主备。
>
> **预备知识**：HA 的自动故障转移依赖 SSH 免密（`sshfence` 要登另一台 NN 强杀旧 active），原理与排错见 [SSH 免密登录](/Hadoop/SSH_免密登录)；端口、角色规划沿用 04 篇统一约定。

> **前置假设**：本篇假设 ZooKeeper 已在 `node1 / node2 / node3` 部署并启动（默认端口 `2181`），ZK 自身安装不在本篇范围；Hadoop 版本 `3.1.3`，用户 `zhangsan`，`$HADOOP_HOME=/opt/bigdata/hadoop/default`。本篇只做 **NameNode HA（HDFS 高可用）**，ResourceManager HA 思路类似，可类比扩展。

## NameNode HA

### 修改配置文件

##### core-site.xml

```xml
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://hdfscluster</value>
    </property>
    
    <property> 
        <name>dfs.journalnode.edits.dir</name>
        <value>/opt/bigdata/hadoop/default/tmp/jn</value>
    </property>

    <property>
        <name>ha.zookeeper.quorum</name>
        <value>node1:2181,node2:2181,node3:2181</value>
    </property>
```



##### hdfs-site.xml

```xml
<configuration>

    <!-- 完全分布式集群名称 -->
    <property>
        <name>dfs.nameservices</name>
        <value>hdfscluster</value>
    </property>
    <!-- 集群中 NameNode 节点都有哪些 -->
    <property>
        <name>dfs.ha.namenodes.hdfscluster</name>
        <value>nn1,nn2</value>
    </property>
    <!-- nn1 的 RPC 通信地址 -->
    <property>
        <name>dfs.namenode.rpc-address.hdfscluster.nn1</name>
        <value>node1:9000</value>  <!-- NameNode RPC 端口，Apache 默认 9000（若与 04 篇的 8020 混用须统一） -->
    </property>
    <!-- nn2 的 RPC 通信地址 -->
    <property>
        <name>dfs.namenode.rpc-address.hdfscluster.nn2</name>
        <value>node3:9000</value>
    </property>
    <!-- nn1 的 http 通信地址 -->
    <property>
        <name>dfs.namenode.http-address.hdfscluster.nn1</name>
        <value>node1:9870</value>  <!-- Hadoop 3.x NameNode Web UI 端口（2.x 旧端口是 50070） -->
    </property>
    <!-- nn2 的 http 通信地址 -->
    <property>
        <name>dfs.namenode.http-address.hdfscluster.nn2</name>
        <value>node3:9870</value>  <!-- Hadoop 3.x NameNode Web UI 端口（2.x 旧端口是 50070） -->
    </property>
    <!-- 指定 NameNode 元数据在 JournalNode 上的存放位置 -->
    <property>
        <name>dfs.namenode.shared.edits.dir</name>
        <value>qjournal://node1:8485;node2:8485;node3:8485/hdfscluster</value>
    </property>
    <!-- 配置隔离机制，即同一时刻只能有一台服务器对外响应 -->
    <property>
        <name>dfs.ha.fencing.methods</name>
        <value>sshfence</value>
    </property>
    <!-- 使用隔离机制时需要 node1↔node3 双向 ssh 免密，原理与排错见 /Hadoop/SSH_免密登录 -->
    <property>
        <name>dfs.ha.fencing.ssh.private-key-files</name>
        <value>/home/zhangsan/.ssh/id_rsa</value>
    </property>
    <!-- 关闭权限检查-->
    <!-- 
	<property>
        <name>dfs.permissions.enable</name>
        <value>false</value>
    </property>
	-->
    <!-- 访问代理类：client，mycluster，active 配置失败自动切换实现方式-->
    <property>
        <name>dfs.client.failover.proxy.provider.hdfscluster</name>
<value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
    </property>

    <!-- 开启自动故障转移 -->
    <property>
        <name>dfs.ha.automatic-failover.enabled</name>
        <value>true</value>
    </property>
</configuration>
```



### 清除历史脏数据

若本环境是从 04 篇的完全分布式升级而来，先清掉各节点的 `$HADOOP_HOME/tmp`、`$HADOOP_HOME/logs`，以及 ZooKeeper 的 `dataDir`（否则会出现 namespaceID / clusterID 不一致导致 NameNode 起不来）。全新环境可跳过。



### 安装psmisc

```shell
[root@node3 ~]# yum install psmisc
```



### 启动Journal Node

注意：此处用的是 `hadoop-daemons.sh`（**带 s**），它和 `hadoop-daemon.sh`（单数）的区别是：

- `hadoop-daemon.sh`：**只在当前节点**起一个进程（如 `start namenode`）；
- `hadoop-daemons.sh`：通过 ssh **在所有 workers 节点**起同名进程（如 `start journalnode` / `start datanode`）。

所以 JournalNode / DataNode 用复数版，在一个节点上敲就能全集群起；NameNode 要分别在每个 NN 节点上用单数版单独起。

```shell
[zhangsan@node1 default]$ hadoop-daemons.sh start journalnode
```

#### 查看启动情况

##### node1

```shell
[zhangsan@node1 default]$ jps
44583 Jps
44025 JournalNode
87531 QuorumPeerMain
```

##### node2

```shell
[zhangsan@node2 default]$ jps
100709 JournalNode
101577 Jps
31691 QuorumPeerMain
```

##### node3

```shell
[zhangsan@node3 default]$ jps
98851 Jps
97967 JournalNode
29023 QuorumPeerMain
```



### 格式化启动NN1

注意：此处使用的是`hadoop-daemon.sh` !

```shell
[zhangsan@node1 default]$ hdfs namenode -format
[zhangsan@node1 default]$ hadoop-daemon.sh start namenode
```

##### 查看启动情况

```shell
[zhangsan@node1 default]$ jps
44583 Jps
44025 JournalNode
87531 QuorumPeerMain
44463 NameNode
```



### 同步启动NN2

注意：我们使用`node3`作为`namenode2`，所以是在`node3`上将`nn2`与`nn1`同步的。

```shell
[zhangsan@node3 default]$ hdfs namenode -bootstrapStandby
[zhangsan@node3 default]$ hadoop-daemon.sh start namenode
```

##### 查看启动情况

```shell
[zhangsan@node3 default]$ jps
98771 NameNode
98851 Jps
97967 JournalNode
29023 QuorumPeerMain
```



### 启动DataNode

```shell
[zhangsan@node1 default]$ hadoop-daemons.sh start datanode
```

成功后，可以看到三个节点都启动了`DataNode`进程。



### 初始化ZK

在`ZooKeeper`中，初始化 `Namenode HA`状态

```shell
[zhangsan@node1 default]$ hdfs zkfc -formatZK
[zhangsan@node1 logs]$ start-dfs.sh 
```



### 停止HDFS

```shell
[zhangsan@node1 hadoop]$ stop-dfs.sh 
Stopping namenodes on [node1 node3]
node1: stopping namenode
node3: stopping namenode
node1: stopping datanode
node3: stopping datanode
node2: stopping datanode
Stopping journal nodes [node1 node2 node3]
node3: stopping journalnode
node1: stopping journalnode
node2: stopping journalnode
Stopping ZK Failover Controllers on NN hosts [node1 node3]
node1: stopping zkfc
node3: stopping zkfc
```



### 启动HDFS

```shell
[zhangsan@node1 default]$ start-dfs.sh 
Starting namenodes on [node1 node3]
node1: starting namenode, logging to /opt/bigdata/hadoop/hadoop-3.1.3/logs/hadoop-zhangsan-namenode-node1.out
node3: starting namenode, logging to /opt/bigdata/hadoop/hadoop-3.1.3/logs/hadoop-zhangsan-namenode-node3.out
node1: starting datanode, logging to /opt/bigdata/hadoop/hadoop-3.1.3/logs/hadoop-zhangsan-datanode-node1.out
node3: starting datanode, logging to /opt/bigdata/hadoop/hadoop-3.1.3/logs/hadoop-zhangsan-datanode-node3.out
node2: starting datanode, logging to /opt/bigdata/hadoop/hadoop-3.1.3/logs/hadoop-zhangsan-datanode-node2.out
Starting journal nodes [node1 node2 node3]
node3: starting journalnode, logging to /opt/bigdata/hadoop/hadoop-3.1.3/logs/hadoop-zhangsan-journalnode-node3.out
node2: starting journalnode, logging to /opt/bigdata/hadoop/hadoop-3.1.3/logs/hadoop-zhangsan-journalnode-node2.out
node1: starting journalnode, logging to /opt/bigdata/hadoop/hadoop-3.1.3/logs/hadoop-zhangsan-journalnode-node1.out
Starting ZK Failover Controllers on NN hosts [node1 node3]
node1: starting zkfc, logging to /opt/bigdata/hadoop/hadoop-3.1.3/logs/hadoop-zhangsan-zkfc-node1.out
node3: starting zkfc, logging to /opt/bigdata/hadoop/hadoop-3.1.3/logs/hadoop-zhangsan-zkfc-node3.out
```



### 验证 HA 状态

确认两个 NameNode 一主一备，并模拟一次自动故障转移：

```shell
# 查看 nn1 / nn2 当前角色
[zhangsan@node1 default]$ hdfs haadmin -getServiceState nn1
active
[zhangsan@node1 default]$ hdfs haadmin -getServiceState nn2
standby

# 浏览器核对：http://node1:9870 与 http://node3:9870 分别标出 active / standby
# （NameNode Web UI 是 3.x 的 9870，不是 2.x 的 50070；RPC 端口见上面 dfs.namenode.rpc-address 配的 9000）
```

模拟故障转移——强杀 active 的 NN，观察 ZKFC 是否把 standby 提升为 active：

```shell
[zhangsan@node1 default]$ kill -9 $(jps | grep NameNode | awk '{print $1}')
# 等几秒，nn2 应自动变为 active
[zhangsan@node1 default]$ hdfs haadmin -getServiceState nn2
active
```

> 验证要点：active / standby 角色正确、`hdfs haadmin -failover` 能手动切换、杀掉 active 后 standby 自动接管。三步都过，HA 才算真正生效。

### 之后启停方式

````shell
[zhangsan@node1 default]$ start-dfs.sh 
[zhangsan@node1 default]$ stop-dfs.sh 
````

