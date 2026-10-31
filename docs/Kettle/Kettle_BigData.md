---
title: Kettle - Kettle连接Hadoop
date: 2022-03-23 15:55:26
categories:
- Kettle
---



## Kettle连接Hadoop

##### Linux软件包

```shell
yum -y install redhat-lsb
```

##### hdfs-site.xml

```xml
<property>
  <name>dfs.permissions.enabled</name>
  <value>false</value>
</property>
```

##### 复制Hadoop配置文件到Kettle

- core-site.xml

- hdfs-site.xml

- yarn-site.xml

- mapred-site.xml

```shell
data-integration\plugins\pentaho-big-data-plugin\hadoop-configurations\cdh61
```

##### 主对象树中配置HadoopCluster

![image-20221213075351415](img/Kettle_BigData/image-20221213075351415.png)

## 复制文件到HDFS

##### Local到HDFS

![image-20221213075538074](img/Kettle_BigData/image-20221213075538074.png)

![image-20221213075203144](img/Kettle_BigData/image-20221213075203144.png)

## MapReduce

### MapReduce Mapper

![image-20221213082122602](img/Kettle_BigData/image-20221213082122602.png)

![image-20221213082202102](img/Kettle_BigData/image-20221213082202102.png)

![image-20221213082227629](img/Kettle_BigData/image-20221213082227629.png)

![image-20221213082250529](img/Kettle_BigData/image-20221213082250529.png)

![image-20221213082310633](img/Kettle_BigData/image-20221213082310633.png)

### MapReduce Reduce

![image-20221213082430515](img/Kettle_BigData/image-20221213082430515.png)

![image-20221213082331351](img/Kettle_BigData/image-20221213082331351.png)

![image-20221213082354984](img/Kettle_BigData/image-20221213082354984.png)

![image-20221213082415349](img/Kettle_BigData/image-20221213082415349.png)

### MapReduce

![image-20221213082505541](img/Kettle_BigData/image-20221213082505541.png)

![image-20221213082528100](img/Kettle_BigData/image-20221213082528100.png)

![image-20221213082544704](img/Kettle_BigData/image-20221213082544704.png)

![image-20221213082603211](img/Kettle_BigData/image-20221213082603211.png)



