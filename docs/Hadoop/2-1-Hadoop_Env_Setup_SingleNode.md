---
marp: true
headingDivider: 6
theme: python-mini-pptx
title: Hadoop环境部署-单机
date: 2023-01-15 15:55:26
categories:
- Hadoop
tags:
- Hadoop
- 环境搭建
---

<div class="cover"><h1>Hadoop 部署（一）单机模式</h1><p>Standalone Operation：不启动守护进程的最小验证环境</p></div>

# Hadoop环境部署-单机

全系列统一约定：虚拟机名为 `node0`，`IP` 为 `192.168.179.100`，普通用户为 `zhangsan`，所有大数据组件安装在 `/opt/bigdata/` 下，`Hadoop` 版本统一为 `3.1.3`。

> **预备知识**：本篇默认你已了解 HDFS、YARN、MapReduce 各自的职责，以及 NameNode、DataNode、ResourceManager 等角色的含义。若还不熟悉，建议先读 [Hadoop 架构导论](/Hadoop/00-Hadoop_Overview_Architecture)，其中还有一张"概念 ↔ 进程 ↔ 端口"的对照表。

## 学习目标

先把单机模式放进三种部署模式的坐标系里，看清它的位置与用途。

### 本篇要解决的问题

- `Hadoop` 下载解压之后，**最小可运行**的形态是什么？
- 一个后台服务都不启动，能不能跑 `MapReduce`？
- 计算结果为什写在名为 `part-r-00000` 的文件里？

### 三种部署模式对照

| 对比项 | 单机模式 | 伪分布式 | 完全分布式 |
| --- | --- | --- | --- |
| 守护进程 | 无 | 全部进程在一台机器 | 进程分布在多台机器 |
| 文件系统 | 本地文件系统 | HDFS（单 DataNode） | HDFS（多 DataNode） |
| 计算资源 | 单个 JVM 多线程模拟 | YARN（单 NodeManager） | YARN（多 NodeManager） |
| SSH 免密 | 不需要 | 需要（登录本机） | 需要（登录所有节点） |
| 典型用途 | 验证程序逻辑 | 学习组件协作 | 生产环境 |

> 单机模式是理解后两种模式的起点：**它剥离了分布式的外壳，只剩下 MapReduce 本身**。

### 为什么从单机模式开始

- `MapReduce` 程序的正确性（输入输出类型、聚合逻辑）与"有没有集群"无关，用单机模式验证最快；
- 单机模式**几乎不会因为环境配置失败**，排错范围最小；
- 后续每一种部署模式的配置，都可以拿单机模式作为对比基线。

## 安装

下载、解压、建软连接，三步之后 `Hadoop` 就可以使用了。

### 下载安装包

安装包从 `Apache` 归档站点获取，本系列统一使用 `3.1.3` 版本。

```http
wget https://archive.apache.org/dist/hadoop/common/hadoop-3.1.3/hadoop-3.1.3.tar.gz
```

> 务必注意版本一致性：后面用到的 `jar` 包名、`$HADOOP_HOME` 路径中的版本号都必须是 `3.1.3`，版本混用是最常见的报错来源。

### 复制到安装目录并解压

全系列统一的软件安装根目录是 `/opt/bigdata/hadoop/`。

```shell
[zhangsan@node0 ~]$ cp hadoop-3.1.3.tar.gz /opt/bigdata/hadoop/
[zhangsan@node0 ~]$ cd /opt/bigdata/hadoop/
[zhangsan@node0 hadoop]$ tar -zxf hadoop-3.1.3.tar.gz
```

### 创建软连接

为什么要额外建一个名为 `default` 的软连接：

- 环境变量 `$HADOOP_HOME` 固定指向 `default`，**切换版本只需要改软连接的指向**，环境变量与所有脚本都不用动；
- 同一台机器上可以同时保留多个 `Hadoop` 版本，互不干扰。

```bash
[zhangsan@node1 hadoop]$ ll /opt/bigdata/hadoop/
total 12
lrwxrwxrwx.  1 zhangsan zhangsan   12 Feb 28 12:53 default -> hadoop-3.1.3
drwxr-xr-x. 11 zhangsan zhangsan 4096 Feb 28 15:57 hadoop-3.1.3
drwxr-xr-x. 11 zhangsan zhangsan 4096 Dec 25 22:31 hadoop-2.7.3
```
> 本系列中 `$HADOOP_HOME` = `/opt/bigdata/hadoop/default`，实际指向 `hadoop-3.1.3`。

