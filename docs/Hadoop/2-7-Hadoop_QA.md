---
title: Hadoop QA
date: 2022-03-23 15:55:26
tags: 
categories:
- QA

---

# Hadoop QA

## Container is running beyond virtual memory limits

### Q

```shell
Application application_1645498549388_0001 failed 2 times due to AM Container for appattempt_1645498549388_0001_000002 `exited with exitCode: -103`
For more detailed output, check application tracking page:http://node1:8088/cluster/app/application_1645498549388_0001Then, click on links to logs of each attempt.
`Diagnostics: Container [pid=2316,containerID=container_1645498549388_0001_02_000001] is running beyond virtual memory limits. Current usage: 100.0 MB of 1 GB physical memory used; 2.2 GB of 2.1 GB virtual memory used. Killing container.`
Dump of the process-tree for container_1645498549388_0001_02_000001 :
|- PID PPID PGRPID SESSID CMD_NAME USER_MODE_TIME(MILLIS) SYSTEM_TIME(MILLIS) VMEM_USAGE(BYTES) RSSMEM_USAGE(PAGES) FULL_CMD_LINE
|- 2316 2314 2316 2316 (bash) 1 1 116006912 300 /bin/bash -c /usr/java/default/bin/java -server -Xmx512m -Djava.io.tmpdir=/opt/bigdata/hadoop/default/tmp/nm-local-dir/usercache/hadoop/appcache/application_1645498549388_0001/container_1645498549388_0001_02_000001/tmp -Dspark.yarn.app.container.log.dir=/opt/bigdata/hadoop/hadoop-2.7.3/logs/userlogs/application_1645498549388_0001/container_1645498549388_0001_02_000001 org.apache.spark.deploy.yarn.ExecutorLauncher --arg 'node1:44636' --properties-file /opt/bigdata/hadoop/default/tmp/nm-local-dir/usercache/hadoop/appcache/application_1645498549388_0001/container_1645498549388_0001_02_000001/__spark_conf__/__spark_conf__.properties --dist-cache-conf /opt/bigdata/hadoop/default/tmp/nm-local-dir/usercache/hadoop/appcache/application_1645498549388_0001/container_1645498549388_0001_02_000001/__spark_conf__/__spark_dist_cache__.properties 1> /opt/bigdata/hadoop/hadoop-2.7.3/logs/userlogs/application_1645498549388_0001/container_1645498549388_0001_02_000001/stdout 2> /opt/bigdata/hadoop/hadoop-2.7.3/logs/userlogs/application_1645498549388_0001/container_1645498549388_0001_02_000001/stderr
|- 2323 2316 2316 2316 (java) 242 111 2250498048 25294 /usr/java/default/bin/java -server -Xmx512m -Djava.io.tmpdir=/opt/bigdata/hadoop/default/tmp/nm-local-dir/usercache/hadoop/appcache/application_1645498549388_0001/container_1645498549388_0001_02_000001/tmp -Dspark.yarn.app.container.log.dir=/opt/bigdata/hadoop/hadoop-2.7.3/logs/userlogs/application_1645498549388_0001/container_1645498549388_0001_02_000001 org.apache.spark.deploy.yarn.ExecutorLauncher --arg node1:44636 --properties-file /opt/bigdata/hadoop/default/tmp/nm-local-dir/usercache/hadoop/appcache/application_1645498549388_0001/container_1645498549388_0001_02_000001/__spark_conf__/__spark_conf__.properties --dist-cache-conf /opt/bigdata/hadoop/default/tmp/nm-local-dir/usercache/hadoop/appcache/application_1645498549388_0001/container_1645498549388_0001_02_000001/__spark_conf__/__spark_dist_cache__.properties
Container killed on request. Exit code is 143
`Container exited with a non-zero exit code 143`
Failing this attempt. Failing the application.
```

### A

##### yarn-site.xml

追加

```xml
    <property>
            <name>yarn.nodemanager.pmem-check-enabled</name>
            <value>false</value>
    </property>

    <property>
            <name>yarn.nodemanager.vmem-check-enabled</name>
            <value>false</value>
    </property>

    <property>
            <name>yarn.nodemanager.vmem-pmem-ratio</name>
            <value>4</value>
    </property>
```

##### 属性说明

| property                              | default | description                                                  |
| ------------------------------------- | ------- | ------------------------------------------------------------ |
| `yarn.nodemanager.pmem-check-enabled` | `true`  | Whether physical memory limits will be enforced for containers. |
| `yarn.nodemanager.vmem-check-enabled` | `true`  | Whether virtual memory limits will be enforced for containers. |
| `yarn.nodemanager.vmem-pmem-ratio`    | 2.1     | Ratio between virtual memory to physical memory `when setting memory limits for containers`. Container allocations are expressed in terms of physical memory, and virtual memory usage is allowed to exceed this allocation by this ratio. |

## Incompatible clusterIDs

### Q

此时`DataNode`无法启动，`$HADOOP_HOME/logs/`日志中出现如下错误：

```shell
java.io.IOException: Incompatible clusterIDs in /opt/bigdata/hadoop/hadoop-2.7.3/tmp/dfs/data: namenode clusterID = CID-ab1341d3-2985-4733-9938-7d207ab1f9f3
de6; datanode clusterID = CID-7ba8e9f1-4917-433e-86be-db2044809204
```

出现这种问题的原因是，你多次对`NameNode`进行了格式化。每次对`NameNode`格式化，`NameNode`都会产生一个新的`clusterID`：

```shell
(python37) [zhangsan@node0 ~]$ cat /opt/bigdata/hadoop/default/tmp/dfs/name/current/VERSION | grep clusterID 
clusterID=CID-ab1341d3-2985-4733-9938-7d207ab1f9f3

(python37) [zhangsan@node0 ~]$ cat /opt/bigdata/hadoop/default/tmp/dfs/data/current/VERSION | grep clusterID
clusterID=CID-7ba8e9f1-4917-433e-86be-db2044809204

(python37) [zhangsan@node0 ~]$ cat /opt/bigdata/hadoop/default/tmp/dfs/namesecondary/current/VERSION | grep clusterID
clusterID=CID-7ba8e9f1-4917-433e-86be-db2044809204
```

### A

你会看到他们的`clusterID`不一致，修改一致即可，记得修改完重启`HDFS`。

> **`ClusterID`**
>
> A `ClusterID identifier` is used to identify `all the nodes in the cluster`. When a `Namenode is formatted`, this identifier is either provided or `auto generated`. This ID should be used for formatting `the other Namenodes into the cluster`.
>
> <https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/Federation.html>

---



### Q

```shell
Permission denied: user=dr.who, access=READ_EXECUTE, inode="/user":zhangsan:supergroup:drwx-wx-wx
```

### A

core-site.xml

```xml
    <property>
        <name>hadoop.http.staticuser.user</name>
        <value>zhangsan</value>
    </property>
```
