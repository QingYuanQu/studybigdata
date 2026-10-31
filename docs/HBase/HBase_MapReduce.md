---
title: HBase与MapReduce
date: 2022-03-23 15:55:26
categories:
- HBase
tags:
- HBase
- MapReduce
---

# HBase与MapReduce

`HBase`可以作为`MapReduce`的输入数据源，也可以作为`MapReduce`的输出目的地，甚至可以在`MapReduce`任务过程中使用`HBase`来共享资源。

```java
(python37) [zhangsan@node0 default]$ bin/hbase mapredcp

SLF4J: Class path contains multiple SLF4J bindings.
SLF4J: Found binding in [jar:file:/opt/bigdata/hbase/hbase-1.4.13/lib/slf4j-log4j12-1.7.25.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/opt/bigdata/hadoop/hadoop-2.7.3/share/hadoop/common/lib/slf4j-log4j12-1.7.10.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
SLF4J: Actual binding is of type [org.slf4j.impl.Log4jLoggerFactory]
/opt/bigdata/hbase/hbase-1.4.13/lib/hbase-hadoop2-compat-1.4.13.jar:/opt/bigdata/hbase/hbase-1.4.13/lib/hbase-metrics-1.4.13.jar:/opt/bigdata/hbase/hbase-1.4.13/lib/zookeeper-3.4.10.jar:/opt/bigdata/hbase/hbase-1.4.13/lib/hbase-shaded-gson-3.0.0.jar:/opt/bigdata/hbase/hbase-1.4.13/lib/hbase-hadoop-compat-1.4.13.jar:/opt/bigdata/hbase/hbase-1.4.13/lib/hbase-prefix-tree-1.4.13.jar:/opt/bigdata/hbase/hbase-1.4.13/lib/hbase-protocol-1.4.13.jar:/opt/bigdata/hbase/hbase-1.4.13/lib/htrace-core-3.1.0-incubating.jar:/opt/bigdata/hbase/hbase-1.4.13/lib/hbase-server-1.4.13.jar:/opt/bigdata/hbase/hbase-1.4.13/lib/hbase-client-1.4.13.jar:/opt/bigdata/hbase/hbase-1.4.13/lib/guava-12.0.1.jar:/opt/bigdata/hbase/hbase-1.4.13/lib/metrics-core-2.2.0.jar:/opt/bigdata/hbase/hbase-1.4.13/lib/protobuf-java-2.5.0.jar:/opt/bigdata/hbase/hbase-1.4.13/lib/hbase-metrics-api-1.4.13.jar:/opt/bigdata/hbase/hbase-1.4.13/lib/netty-all-4.1.8.Final.jar:/opt/bigdata/hbase/hbase-1.4.13/lib/hbase-common-1.4.13.jar
```



##### hadoop-env.sh

```shell
export HBASE_HOME=/opt/bigdata/hbase/default
export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:$HBASE_HOME/lib/*
```



##### 启动Hadoop

##### 启动HBase



```shell
(python37) [zhangsan@node0 default]$ hadoop jar lib/hbase-server-1.4.13.jar 
An example program must be given as the first argument.
Valid program names are:
  CellCounter: Count cells in HBase table. # 统计有多少cell
  WALPlayer: Replay WAL files. 
  completebulkload: Complete a bulk data load. # 将hfile的文件数据加载
  copytable: Export a table from local cluster to peer cluster. # 表在集群中复制
  export: Write table data to HDFS. # 将表导出到HDFS
  exportsnapshot: Export the specific snapshot to a given FileSystem. 
  import: Import data written by Export. 
  importtsv: Import data in TSV format.
  rowcounter: Count rows in HBase table. # 行数统计
  verifyrep: Compare the data from tables in two different clusters. WARNING: It doesn't work for incrementColumnValues'd cells since the timestamp is changed after being appended to the log.
```





```
(python37) [zhangsan@node0 default]$ hadoop jar lib/hbase-server-1.4.13.jar rowcounter Student
```



> https://blog.csdn.net/u014414323/article/details/81170560