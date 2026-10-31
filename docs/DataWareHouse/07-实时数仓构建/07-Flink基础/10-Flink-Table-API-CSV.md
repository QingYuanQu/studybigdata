---
title: Flink Table API - CSV
date: 2026-03-14 21:36:26
categories:
- Flink 
tags:
- Flink Table API
- Table API CSV
---



Apache Flink 的 Table API 是一种用于流处理和批处理的统一的关系型 API。它允许用户以声明式的方式编写查询，类似于 SQL，但可以无缝地集成到 Flink 程序中。以下是一个入门示例，演示如何使用 Table API 读取 CSV 文件、进行简单的聚合计算并将结果输出到控制台。

### 引入依赖

在开始之前，确保你的项目中包含了必要的依赖。以 Maven 为例，在 `pom.xml` 中添加以下依赖：

```xml
        <!-- Flink Table API 依赖 -->
        <dependency>
            <groupId>org.apache.flink</groupId>
            <artifactId>flink-table-api-java-bridge</artifactId>
            <version>${flink.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.flink</groupId>
            <artifactId>flink-table-runtime</artifactId>
            <version>${flink.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.flink</groupId>
            <artifactId>flink-table-planner_2.12</artifactId>
            <version>${flink.version}</version>
        </dependency>
        <!-- Flink FileSystem Connector -->
        <dependency>
            <groupId>org.apache.flink</groupId>
            <artifactId>flink-connector-files</artifactId>
            <version>${flink.version}</version>
        </dependency>
        <!-- Flink CSV Format Connector (Flink 1.16+ 使用 flink-csv) -->
        <dependency>
            <groupId>org.apache.flink</groupId>
            <artifactId>flink-csv</artifactId>
            <version>${flink.version}</version>
        </dependency>
```

### 示例数据

我们有一个销售记录文件 `sales.csv`，内容如下：

```csv
apple,10
banana,5
apple,7
orange,3
banana,8
```

我们希望计算每种产品的总销量（`amount` 总和）。

### 代码实现

以下是使用 Java 编写的 Flink Table API 程序：

#### 创建表环境

```java
StreamTableEnvironment tableEnv = StreamTableEnvironment.create(env);
tableEnv.getConfig().getConfiguration().setString("table.exec.state.ttl",(15*60+5) + "s");
```

#### 创建表

```java
tableEnv.executeSql("CREATE TABLE sales (" +
        "  product STRING," +
        "  amount INT" +
        ") WITH (" +
        "  'connector' = 'filesystem'," +
        "  'path' = '/path/to/csv'," +   // 替换为实际文件路径
        "  'format' = 'csv'," +
        "  'csv.first-line-as-header' = 'true'," +
        "  'csv.ignore-parse-errors' = 'true'" +
        ")");
```

#### 查询输出

```java
Table sales = tableEnv.from("sales");
Table result = sales
        .groupBy($("product")) //`$` 是 Flink 提供的一个辅助方法，用于引用列名
        .select($("product"), $("amount").sum().as("total_amount"));

result.execute().print();
```

### 输出

```shell
+----+--------------------------------+--------------+
| op |                        product | total_amount |
+----+--------------------------------+--------------+
| +I |                          apple |           10 |
| +I |                         banana |            5 |
| -U |                          apple |           10 |
| +U |                          apple |           17 |
| +I |                         orange |            3 |
| -U |                         banana |            5 |
| +U |                         banana |           13 |
+----+--------------------------------+--------------+
```

### 执行流程分析

```shell
读取 apple,10
+I (Insert): apple = 10
读取 banana,5
+I (Insert): banana = 5
读取 apple,7
-U (Update Before): 撤销之前的 apple=10
+U (Update After): 更新为 apple=17 (10+7)
读取 orange,3
+I (Insert): orange = 3
读取 banana,8
-U (Update Before): 撤销之前的 banana=5
+U (Update After): 更新为 banana=13 (5+8)
```

### TTL

TTL 是 **Time To Live** 的缩写，意思是"生存时间"。

在代码中：
```java
tableEnv.getConfig().getConfiguration().setString("table.exec.state.ttl", (15*60+5) + "s");
```


这行代码设置了 **Flink 状态数据的过期时间为 15 分 5 秒（905 秒）**。

#### 为什么需要 TTL？

在流式计算中，Flink 会维护**状态数据**（比如您的 GROUP BY 聚合结果）：
- `apple` 的累计值 = 17
- `banana` 的累计值 = 13
- `orange` 的累计值 = 3

如果没有 TTL，这些状态会**永久保存**在内存或 RocksDB 中，导致：
1. ❌ 内存/磁盘占用越来越大
2. ❌ 对于不再更新的产品（如 orange），状态永远不清理
3. ❌ 长时间运行后可能 OOM（内存溢出）

#### TTL 的工作原理

设置 TTL = 905 秒后：
- ✅ 当某个产品的数据超过 905 秒没有更新时，Flink 会自动清理它的状态
- ✅ 释放内存空间
- ✅ 保持系统稳定运行
