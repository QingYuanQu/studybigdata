---
theme: python-mini-pptx
paginate: true
headingDivider: 5
title: Hadoop HDFS 原理与命令实战
date: 2022-01-15 15:55:26
categories:
- Hadoop
keywords:
- Hadoop
- HDFS
- HDFS 原理
- HDFS Shell
- HDFS 命令
- Hadoop 3.1.3
---

# HDFS文件系统用户基本操作

## 用户与权限

HDFS 身份来自操作系统，管理员通过 `supergroup` 与扩展属性精细控制访问。

### 超级用户与用户身份

- 谁启动 NameNode，谁就是 HDFS 的 **超级用户（super-user）**。
- 客户端进程在 HDFS 上的身份由主机操作系统决定；类 Unix 系统上即 `whoami` 的结果。

参考：https://hadoop.apache.org/docs/r3.1.3/hadoop-project-dist/hadoop-hdfs/HdfsPermissionsGuide.html

## HDFS 用户命令

HDFS 命令分用户命令、管理员命令、调试命令三类。用户命令面向日常文件操作，是最高频的一组。

参考：https://hadoop.apache.org/docs/r3.1.3/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html

## 通过WebUI管理文件

hdfs-site.xml

```xml
<property>
    <name>hadoop.http.staticuser.user</name>
    <value>zhangsan</value>
</property>
```

> 增加配置项后，重启HDFS

## 通过命令管理文件

### 基础命令

`hdfs dfs [options]` 在 Hadoop 支持的文件系统上执行命令，等价于早期的 `hadoop fs`。

| 作用             | 命令                                                         |
| ---------------- | ------------------------------------------------------------ |
| 本地 →HDFS       | `-put [-f] [-p] [-l] <localsrc> ... <dst>`                   |
| 本地 →HDFS       | `-copyFromLocal [-f] [-p] [-l] <localsrc> ... <dst>`         |
| 本地 →HDFS(搬移) | `-moveFromLocal <localsrc> ... <dst>`                        |
| HDFS→ 本地       | `-get [-p] [-ignoreCrc] [-crc] <src> ... <localdst>`         |
| HDFS→ 本地       | `-copyToLocal [-p] [-ignoreCrc] [-crc] <src> ... <localdst>` |
| 追加             | `-appendToFile <localsrc> ... <dst>`                         |
| 合并下载         | `-getmerge [-nl] <src> <localdst>`                           |

### 文件管理

| 作用        | 命令                                            |
| ----------- | ----------------------------------------------- |
| 建目录      | `-mkdir [-p] <path> ...`                        |
| 列举        | `-ls [-d] [-h] [-R] [<path> ...]`               |
| 建空文件    | `-touchz <path> ...`                            |
| 查看内容    | `-cat [-ignoreCrc] <src> ...`                   |
| 尾部跟踪    | `-tail [-f] <file>`                             |
| 复制        | `-cp [-f] [-p] <src> ... <dst>`                 |
| 移动/重命名 | `-mv <src> ... <dst>`                           |
| 删除        | `-rm [-f] [-r\|-R] [-skipTrash] <src> ...`      |
| 删空目录    | `-rmdir [--ignore-fail-on-non-empty] <dir> ...` |
| 统计计数    | `-count [-q] [-h] <path> ...`                   |



### 实操示例

#### 准备数据

##### 启动HDFS

使用用户`zhangsan`启动`HDFS`（张三用户已配置免密登录）；

使用用户`root`执行后续操作。

##### 配置全局环境变量

```shell
[root@node0 ~]# vim /etc/profile
export HADOOP_HOME=/opt/bigdata/hadoop/default
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin/:$PATH
```

##### Linux本地创建三个文件

```shell
[root@node1 ~]# echo "hello hadoop" > file_hadoop
[root@node1 ~]# echo "hello hbase" > file_to_append
[root@node1 ~]# echo "hello spark" > file_to_move
```

#### 创建目录

##### 在`HDFS`上创建目录`/input`

```bash
[root@node0 zhangsan]# hdfs dfs -mkdir /input
mkdir: Permission denied: user=root, access=WRITE, inode="/":zhangsan:supergroup:drwxr-xr-x
```

