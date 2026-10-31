---
title: HDFS综合操作实验：安全模式管理与集群监控
date: 2021-01-15 15:55:26
categories:
- Hadoop
tags:
- Hadoop
- HDFS综合操作实验
---

### 一、实验目标

1.  掌握HDFS的格式化操作及其影响。
2.  熟练使用`hdfs dfsadmin`命令查看集群状态和网络拓扑。
3.  理解并实践HDFS的安全模式（Safe Mode），观察其对文件操作的影响。
4.  综合运用HDFS文件上传、下载、查看等基础命令。

### 二、实验环境

*   已配置好的Hadoop集群（包含Namenode和至少一个Datanode）。
*   学生已登录到Namenode节点（例如 `node0`）。

### 三、实验步骤

#### 步骤 1：环境准备与HDFS格式化 (热身)

1. **停止 Hadoop 服务**：为确保环境干净，先停止所有 Hadoop 相关服务。

   ```bash
   [zhangsan@node0 ~]$ stop-all.sh
   # 或者分别停止
   # stop-dfs.sh
   # stop-yarn.sh
   ```

2. **确认 `hadoop.tmp.dir` 配置**：格式化前先确认 HDFS 数据目录的位置，后续清理与验证都依赖该路径。（查看 core-site.xml 中 hadoop.tmp.dir 的实际取值）

   ```bash
   [zhangsan@node0 ~]$ grep -A 1 'hadoop.tmp.dir' $HADOOP_HOME/etc/hadoop/core-site.xml
   ```
   
3. **清理旧数据**：删除上一次运行留下的 HDFS 数据与日志，避免残留元数据导致冲突。

   ```bash
   # 路径以 hadoop.tmp.dir 的实际配置为准，以下为示例
   [zhangsan@node0 ~]$ rm -rf /opt/bigdata/hadoop/default/tmp/*
   [zhangsan@node0 ~]$ rm -rf /opt/bigdata/hadoop/default/logs/*
   ```

4. **格式化 Namenode**：执行格式化命令，清空 HDFS 的元数据并初始化新的命名空间。

   ```bash
   [zhangsan@node0 ~]$ hdfs namenode -format
   ```

5. **验证格式化结果**：进入 `dfs.name.dir`（由 `hadoop.tmp.dir` 配置决定）的 `current` 目录，查看是否生成了新的 `fsimage` 等文件。

   ```bash
   # 路径可能因配置而异，请根据实际情况修改
   [zhangsan@node0 ~]$ cd /opt/bigdata/hadoop/default/tmp/dfs/name/current
   [zhangsan@node0 ~]$ ls -al
   ```
   > **预期结果**：能看到 `fsimage_*`、`seen_txid`、`VERSION` 等文件。

6. **重启 Hadoop 服务**：启动所有 Hadoop 服务，使格式化生效。

   ```bash
   [zhangsan@node0 ~]$ start-all.sh
   # 或者分别启动
   # start-dfs.sh
   # start-yarn.sh
   ```

7. **查看相关进程是否启动**
   
   ```bash
   [zhangsan@node0 ~]$ jps
   ```

#### 步骤 2：上传文件并查看HDFS状态

1. **创建本地测试文件**：在Linux本地创建一个文本文件。
   ```bash
   [zhangsan@node0 ~]$ echo "Hello HDFS, this is a test file for comprehensive operation." > test_hdfs.txt
   ```
2. **创建用户目录**/user/zhangsan

   ```bash
   [zhangsan@node0 ~]$ hdfs dfs -mkdir -p /user/zhangsan
   ```

1. **上传文件到HDFS**：将创建的文件上传到HDFS的用户主目录下。

   ```bash
   [zhangsan@node0 ~]$ hdfs dfs -put test_hdfs.txt /user/zhangsan/
   ```
2. **查看HDFS文件列表**：确认文件已成功上传。

   ```bash
   [zhangsan@node0 ~]$ hdfs dfs -ls /user/zhangsan/
   ```
3. **查看HDFS集群报告**：使用管理员命令查看整个文件系统的容量、使用情况和Datanode状态。
   ```bash
   [zhangsan@node0 ~]$ hdfs dfsadmin -report
   ```
   > **思考**：记录下 `DFS Used` 和 `DFS Remaining` 的值，稍后对比。

#### 步骤 3：管理安全模式

1.  **进入安全模式**：手动将Namenode置于安全模式。
    ```bash
    [zhangsan@node0 ~]$ hdfs dfsadmin -safemode enter
    ```
2.  **查看安全模式状态**：确认当前模式。
    ```bash
    [zhangsan@node0 ~]$ hdfs dfsadmin -safemode get
    ```
    > **预期结果**：输出 `Safe mode is ON`。

3.  **尝试删除操作（验证限制）**：在安全模式下，尝试删除刚刚上传的文件。
    
    ```bash
    [zhangsan@node0 ~]$ hdfs dfs -rm /user/zhangsan/test_hdfs.txt
    ```
    > **预期结果**：操作失败，并提示 `Name node is in safe mode.`。
    
4.  **尝试读取操作（验证权限）**：在安全模式下，尝试查看文件内容。
    ```bash
    [zhangsan@node0 ~]$ hdfs dfs -cat /user/zhangsan/test_hdfs.txt
    ```
    > **预期结果**：可以成功读取文件内容。

5.  **离开安全模式**：手动强制Namenode退出安全模式。
    
    ```bash
    [zhangsan@node0 ~]$ hdfs dfsadmin -safemode leave
    ```

#### 步骤 4：验证与清理

1.  **再次尝试删除文件**：在安全模式关闭后，重新执行删除命令。
    
    ```bash
    [zhangsan@node0 ~]$ hdfs dfs -rm /user/zhangsan/test_hdfs.txt
    ```
    > **预期结果**：文件被成功删除。
    
3.  **查看网络拓扑**：使用管理员命令查看HDFS集群的网络拓扑结构。
    ```bash
    [zhangsan@node0 ~]$ hdfs dfsadmin -printTopology
    ```
    > **预期结果**：显示出机架（rack）和下属的Datanode列表。



### 总结

通过本次实验，我们依次完成了以下核心操作：

1. **集群初始化**：通过停止服务、清理旧数据并执行 `hdfs namenode -format`，掌握了格式化对 HDFS 元数据的清空与重建作用，以及如何通过 `hadoop.tmp.dir` 定位数据与日志目录进行验证。
2. **基础文件操作与状态监控**：使用 `hdfs dfs -put/-ls/-cat` 完成文件上传与查看，并借助 `hdfs dfsadmin -report` 获取集群容量、使用情况和 Datanode 状态，建立了对比基线。
3. **安全模式管理**：通过 `hdfs dfsadmin -safemode enter/get/leave` 验证了安全模式下只读不写的特性——读取正常而删除被拒绝，理解了 Namenode 在数据块未充分复制时保护文件系统一致性的机制。
4. **拓扑与清理**：利用 `hdfs dfsadmin -printTopology` 查看集群机架与 Datanode 的网络拓扑结构，并在退出安全模式后验证了写操作的恢复。

**关键收获**：`hdfs dfsadmin` 是 HDFS 集群管理与运维的核心命令集；安全模式是 Namenode 启动和异常恢复期间保障元数据一致性的重要保护机制，期间仅允许读操作、禁止任何修改命名空间的操作。
