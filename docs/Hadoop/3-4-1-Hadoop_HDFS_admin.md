---
theme: python-mini-pptx
paginate: true
headingDivider: 5
title: Hadoop HDFS 原理与命令实战
subtitle: 状态查看·安全模式·快照·配额
date: 2022-01-15 15:55:26
categories:
- Hadoop
keywords: Hadoop,HDFS
---



## 管理员命令

管理员命令负责集群级运维：状态查看、安全模式、快照、配额。它们通常需要管理员/超级用户权限。准备测试文件

```bash
[zhangsan@node0 ~]$ hdfs dfs -touchz /user/zhangsan/bigdata.txt
```

## 查看网络拓扑

副本放置与距离计算都依赖集群拓扑，`dfsadmin -printTopology` 直接打印实际机架结构。

```bash
[zhangsan@node0 ~]$ hdfs dfsadmin -printTopology
#Rack: /default-rack
#    192.168.179.101:50010 (node1)
#    192.168.179.102:50010 (node2)
#    192.168.179.103:50010 (node3)
```

## 集群基本信息

`hdfs dfsadmin -report` 汇总集群容量、各 DataNode 负载与块健康，是日常巡检第一命令。

```bash
[zhangsan@node0 ~]$ hdfs dfsadmin -report
```

> https://hadoop.apache.org/docs/r3.1.3/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#Administration_Commands

#### 三个容量数字

**Configured Capacity** 是配置的磁盘总空间（26.46 GB，含非 HDFS 使用的部分）；

**Present Capacity** 是 DataNode 实际能用的；

**DFS Remaining** 是 HDFS 还剩多少。



## 安全模式

安全模式下 HDFS 只接收 **读** 请求，**拒绝修改/删除**，常用于维护或异常恢复。

```shell
[zhangsan@node0 ~]$ hdfs dfsadmin -safemode <enter | leave | get | wait>
#   enter   进入安全模式
#   leave   强制退出安全模式
#   get     查看当前状态
#   wait    等待退出安全模式
```

#### 触发阈值配置（对应 `hdfs-site.xml`）：

| property                              | default  | comment                            |
| ------------------------------------- | -------- | ---------------------------------- |
| `dfs.namenode.safemode.threshold-pct` | `0.999f` | 默认副本率 = 实际副本数/设置副本数 |
| `dfs.namenode.safemode.min.datanodes` | `0`      | 最少可用 DataNode 数               |
| `dfs.namenode.safemode.extension`     | `30000`  | 离开安全模式的延迟（毫秒）         |

#### 	安全模式使用示例

查询安全模式

```bash
[zhangsan@node0 ~]$ hdfs dfsadmin -safemode get
```

进入安全模式

```bash
[zhangsan@node0 ~]$ hdfs dfsadmin -safemode enter
```

删除测试文件

```bash
[zhangsan@node0 ~]$ hdfs dfs -rm /user/zhangsan/bigdata.txt
```

退出安全模式

```bash
[zhangsan@node0 ~]$ hdfs dfsadmin -safemode leave
```

关键点：安全模式期间的删除请求被 **直接拒绝而非排队执行**，退出后文件完好无损、大小不变。所以维护操作时可以放心 `enter`，它是一道 "只读保险"，不会积压破坏性操作。



## 快照

HDFS 快照是文件系统的 **只读时间点副本**，用于备份、防误删、灾难恢复。可快照目录不允许嵌套。

| 命令                                          | 作用                                           | 权限/前置说明                              |
| --------------------------------------------- | ---------------------------------------------- | ------------------------------------------ |
| `hdfs dfsadmin -allowSnapshot <path>`         | 将目录设为允许快照（snapshottable）            | 需管理员权限；设置后方可创建快照           |
| `hdfs dfs -createSnapshot <path> [<name>]`    | 创建快照；不指定 `name` 时自动生成时间戳名称   | 需目录 owner 权限                          |
| `hdfs dfs -renameSnapshot <path> <old> <new>` | 重命名快照                                     | 需目录 owner 权限                          |
| `hdfs dfs -deleteSnapshot <path> <name>`      | 删除指定快照                                   | 需目录 owner 权限                          |
| `hdfs dfsadmin -disallowSnapshot <path>`      | 取消目录的快照能力                             | 需管理员权限；**须先删除该目录下所有快照** |
| `hdfs lsSnapshottableDir`                     | 列出当前用户有权限创建快照的所有可快照目录     | —                                          |
| `hdfs snapshotDiff <path> <from> <to>`        | 生成两个快照（或快照与当前状态 `.`）的差异报告 | 需对两个快照内所有文件/目录有读权限        |

符号含义（供差异报告配套说明）：`+` 新建、`-` 删除、`M` 修改、`R` 重命名/移动。

> 参考：https://hadoop.apache.org/docs/r3.1.3/hadoop-project-dist/hadoop-hdfs/HdfsSnapshots.html

#### 快照使用示例

准备测试文件

```bash
[zhangsan@node0 ~]$ hdfs dfs -touchz /user/zhangsan/hdfs.txt	
[zhangsan@node0 ~]$ hdfs dfs -touchz /user/zhangsan/yarn.txt
```

查询文件列表

```bash
[zhangsan@node0 ~]$ hdfs dfs -ls /user/zhangsan/
```

允许 /user/zhangsan 快照并创建		

