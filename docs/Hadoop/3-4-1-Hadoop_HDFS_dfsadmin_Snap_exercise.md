---
title: HDFS 快照管理实训实验
date: 2021-01-15 15:55:26
categories:
- Hadoop
tags:
- Hadoop
- HDFS综合操作实验
---

#### 一、实验目标

1.  掌握如何启用和禁用 HDFS 目录的快照功能。
2.  学会创建、重命名和删除 HDFS 快照。
3.  理解如何利用快照进行数据恢复。
4.  掌握如何查看快照列表和比较不同快照之间的差异。

#### 二、实验环境

*   已搭建好的 Hadoop 集群（伪分布式或完全分布式均可）。
*   已启动 HDFS 服务。
*   一个用于操作的 HDFS 用户（例如 `zhangsan`）。

#### 三、实验步骤

##### 步骤一：环境准备与启用快照

1.  **创建实验目录和文件**：
    在 HDFS 上为本次实验创建一个专用的目录（例如 `/snapshot_test`），并在其中创建一个初始文件。
    ```shell
    # 在 HDFS 上创建目录
    hdfs dfs -mkdir /snapshot_test
    
    # 创建一个名为 initial_data.txt 的文件并写入内容
    echo "This is the initial data." | hdfs dfs -put - /snapshot_test/initial_data.txt
    
    # 查看目录内容，确认文件创建成功
    hdfs dfs -ls /snapshot_test
    ```

2.  **启用目录快照功能**：
    使用 `dfsadmin` 命令将刚刚创建的目录设置为可快照目录。
    
    ```shell
    hdfs dfsadmin -allowSnapshot /snapshot_test
    ```
    预期输出：`Allowing snaphot on /snapshot_test succeeded`

##### 步骤二：创建与查看快照

1.  **创建第一个快照**：
    在 `/snapshot_test` 目录上创建一个名为 `snap_v1` 的快照。
    
    ```shell
    hdfs dfs -createSnapshot /snapshot_test snap_v1
    ```
    预期输出：`Created snapshot /snapshot_test/.snapshot/snap_v1`
    
2.  **查看快照列表**：
    使用 `lsSnapshottableDir` 命令查看当前用户有权限的所有可快照目录及其快照数量。
    ```shell
    hdfs lsSnapshottableDir
    ```
    在输出结果中找到 `/snapshot_test` 目录，并确认其快照数量（`numSnapshots`）为 `1`。

3.  **模拟数据变更**：
    向 `/snapshot_test` 目录中添加一个新文件，以模拟数据的日常更新。
    ```shell
    # 创建一个新文件
    echo "This is some new data." | hdfs dfs -put - /snapshot_test/new_data.txt
    
    # 查看当前目录内容，确认新文件已添加
    hdfs dfs -ls /snapshot_test
    ```

4.  **创建第二个快照**：
    在数据变更后， 为`/snapshot_test` 目录创建第二个名为 `snap_v2` 的快照。
    
    ```shell
    
    ```
    预期输出：`Created snapshot /snapshot_test/.snapshot/snap_v2`

##### 步骤三：比较快照差异

1.  **生成快照差异报告**：
    使用 `snapshotDiff` 命令比较 `snap_v1` 和 `snap_v2` 两个快照之间的差异。
    ```shell
    hdfs snapshotDiff /snapshot_test snap_v1 snap_v2
    ```
    预期输出会显示根目录 `.` 被修改（`M`），并且有一个新文件 `new_data.txt` 被添加（`+`）。

##### 步骤四：数据恢复操作

1.  **模拟数据误删**：
    删除当前目录下的 `new_data.txt` 文件，模拟用户的误操作。
    ```shell
    
    ```
    预期输出：`Deleted /snapshot_test/new_data.txt`

2.  **从快照中恢复数据**：
    从 `snap_v2` 快照中复制 `new_data.txt` 文件，将其恢复到原目录。
    ```shell
    
    ```

3.  **验证数据恢复**：
    再次查看 `/snapshot_test` 目录，确认 `new_data.txt` 文件已成功恢复。
    ```shell
    hdfs dfs -ls /snapshot_test
    ```

##### 步骤五：重命名与删除快照

1.  **重命名快照**：
    将 `snap_v2` 重命名为 `snap_before_deletion`，使其更具描述性。
    ```shell
    
    ```

2.  **删除快照**：
    删除不再需要的 `snap_v1` 快照。
    ```shell
    
    ```

##### 步骤六：禁用快照功能

1.  **尝试直接禁用（预期失败）**：
    尝试直接禁用 `/snapshot_test` 目录的快照功能。
    ```shell
    hdfs dfsadmin -disallowSnapshot /snapshot_test
    ```
    预期输出：`disallowSnapshot: The directory /snapshot_test has snapshot(s). Please redo the operation after removing all the snapshots.` （因为目录下仍有 `snap_before_deletion` 快照）。

2.  **删除所有快照后禁用**：
    先删除最后一个快照`snap_before_deletion`，然后再禁用目录的快照功能。
    
    ```shell
    
    ```
    
    再次禁用快照功能
    ```shell 
	
    ```
	预期输出：`Disallowing snaphot on /snapshot_test succeeded`

#### 四、实验总结与思考

**总结**：通过本实验，你成功地完成了从启用快照、创建快照、查看差异、数据恢复到最终清理快照和禁用功能的全过程。这模拟了在实际生产环境中利用 HDFS 快照进行数据保护和灾难恢复的核心工作流。