---
marp: true
headingDivider: 6
theme: python-mini-pptx
title: Hadoop环境部署-伪分布式
date: 2023-01-15 15:55:26
categories:
- Hadoop
tags:
- Hadoop
- 环境搭建
---

<div class="cover"><h1>Hadoop 部署（二）伪分布式</h1><p>Pseudo-Distributed Operation：一台机器上跑完整的 HDFS 与 YARN</p></div>

# Hadoop环境部署-伪分布式

沿用统一约定：机器名 `node0`，`IP` 为 `192.168.179.100`，用户 `zhangsan`，`$HADOOP_HOME=/opt/bigdata/hadoop/default`，版本 `3.1.3`。

> **预备知识**：本篇要把 Hadoop 的全部角色在同一台机器上跑起来，涉及 NameNode、DataNode、ResourceManager 等概念。若还不熟悉，建议先读 [Hadoop 架构导论](/Hadoop/00-Hadoop_Overview_Architecture)，尤其是最后一节的角色对照表。

## 目标与定位

先看清伪分布式到底是什么，以及它与单机模式的边界在哪里。

### 什么是伪分布式

伪分布式：HDFS 的 NameNode、DataNode、SecondaryNameNode，以及 YARN 的 ResourceManager、NodeManager

- **全部运行在 node0 这一台机器上**，各自是独立的 JVM 进程，通过网络端口通信。

它是"分布式"，因为进程各自独立、组件之间通过 RPC 走网络通信；
它是"伪"，因为这些进程并没有真正分布到多台机器上去。

### 与单机模式的关键差别

| 对比项 | 单机模式 | 伪分布式 |
| --- | --- | --- |
| 文件系统 | 本地目录 | HDFS，需要先格式化 |
| 计算框架 | 单个 JVM | YARN，作业提交给 ResourceManager |
| 后台进程 | 无 | 5 个守护进程常驻 |
| 配置文件 | 无需修改 | 必须修改 |
| SSH 免密 | 不需要 | 必须配置 |

### 开始前的前置条件

- 已完成 Linux 系统配置篇：用户 `zhangsan` 已创建、`JDK` 已安装、`JAVA_HOME=/usr/java/default`；
- 已完成单机模式安装，`$HADOOP_HOME` 存在且软连接指向 `3.1.3`；
- `/etc/hosts` 中已有 `192.168.179.100 node0` 映射，执行 `ping node0` 能通；
- 后续完全分布式的三台机器是直接克隆本机，因此这一步务必做扎实。

## 免密登录

这是伪分布式最容易被漏掉的前置动作，先讲清"为什么只有一台机器却还要配 SSH"。

> 关于 SSH 免密的原理（非对称加密）、多机互信怎么做、以及配了却还让输密码如何排查，本系列另有独立文档 [SSH 免密登录](/Hadoop/SSH_免密登录) 系统讲解；本节约其要，先把伪分布式"自己免自己"这一步跑通。

### 为什么伪分布式也要配 SSH 免密

`start-dfs.sh` 并不是在本地 `fork` 出进程，它的工作机制是：

1. 读取 `workers` 文件（Hadoop 2.x 中叫 `slaves`）里列出的主机清单；
2. **通过 ssh 逐台登录**这些主机；
3. 在远端执行启动命令，拉起对应的守护进程。

伪分布式时 `workers` 里只有 `node0` 自己，**但登录本机的 ssh 同样需要密码**，所以必须先把本机配置成免密。

> 这是伪分布式最容易想不通的一步：明明只有一台机器，为什么还要配 SSH？答案就在上面这套机制里。

### 未配置免密时的表现

```shell
[zhangsan@node0 ~]$ ssh node0
The authenticity of host 'node0 (192.168.179.100)' can't be established.
Are you sure you want to continue connecting (yes/no)? yes
zhangsan@node0's password:
```

两个交互提示都要留意：

- 首次连接要求输入 `yes` 确认主机指纹，确认后会写入 `~/.ssh/known_hosts`；
- 随后要求输入密码。只要还在索要密码，后续执行 `start-dfs.sh` 就会被卡在这里。

### 生成密钥对

```shell
[zhangsan@node0 ~]$ ssh-keygen
```

执行后会在用户目录 `~` 下生成 `.ssh` 文件夹，内含公钥 `id_rsa.pub` 与私钥 `id_rsa`。

过程中的提示直接回车使用默认值即可；尤其**不要给私钥设置口令**，否则每次启动集群仍然要交互输入。

### 分发公钥到本机

```shell
[zhangsan@node0 ~]$ ssh-copy-id -i node0
```

`ssh-copy-id` 会把本机公钥追加到目标机器的 `~/.ssh/authorized_keys` 中，此过程中需要输入一次 `zhangsan` 在 `node0` 上的密码。

