---
title: Flink Hello World
date: 2026-03-14 21:36:26
categories:
- Flink 
tags:
- Flink
- Hello World
---

```mermaid
graph LR
    subgraph External
        NC["nc -lk 9999<br/>(socket server)"]
    end

    subgraph Flink_Job
        Source["env.socketTextStream()<br/>Source 算子"]
        Print["print()<br/>Sink 算子"]
    end

    subgraph Output
        Console["控制台输出<br/>(a, b b, c c c)"]
    end

    NC -- "逐行数据" --> Source
    Source -- "DataStream<String>" --> Print
    Print -- "直接打印" --> Console
```

### 创建项目

[image-20260505155308912](/DataWareHouse/07-实时数仓构建/img/01-Flink-HelloWorld/image-20260505155308912.png)



创建完成后，删除 **src**目录

[image-20260422190840140](/DataWareHouse/07-实时数仓构建/img/00-Flink-HelloWorld/image-20260422190840140.png)



### 添加Module

[image-20260422190954012](/DataWareHouse/07-实时数仓构建/img/00-Flink-HelloWorld/image-20260422190954012.png)

> 包名改成自己的名字



### 添加依赖

在该Modue的pom.xml中添加依赖

```xml
<flink.version>1.16.1</flink.version>

<!-- Flink 核心依赖 -->
<dependency>
    <groupId>org.apache.flink</groupId>
    <artifactId>flink-java</artifactId>
    <version>${flink.version}</version>
</dependency>
<dependency>
    <groupId>org.apache.flink</groupId>
    <artifactId>flink-streaming-java</artifactId>
    <version>${flink.version}</version>
</dependency>
<!-- Flink 客户端依赖（本地运行需要） -->
<dependency>
    <groupId>org.apache.flink</groupId>
    <artifactId>flink-clients</artifactId>
    <version>${flink.version}</version>
</dependency>
```



### 编写实现

#### 创建包

包名为 `com.姓名全拼.flink.base`

#### 创建类

创建类 HelloWorld，此类将`Socket`输入直接输出到控制台。

```java
public static void main(String[] args) throws Exception {
    // 1. 创建流处理执行环境
    StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
    // 本地运行时设置并行度为 1，方便查看结果
    env.setParallelism(1);

    // 2. 加载数据源：监听本地 9999 端口的实时输入（需先启动 nc -lk 9999 命令）
    DataStream<String> socketSource = env.socketTextStream("node1", 9999);

    // 3. 输出结果到控制台
    socketSource.print();
    
    // 4. 触发流处理执行（流处理必须显式调用 execute）
    env.execute("Flink Stream WordCount Demo");
}
```

### 输入

```bash
[root@node1 hadoop]# yum install epel-release -y

[root@node1 hadoop]#  yum install nc -y

[root@node1 zhangsan]# nc --version
Ncat: Version 7.50 ( https://nmap.org/ncat )

[zhangsan@node1 zhangsan]~ nc -lk 9999
a
b b
c c c
```

### 输出

```bash
a
b b
c c c
```



### 知识点

```properties
假设集群有3台机器，每台机器有2个slot
env.setParallelism(6);
结果：6个并行子任务分布在3台机器上
Machine1: 线程1, 线程2
Machine2: 线程3, 线程4
Machine3: 线程5, 线程6
```

```mermaid
graph TB
    subgraph Cluster["集群 (3台TaskManager, 每台2个Slot)"]
        subgraph TM1["TaskManager 1"]
            S1["Slot 1: Subtask 1 (Source+Print)"]
            S2["Slot 2: Subtask 2 (Source+Print)"]
        end
        subgraph TM2["TaskManager 2"]
            S3["Slot 1: Subtask 3 (Source+Print)"]
            S4["Slot 2: Subtask 4 (Source+Print)"]
        end
        subgraph TM3["TaskManager 3"]
            S5["Slot 1: Subtask 5 (Source+Print)"]
            S6["Slot 2: Subtask 6 (Source+Print)"]
        end
    end

    NC["nc -lk 9999"] -->|"数据分发"| S1
    NC --> S2
    NC --> S3
    NC --> S4
    NC --> S5
    NC --> S6

    S1 -->|print| Console1["控制台输出"]
    S2 -->|print| Console2["控制台输出"]
    S3 -->|print| Console3["控制台输出"]
    S4 -->|print| Console4["控制台输出"]
    S5 -->|print| Console5["控制台输出"]
    S6 -->|print| Console6["控制台输出"]
```

