---
title: Spark环境搭建（三）Spark On YARN模式
date: 2023-01-15 15:55:26
categories:
- Spark
tags:
- Spark环境搭建
---

<h1 style="color:red; text-align:center;color:red;">Spark环境搭建（三）Spark On YARN模式</h1>

## 伪分布式

#### 配置

`Spark`的`Master`由`YARN`的`ResourceManager`替代，`Worker`由`NodeManager`替代。

##### spark-env.sh

```shell
HADOOP_CONF_DIR=/opt/bigdata/hadoop/default/etc/hadoop
YARN_CONF_DIR=/opt/bigdata/hadoop/default/etc/hadoop
# 日志服务器HistoryServer配置
SPARK_HISTORY_OPTS="-Dspark.history.fs.logDirectory=hdfs://node0:9000/spark-logs"
```

##### spark-defaults.conf

```shell
[zhangsan@node0 conf]$ vim spark-defaults.conf
spark.master                     yarn

# spark app执行的事件日志会存放到指定的位置
spark.eventLog.enabled           true
spark.eventLog.dir               hdfs://node0:9000/spark-logs
# spark包位置
spark.yarn.archive               hdfs://node0:9000/spark-jars
```

将`spark`的`jar`包上传到`HDFS`

```shell
# 在hdfs上创建目录hdfs:node0:9000/shared/spark-archive
[zhangsan@node0 default]$ hdfs dfs -mkdir /spark-jars

# 将$SPARK_HOME/spark/jars/*.jar上传到hdfs
[zhangsan@node0 default]$ hdfs dfs -put jars/* /spark-jars
```

#### 运行SparkApp

`Spark Application`有两种运行模式，`Client`和`Cluster`。可以通过 `--deploy-mode=client/cluster`来指定。在提交`Application`的时候，可以告诉`YARN`需要的计算资源。

##### Client模式

`Client`模式，`driver`运行在客户端进程中；

**实验**

```shell
[zhangsan@node1 default]$ bin/spark-shell --master yarn --deploy-mode client 
```



##### Cluster模式

`Cluster`模式，`driver`运行在`YARN`容器中`ApplicationMaster`。

### Mesos

略。



## 集群模式

如要继续如下步骤，请完成[`Hadoop`全分布式环境]()的搭建。

集群规划

|       | Hadoop                                          | spark                               |
| ----- | ----------------------------------------------- | ----------------------------------- |
| node1 | `NameNode`, `SecondNameNode`, `ResourceManager` | `Master`, `Worker`, `HistoryServer` |
| node2 | `DataNode`, `NodeManager`                       | `Worker`                            |
| node3 | `DataNode`,` NodeManager`                       | `Worker`                            |



`Spark On YARN`， 只需要在一个节点上部署`Spark`，`Spark`的`Master`由`YARN`的`ResourceManager`替代，`Worker`由`NodeManager`替代。

##### spark-env.sh

##### spark-defaults.conf

与`伪分布式-YARN`配置基本一致，不同的是，此处我们的`Namenode`运行在`node1`节点上，因此需要修改一下`node0`为`node1`，