> `workers` 文件默认内容是 `localhost`。由于 `localhost` 与 `node0` 指向同一台机器、同一个用户，`authorized_keys` 是同一份文件，所以配好 `ssh-copy-id node0` 之后 ssh 到 `localhost` 同样免密，**一般无需修改 workers**。

### 验证

```shell
[zhangsan@node0 ~]$ ssh node0
Last login: Wed Mar 30 13:35:51 2022 from node0
```

直接进入、不再索要密码即为成功。记得用 `exit` 退回原终端。

## 环境变量

让 `hadoop` 命令随处可用，并交代一个只在远程启动时才会暴露的问题。

### HADOOP_HOME 与 PATH

配置文件是用户 HOME 目录（`~`）下的 `.bashrc`。

```shell
[zhangsan@node0 ~]$ vim .bashrc
export HADOOP_HOME=/opt/bigdata/hadoop/default
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH
```

两个目录的分工要分清：

- `bin` 放的是**客户端命令**：`hadoop`、`hdfs`、`yarn`；
- `sbin` 放的是**集群管理脚本**：`start-dfs.sh`、`stop-dfs.sh`、`start-yarn.sh`。

> 之所以能直接敲 `hdfs`、`start-dfs.sh` 而不写全路径，正是因为 `PATH` 里包含了这两个目录。

### 生效与验证

```shell
[zhangsan@node0 ~]$ source ~/.bashrc
[zhangsan@node0 ~]$ hadoop version
```

`source` 使配置在当前终端立即生效；`hadoop version` 能打印出版本信息，即表示环境变量配置成功。

### 为什么还要在 hadoop-env.sh 里再写一遍 JAVA_HOME

`JAVA_HOME` 明明已经在 `/etc/profile` 中配过了，为什么 Hadoop 还要单独写一次？

关键在于**脚本的运行环境**：

- `/etc/profile`、`~/.bashrc` 中的变量，只有"登录式交互式 shell"才会加载；
- 而 `start-dfs.sh` 是通过 ssh **远程执行非交互式命令**启动进程的，这类 shell 不会加载上述文件；
- 脚本因此拿不到 `JAVA_HOME`，找不到 java，`hadoop-env.sh` 的作用就是给 Hadoop 自己的脚本环境兜底。

所以在 `hadoop-env.sh` 中写死的 `JAVA_HOME` 是**必需项**，不是重复劳动。

## 配置文件

五个配置文件各管一段职责，按"在哪、写什么、为什么"的顺序依次说明。

### 配置文件在哪里

四个 `site` 文件与 `hadoop-env.sh` 都位于 `$HADOOP_HOME/etc/hadoop/` 目录下。

```shell
[zhangsan@node0 ~]$ cd /opt/bigdata/hadoop/default/etc/hadoop/
```

| 文件 | 作用范围 | 本篇要设置的内容 |
| --- | --- | --- |
| hadoop-env.sh | 启动脚本的运行环境 | JAVA_HOME |
| core-site.xml | 通用（HDFS 与 YARN 共用） | 默认文件系统、数据目录 |
| hdfs-site.xml | HDFS | 副本数 |
| mapred-site.xml | MapReduce | 运行框架 |
| yarn-site.xml | YARN | ResourceManager 地址、辅助服务 |

### hadoop-env.sh

```shell
JAVA_HOME=/usr/java/default
```

必须写成绝对路径，也不要引用 `$JAVA_HOME`——这里就是定义它的地方。

### core-site.xml

通用配置文件，HDFS 与 YARN 都会读取它。本篇在其中指定默认文件系统与数据目录。

```xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://node0:9000</value>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/opt/bigdata/hadoop/default/tmp</value>
    </property>
</configuration>
```

### core-site.xml 配置项解读

| 配置项 | 值 | 说明 |
| --- | --- | --- |
| fs.defaultFS | hdfs://node0:9000 | 默认文件系统；`node0:9000` 是 NameNode 的 RPC 地址（`Apache` 官方默认端口为 9000，部分发行版习惯用 8020） |
| hadoop.tmp.dir | /opt/bigdata/hadoop/default/tmp | 元数据与数据块的存放根目录 |

> `hadoop.tmp.dir` 的默认值是 `/tmp/hadoop-$USER`。而 Linux 会定期清理 `/tmp`，一旦被清，NameNode 元数据丢失、集群就废了，所以**必须**显式改到非临时目录。

### hdfs-site.xml

`HDFS` 专属配置文件，本篇只设置副本数一项。

```xml
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
</configuration>
```

### 副本数为什么必须改成 1

