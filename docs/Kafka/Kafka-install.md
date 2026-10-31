---
title: Kafka环境搭建
date: 2026-03-09 08:00:00
categories:
- kafka
tags:
- Kafka环境搭建
---



分布式消息**队列**。

## 集群规划

|node1|node2|node3|
|---|---|---|
|zookeeper|zookeeper|zookeeper|
|kafka|kafka|kafka|

## 集群部署
### 	官方下载地址

​	http://kafka.apache.org/downloads.html

### 	解压安装包

```bash
[zhangan@node1 kafka]$ tar -zxvf kafka_2.12-3.0.0.tgz
```

### 	创建软连接

```bash
[zhangan@node1 kafka]$ ln kafka_2.12-3.0.0/ default
```

### 	修改配置文件

```bash
[zhangan@node1 default]$ cd config/
[zhangan@node1 config]$ vim server.properties
```
输入以下内容：
```bash
#broker的全局唯一编号，不能重复，只能是数字。
broker.id=1
log.dirs=/opt/bigdata/kafka/default/data
zookeeper.connect=node1:2181,node2:2181,node3:2181/kafka
advertised.listeners=PLAINTEXT://node1-ip:9092
```

### 分发安装包

分别在node2和node3上修改配置文件`/opt/bigdata/kafka/default/config/server.properties`中的broker.id=2、broker.id=3

> 注：broker.id不得重复，整个集群中唯一。
```bash
[zhangan@node2 default]$ vim config/server.properties
broker.id=2
advertised.listeners=PLAINTEXT://node2-ip:9092

[zhangan@node3 default]$ vim config/server.properties
broker.id=3
advertised.listeners=PLAINTEXT://node3-ip:9092
```

### 配置环境变量

- 在`~/bash_profile`文件中增加kafka环境变量配置

- 刷新环境变量。

- 修改其他节点的环境变量，并source。

### 启动集群

- 先启动Zookeeper集群，然后启动Kafka。

```bash
[zhangan@node1   kafka]$ zk.sh start 
```
- 依次在node1、node2、node3节点上启动Kafka。

```bash
[zhangan@node1 kafka]$ bin/kafka-server-start.sh -daemon config/server.properties
[zhangan@node2 kafka]$ bin/kafka-server-start.sh -daemon config/server.properties
[zhangan@node3 kafka]$ bin/kafka-server-start.sh -daemon config/server.properties
```
> 注意：配置文件的路径要能够到server.properties。

### 关闭集群

```bash
[zhangan@node1 kafka]$ bin/kafka-server-stop.sh 
[zhangan@node2 kafka]$ bin/kafka-server-stop.sh 
[zhangan@node3 kafka]$ bin/kafka-server-stop.sh 
```

### 集群启停脚本
#### 启停脚本

在/home/zhangan/bin目录下创建文件kf.sh脚本文件

```bash
[zhangan@node1 bin]$ vim kf.sh
```
脚本如下：
```bash
#!/bin/bash

case $1 in
"start"){
    for i in node1 node2 node3
    do
        echo " --------启动 $i Kafka-------"
        ssh $i "kafka-server-start.sh -daemon /opt/bigdata/kafka/default/config/server.properties"
    done
};;
"stop"){
    for i in node1 node2 node3
    do
        echo " --------停止 $i Kafka-------"
        ssh $i "kafka-server-stop.sh stop"
    done
};;
esac
```

#### 添加执行权限

略。

#### 启动集群命令

```bash
[zhangan@node1 ~]$ kf.sh start
```

#### 停止集群命令

```bash
[zhangan@node1 ~]$ kf.sh stop
```
> 注意：停止Kafka集群时，一定要等Kafka所有节点进程全部停止后再停止Zookeeper集群。因为Zookeeper集群当中记录着Kafka集群相关信息，Zookeeper集群一旦先停止，Kafka集群就没有办法再获取停止进程的信息，只能手动杀死Kafka进程了。