```bash
[zhangsan@node0 ~]$ hdfs dfsadmin -allowSnapshot /user/zhangsan
```

列出可快照目录

```bash
[zhangsan@node0 ~]$ hdfs lsSnapshottableDir 
```

创建快照

```bash
[zhangsan@node0 ~]$ hdfs dfs -createSnapshot /user/zhangsan snap1
```

模拟误删操作

```bash
[zhangsan@node0 ~]$ hdfs dfs -rm /user/zhangsan/hdfs.txt
[zhangsan@node0 ~]$ hdfs dfs -rm /user/zhangsan/yarn.txt
```

查询文件列表

```bash
[zhangsan@node0 ~]$ hdfs dfs -ls /user/zhangsan/
```

从快照恢复	

```bash
[zhangsan@node0 ~]$ hdfs dfs -cp /user/zhangsan/.snapshot/snap1/hdfs.txt /user/zhangsan/
```

查询文件列表

```bash
[zhangsan@node0 ~]$ hdfs dfs -ls /user/zhangsan/
```

创建快照

```bash
[zhangsan@node0 ~]$ hdfs dfs -createSnapshot /user/zhangsan snap2
```

快照差异报告

```bash
[zhangsan@node0 ~]$ hdfs snapshotDiff /user/zhangsan snap1 snap2    # 差异报告
```

删除快照

```bash
[zhangsan@node0 ~]$ hdfs dfs -deleteSnapshot /user/zhangsan snap1
```

删除快照	

```bash
[zhangsan@node0 ~]$ hdfs dfs -deleteSnapshot /user/zhangsan snap2
```

禁用快照		

```bash
[zhangsan@node0 ~]$ hdfs dfsadmin -disallowSnapshot /user/zhangsan
```



## 配额

配额限制目录可容纳的 **文件/目录数量** 与 **磁盘空间（含副本）**，防止单目录吃满集群。

| 作用          | 命令                             | 说明                   |
| ------------- | -------------------------------- | ---------------------- |
| 数量限额 设置 | `-setQuota <n> <dir>...`         | 最多放 n-1 个文件/目录 |
| 数量限额 清除 | `-clrQuota <dir>...`             | 清除数量配额           |
| 大小限额 设置 | `-setSpaceQuota <Size> <dir>...` | 块的副本计入配额       |
| 大小限额 清除 | `-clrSpaceQuota <dir>...`        | 清除大小配额           |

> 例如一个 1MB 的文件、副本因子为 3，在空间配额里要扣 **3MB**。

参考：https://hadoop.apache.org/docs/r3.1.3/hadoop-project-dist/hadoop-hdfs/HdfsQuotaAdminGuide.html

#### 配额使用示例

创建配额实验目录

```bash
[zhangsan@node0 ~]$ hdfs dfs -mkdir /quota
```

##### 数量配额设置

数量配额：限制为 3

```bash
[zhangsan@node0 ~]$ hdfs dfsadmin -setQuota 3 /quota
```

依次创建文件 a,b

```bash
[zhangsan@node0 ~]$ hdfs dfs -touchz /quota/a
[zhangsan@node0 ~]$ hdfs dfs -touchz /quota/b
```

创建文件c

```bash
[zhangsan@node0 ~]$ hdfs dfs -touchz /quota/c
```

查看实验目录文件列表

```bash
[zhangsan@node0 ~]$ hdfs dfs -ls /quota
```

清除数量配额

```bash
[zhangsan@node0 ~]$ hdfs dfsadmin -clrQuota /quota
```



##### 大小配额设置

大小配额：限制为128M

```bash
[zhangsan@node0 ~]$ hdfs dfsadmin -setSpaceQuota 200m /quota
```

制作实验文件

```bash
[zhangsan@node0 ~]$ dd if=/dev/zero of=~/128mb bs=1M count=128
```

上传到HDFS

```bash
[zhangsan@node0 ~]$ hdfs dfs -put ~/128mb /quota
```

查看实验目录文件列表

```bash
[zhangsan@node0 ~]$ hdfs dfs -ls /quota
```

查询配额

```bash
[zhangsan@node0 ~]$ hdfs dfs -count -q -h /quota
```

>  QUOTA REMAINING_QUOTA SPACE_QUOTA REMAINING_SPACE_QUOTA DIR_COUNT FILE_COUNT CONTENT_SIZE

| 字段 (Field)          | 值 (Value) | 中文说明                                       |
| --------------------- | ---------- | ---------------------------------------------- |
| QUOTA                 | none       | 名称配额（文件/目录数量配额），none 表示未设置 |
| REMAINING_QUOTA       | inf        | 剩余名称配额，inf 表示无限（未受限）           |
| SPACE_QUOTA           | 200 M      | 空间配额（存储容量上限），200 MB               |
| REMAINING_SPACE_QUOTA | 72 M       | 剩余空间配额，还可使用 72 MB                   |
| DIR_COUNT             | 1          | 目录数量                                       |
| FILE_COUNT            | 3          | 文件数量                                       |
| CONTENT_SIZE          | 128 M      | 当前已用内容大小，128 MB                       |
| 路径 (Path)           | /quota     | 该配额信息对应的 HDFS 目录                     |



清除大小配额

```bash
[zhangsan@node0 ~]$ hdfs dfsadmin -clrSpaceQuota /quota
```