- 默认值是 3，表示每个数据块存 3 份；
- 伪分布式只有一个 DataNode，多出来的副本无处安放，HDFS 会持续出现 `Under-replicated blocks` 告警；
- 所以单 DataNode 环境必须显式改成 1。

> SecondaryNameNode 若不单独配置 `dfs.namenode.secondary.http-address`，默认就落在本机，伪分布式无需额外配置。

### yarn-site.xml

`YARN` 专属配置文件，指定 ResourceManager 所在主机与 NodeManager 的辅助服务。

```xml
<configuration>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>node0</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
</configuration>
```

### yarn-site.xml 配置项解读

- `yarn.resourcemanager.hostname`：告诉所有 NodeManager 到哪里去找 ResourceManager；
- `yarn.nodemanager.aux-services`：NodeManager 需要加载 `mapreduce_shuffle` 这个辅助服务来提供洗牌能力，**不配的话 Reduce 阶段拉取 Map 端数据会失败**。

### mapred-site.xml

`MapReduce` 专属配置文件，本篇只设置运行框架一项。

```xml
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>
```

### MapReduce 交给谁来跑

该配置的可选值是 `local`、`classic`、`yarn`。设为 `yarn`，意味着 MapReduce 作业提交给 YARN 调度；这也正是它与单机模式（`local`）的本质区别。

## 格式化

`HDFS` 第一次投入使用前必须完成的一次性动作，也是踩坑最多的一步。

### 格式化到底做了什么

第一次启动之前，NameNode 需要先建立起自己的目录结构与元数据。

```shell
[zhangsan@node0 ~]$ hdfs namenode -format
```

它完成三件事：

- 在 `hadoop.tmp.dir` 指定的目录下创建 `dfs/name` 子目录；
- 生成初始的 `fsimage`（文件系统镜像）与 `edits`（操作日志）文件；
- 生成 `VERSION` 文件，写入本次集群的 `clusterID` 与 `blockpoolID`。

判断成功的标志是输出中出现 `Exiting with status 0`。

```shell
22/02/14 23:17:31 INFO util.ExitUtil: Exiting with status 0
22/02/14 23:17:31 INFO namenode.NameNode: SHUTDOWN_MSG:
SHUTDOWN_MSG: Shutting down NameNode at node0/192.168.179.100
```

### 千万别重复格式化（clusterID 陷阱）

DataNode 首次向 NameNode 注册时，会记住 NameNode 的 `clusterID`。如果之后再重新格式化 NameNode：

- NameNode 拿到了**新的** `clusterID`；
- DataNode 数据目录里记的还是**旧的**；
- 两者不一致，DataNode 会被 NameNode 拒绝注册，表现为 `jps` 里看不到 DataNode，日志报 `Incompatible clusterIDs`。

一旦踩到，正确做法是停服务、清空数据目录，然后统一重新格式化：

```shell
[zhangsan@node0 ~]$ stop-dfs.sh
[zhangsan@node0 ~]$ rm -rf $HADOOP_HOME/tmp $HADOOP_HOME/logs
```

> 格式化是**一次性动作**，不是每次启动前都要做的例行流程。只有首次部署、或明确要放弃全部数据时才执行。

## 启动集群

配置就绪之后，把五个守护进程依次拉起来，并逐个确认到位。

### 启动 HDFS

```shell
[zhangsan@node0 ~]$ start-dfs.sh
```

脚本会 ssh 到 `workers` 列出的主机，启动三个守护进程：NameNode、DataNode、SecondaryNameNode。

### 用 jps 确认进程

```shell
[zhangsan@node0 hadoop]$ jps
8096 NameNode
8402 SecondaryNameNode
8230 DataNode
```

三个角色缺一不可：

- `NameNode`：管理元数据（文件名到数据块的映射）；
- `DataNode`：真正存储数据块，并定期向 NameNode 汇报；
- `SecondaryNameNode`：辅助完成 `fsimage` 与 `edits` 的检查点合并，**它不是 NameNode 的热备份**。

### 启动 YARN

```shell
[zhangsan@node0 ~]$ start-yarn.sh
```

```shell
[zhangsan@node0 hadoop]$ jps
8558 ResourceManager
8712 NodeManager
```

- `ResourceManager`：整个集群资源（CPU、内存）的统一调度者；
- `NodeManager`：单台机器上的资源管理者，负责 Container 的启停。

> 也可以用 `start-all.sh` 一次性启动 HDFS 与 YARN，它内部就是依次调用 `start-dfs.sh` 和 `start-yarn.sh`。

### Web UI 一览

在浏览器中访问之前，需要先在宿主机（`Windows`）上配置域名与 IP 的映射，文件是 `C:\Windows\System32\drivers\etc\hosts`：