##### 把`root`用户加入`supergroup`

如果创建失败,（把`root`用户加入`supergroup`）

```shell
[root@node0 ~]# groupadd supergroup
You have new mail in /var/spool/mail/root

[root@node0 ~]# gpasswd -a root supergroup
Adding user root to group supergroup

# 同步系统的权限信息到HDFS
[root@node0 ~]# hdfs dfsadmin -refreshUserToGroupsMappings
Refresh user to groups mapping successful
```

##### 创建目录

创建文件夹 `hdfs:///input/`

```shell
[root@node1 ~]# hdfs dfs -mkdir /input
```

创建文件夹`hdfs:///user/root/`

```shell
[root@node1 ~]# hdfs dfs -mkdir /user/root
```

#### Linux与HDFS交互

##### 上传文件

上传文件 `file_hadoop`到`hdfs:///input/`

```shell
[root@node1 ~]# hdfs dfs -put file_hadoop /input
```

##### 创建空白文件

创建空白文件`hdfs:///input/file_hbase`

```shell
[root@node1 ~]# hdfs dfs -touchz /input/file_hbase
```

##### 内容追加

将本地文件 `file_to_append` 的内容追加到 `hdfs:///input/file_hbase`

```shell
[root@node1 ~]# hdfs dfs -appendToFile file_to_append /input/file_hbase
```

##### 内容查看

查看HDFS中 `hdfs:///input/file_hbase` 文件内容

```shell
[root@node1 ~]# hdfs dfs -cat /input/file_hbase
hello hbase
```

##### 本地移动到HDFS

 将本地文件 `file_to_move` 移动到 `hdfs:///input/`

```shell
[root@node1 ~]# hdfs dfs -moveFromLocal file_to_move /input/
```

> 可以看到本地Linux文件系统中文件已经消失

#### HDFS文件管理

##### 文件重命名

将 `hdfs:///input/file_to_move` 重命名为 `hdfs:///input/file_spark`

```shell
[root@node1 ~]# hdfs dfs -mv /input/file_to_move /input/file_spark
```

将文件夹  `hdfs:///input/` 重命名为  `hdfs:///data/` 

```shell
[root@node1 ~]# hdfs dfs -mv /input /data
```

##### 目录复制

将目录`hdfs:///data/` 复制到 `hdfs:///user/root/`下

```shell
[root@node1 ~]# hdfs dfs -cp /data/ /user/root/
```

##### 文件列表

查看`hdfs:///user/root/data`下的文件的详细信息（创建修改时间，所有者，权限）

```shell
[root@node1 ~]# hdfs dfs -ls /user/root/data
Found 3 items
-rw-r--r--   3 root supergroup         13 2022-10-01 20:48 /user/root/data/file_hadoop
-rw-r--r--   3 root supergroup         12 2022-10-01 20:48 /user/root/data/file_hbase
-rw-r--r--   3 root supergroup         12 2022-10-01 20:48 /user/root/data/file_spark
```

##### 合并下载

将hdfs`file_hadoop`, `file_hbase`, `file_spark`下载到本地` file_merge.txt`。

```shell
[root@node1 ~]# hdfs dfs -getmerge /user/root/data/* ~/file_merge.txt
You have new mail in /var/spool/mail/root
[root@node1 ~]# cat file_merge.txt 
hello hadoop
hello hbase
hello spark
```

将hdfs`file_hadoop`, `file_hbase`, `file_spark`下载到本地` file_merge.txt`，以换行符分割。

```bash
[root@node1 ~]# hdfs dfs -getmerge -nl /user/root/data/* ~/file_merge.txt
You have new mail in /var/spool/mail/root
[root@node1 ~]# cat file_merge.txt 
hello hadoop

hello hbase

hello spark
```

##### 统计

统计`hdfs:///user/root/data`内文件数量和总大小

```shell
[root@node1 ~]# hdfs dfs -count /user/root/data/
2            			3                 37 		/user/root/data
目录数(包括当前目录.)	 文件数			文件总大小	 统计的目录名
```

##### 删除

删除`hdfs:///data/`下的所有文件

```shell
# TODO
[root@node1 ~]# hdfs dfs -rm /data
```