## 配置文件

单机模式不需要修改任何配置，原因就藏在 `Hadoop` 的那一组默认值里。

### 为什么单机模式无需修改任何配置

`Hadoop` 的每一个配置项都有默认值，这一组默认值组合起来就是单机模式：

- 默认文件系统 `fs.defaultFS` 是 `file:///`，也就是**本机文件系统**，不涉及 HDFS；
- 默认运行框架 `mapreduce.framework.name` 是 `local`，作业在**单个 JVM 内**完成，不提交给 YARN；
- 没有 NameNode、DataNode、ResourceManager 需要指定地址。

因此解压即可使用。所谓"单机模式"，本质就是**把 Hadoop 当成一个普通的 Java 程序库来运行**。

## 运行验证

用官方 `wordcount` 示例跑一遍，验证这套安装确实能产出正确的计算结果。

### 准备输入文件

在用户家目录下造一个小文本文件作为输入。

```shell
[zhangsan@node0 ~]$ echo hello study bigdata > bigdata.txt
```

### 运行 WordCount

`wordcount` 是 Hadoop 自带的示例程序，打包在 `examples` 的 `jar` 包里。

```shell
[zhangsan@node0 ~]$ hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.1.3.jar wordcount /home/zhangsan/bigdata.txt /home/zhangsan/out
```

命令拆解：

- `hadoop jar <jar 路径>`：启动一个 JVM 来运行指定的 Java 程序；
- `wordcount`：要运行的主类名；
- 之后的参数由程序自己约定，`wordcount` 的规则是 `<输入路径> <输出路径>`。

> 上面命令能这样写的前提是环境变量 `$HADOOP_HOME` 已生效（见 Linux 系统配置篇）。若尚未配置，可以先 `cd $HADOOP_HOME/bin` 再用 `./hadoop jar ...` 执行。

### 查看计算结果

```shell
[zhangsan@node0 ~]$ cat /home/zhangsan/out/part-r-00000
bigdata	1
hello	1
study	1
```

为什么叫 `part-r-00000`？

- `r` 表示这是 **Reduce 阶段**的输出（`m` 则表示 Map 阶段）；
- `00000` 是 Reduce 任务的编号，有几个 Reducer 就会生成几个 `part-r-*` 文件；
- 结果是**按键排序**的（bigdata、hello、study），这个顺序由 Shuffle 阶段的排序保证。

### 用 jps 看看有没有"服务"

```shell
[zhangsan@node0 ~]$ jps
2513 Jps
2479 RunJar
```

这一段最容易误解，需要说明两点：

- 列表里只有 `RunJar`（本次 `hadoop jar` 启动的进程）和 `Jps`（`jps` 命令自身），**没有任何 Hadoop 守护进程**；
- 作业结束后 `RunJar` 随之退出，进程消失是正常现象，不是崩溃。

> 正因为单机模式不存在后台服务，我们看到的是"命令执行完就干净退出"，这与后面伪分布式的常驻进程形成鲜明对比。

### 再次运行前必须先做的事

`MapReduce` 要求输出目录**事先不存在**，重复运行会直接报错退出。

```text
org.apache.hadoop.mapred.FileAlreadyExistsException: Output directory file:/home/zhangsan/out already exists
```

这是 Hadoop 的保护机制：防止多个作业的输出互相覆盖。

```shell
[zhangsan@node0 ~]$ rm -rf /home/zhangsan/out
```

习惯上也可以每次换一个输出目录名，便于保留多份结果做对比。

## 小结

回顾本篇要点，并预告伪分布式需要额外补齐哪些环节。

### 本篇要点

- 单机模式 = 默认配置 + 本地文件系统 + 单 JVM，**不启动任何守护进程**；
- 安装三步走：下载 → 解压 → 创建软连接 `default`；
- 用官方 `wordcount` 示例验证安装是否成功；
- 输出目录必须事先不存在；结果文件 `part-r-00000` 的个数由 Reduce 任务数决定。

### 下一篇做什么

伪分布式要在**同一台机器上**跑起完整的 HDFS 与 YARN：

- 必须先配置 SSH 免密登录——即使是登录本机，`start-dfs.sh` 也是通过 ssh 拉起守护进程的；
- 必须修改全套配置文件，明确指定 NameNode 与 ResourceManager 的地址；
- 必须先格式化 NameNode，之后才会出现常驻后台的守护进程。

<div class="end"><h1>谢谢</h1><p>下一篇：伪分布式部署</p></div>