`192.168.179.100	node0`

Hadoop 3.x 的常用端口：

| 组件 | 地址 | 用来看什么 |
| --- | --- | --- |
| NameNode | http://node0:9870 | HDFS 目录树、DataNode 存活与容量 |
| SecondaryNameNode | http://node0:9868 | 检查点合并状态 |
| ResourceManager | http://node0:8088 | YARN 应用（作业）的运行状态 |

> 端口务必注意版本：Hadoop 2.x 的 NameNode UI 是 `50070`，从 3.x 起改成了 `9870`。参考网上教程时先确认对方的版本。

## 运行验证

进程都在还不算成功，跑通一次完整的作业，才算真正验证。`wordcount` 是最合适的例子。

### 上传文件到 HDFS

数据必须先进入 HDFS，后面运行的 wordcount 才读得到。

```shell
[zhangsan@node0 ~]$ hdfs dfs -mkdir /input
[zhangsan@node0 ~]$ hdfs dfs -put ~/bigdata.txt /input
[zhangsan@node0 ~]$ hdfs dfs -ls /input
```

路径写法说明：`hdfs dfs` 操作的是集群文件系统，命令里不带前缀的路径会默认补上 `fs.defaultFS` 配置的 `hdfs://node0:9000`。

### 提交 WordCount 给 YARN

```shell
[zhangsan@node0 ~]$ hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.1.3.jar wordcount /input/bigdata.txt /output
```

与单机模式相比有四点不同：

- 输入输出路径都是 HDFS 路径；
- 作业不再本地执行，而是交给 ResourceManager 调度，先由 NodeManager 起 Container；
- 输出目录同样必须事先不存在，重复运行请用新目录名；
- 可以在 ResourceManager 的 Web UI（8088）上看到 application 状态一路推进到 SUCCEEDED。

### 查看计算结果

```shell
[zhangsan@node0 ~]$ hdfs dfs -cat /output/part-r-00000
bigdata	1
hello	1
study	1
```

走到这一步才算完整闭环：**HDFS 存住了数据，YARN 调度了计算，MapReduce 产出了结果**。

## 停止与排错

集群要能正确地停下来；进程起不来时，也要知道去哪里找答案。

### 停止集群

```shell
[zhangsan@node0 ~]$ stop-yarn.sh
[zhangsan@node0 ~]$ stop-dfs.sh
```

停止顺序与启动相反：先停 YARN，再停 HDFS。切忌直接关闭虚拟机，否则可能造成元数据不一致。

### 排错的唯一入口：日志

日志目录是 `$HADOOP_HOME/logs/`，按 `<用户>-<角色>-<主机名>.log` 命名，例如 `hadoop-zhangsan-datanode-node0.log`。

先用 `jps` 确认哪个进程没起来，再去对应的日志文件里看原因——报错一定写在那里。

### 常见问题自查清单

| 现象 | 原因 | 处理 |
| --- | --- | --- |
| NameNode 起不来 | 未格式化 | 执行 `hdfs namenode -format` |
| jps 看不到 DataNode | clusterID 不一致（重复格式化所致） | 停集群，清掉 tmp 与 logs 后重新格式化 |
| Permission denied (publickey) | 免密未生效 | 重做 `ssh-copy-id node0`，用 `ssh node0` 复验 |
| 浏览器打不开 UI | 端口用错 / 防火墙 / 未配 hosts | 3.x 用 9870；关闭防火墙；配宿主机 hosts |
| 持续 Under-replicated 告警 | 副本数大于 DataNode 数 | 伪分布式设 `dfs.replication=1` |
| hadoop 命令找不到 | PATH 未生效 | `source ~/.bashrc` 后 `hadoop version` 复验 |

## 小结

回顾本篇的关键动作，并交代下一步完全分布式要做的拆分。

### 本篇要点

- 伪分布式 = 一台机器上跑全量守护进程，组件间走网络 RPC 通信；
- 核心四步：SSH 免密 → 环境变量 → 五个配置文件 → 格式化；
- 守护进程合计 5 个：HDFS 三个 + YARN 两个；
- 格式化只做一次，重复格式化会因 `clusterID` 不一致导致 DataNode 无法注册。

### 下一篇做什么

完全分布式要把 `node0` 上的这些角色拆分到 `node1`、`node2`、`node3` 三台机器：

- 先做集群规划：谁做 NameNode、谁做 ResourceManager、谁放 SecondaryNameNode；
- `workers` 文件改为三台主机名，并为主从节点分别配置免密登录；
- 配置文件写好之后用 `scp` 同步到所有节点。

<div class="end"><h1>谢谢</h1><p>下一篇：完全分布式部署</p></div>
