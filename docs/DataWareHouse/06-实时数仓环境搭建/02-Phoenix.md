# Apache Phoenix 入门实训手册

## 一、Phoenix 概述

Apache Phoenix 是构建在 HBase 之上的 SQL 层，它允许用户使用标准的 JDBC API 和 SQL 语法来操作 HBase 数据。Phoenix 将 SQL 查询编译为 HBase 原生 API 调用。

**核心特性：**
- 标准 SQL 支持（SELECT、UPSERT、DELETE、CREATE/ALTER/DROP TABLE）
- 二级索引（全局索引和本地索引）
- 事务支持（有限）
- 与 HBase 无缝集成，自动映射数据模型
- 支持 JDBC/ODBC，可连接 BI 工具

**适用场景：**
- 需要低延迟随机读写的大数据应用
- 实时数据分析与报表
- 物联网时序数据存储与查询
- 替代传统关系型数据库的横向扩展方案

---

## 二、环境准备与安装部署

### 2.1 前置条件
- Hadoop 集群（HDFS + YARN）已正常运行
- ZooKeeper 集群已部署
- HBase 集群版本与 Phoenix 版本兼容（例如 HBase 2.4.x + Phoenix 5.1.x）

### 2.2 下载地址

- http://phoenix.apache.org/

### 2.3 HBase配置

- 修改 hbase-site.xml，追加配置项

  ```xml
  <property>
    <name>phoenix.schema.isNamespaceMappingEnabled</name>
    <value>true</value>
  </property>
  
  <property>
    <name>phoenix.schema.mapSystemTablesToNamespace</name>
    <value>true</value>
  </property>
  ```

  这两个配置是 **Apache Phoenix 对接 HBase 时的「命名空间映射开关」**，作用只有一个：
  **让 Phoenix 的 Schema 直接对应 HBase 的 Namespace（命名空间），而不是把所有表都塞到 HBase 默认命名空间里。**

- 分发配置文件到其他节点



### 2.4 Phoenix部署

- 上传并解压tar包

- 配置环境变量 

  ```bash
  export PHOENIX_HOME=/opt/bigdata/phoenix/default
  export PHOENIX_CLASSPATH=$PHOENIX_HOME
  export PATH=$PATH:$PHOENIX_HOME/bin
  ```

- 复制`$PHOENIX_HOME/phoenix-5.0.0-HBase-2.0-server.jar` 包并拷贝到各个节点的`$HBASE_HOME/lib`中

- 复制`hbase-site.xml`到`phoenix`的`bin`目录。

- 重启HBase

### 2.5 启动 Phoenix 客户端

进入 Phoenix 安装目录，执行 sqlline.py 脚本连接 ZooKeeper：
```bash
cd /opt/phoenix/bin
(base) [zhangsan@node1 bin]$ python2 ./sqlline.py  node1,node2,node3:2181
Setting property: [incremental, false]
Setting property: [isolation, TRANSACTION_READ_COMMITTED]
issuing: !connect jdbc:phoenix:node1,node2,node3:2181 none none org.apache.phoenix.jdbc.PhoenixDriver
Connecting to jdbc:phoenix:node1,node2,node3:2181
SLF4J: Class path contains multiple SLF4J bindings.
SLF4J: Found binding in [jar:file:/opt/bigdata/phoenix/apache-phoenix-5.0.0-HBase-2.0-bin/phoenix-5.0.0-HBase-2.0-client.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/opt/bigdata/hadoop/hadoop-3.1.3/share/hadoop/common/lib/slf4j-log4j12-1.7.25.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
26/04/23 10:24:58 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Connected to: Phoenix (version 5.0)
Driver: PhoenixEmbeddedDriver (version 5.0)
Autocommit status: true
Transaction isolation: TRANSACTION_READ_COMMITTED
Building list of tables and columns for tab-completion (set fastconnect to true to skip)...
263/263 (100%) Done
Done
sqlline version 1.2.0
0: jdbc:phoenix:node1,node2,node3:2181>
```
成功后将出现 `0: jdbc:phoenix:node1,node2,node3:2181>` 提示符，表示已连接。

### 2.6 验证安装

```sql
!tables
```
应列出系统表（如 SYSTEM.CATALOG、SYSTEM.STATS 等）。

---

## 三、数据模型与 SQL 基础

### 3.1 Phoenix 表与 HBase 表的映射

在 Phoenix 中创建表时会自动在 HBase 中创建对应的表。行键（RowKey）由主键列组合而成。

```sql
CREATE TABLE IF NOT EXISTS student (
    id      INTEGER NOT NULL PRIMARY KEY,
    name    VARCHAR,
    age     INTEGER,
    class   VARCHAR
);
```

对应 HBase 存储结构：
- RowKey = 整数 id 的字节序编码
- 列族默认为 `0`（可配置），列名为 `NAME`、`AGE`、`CLASS`

创建完成后，在 HBase Shell中查看

```sql
hbase(main):006:0> list
TABLE
STUDENT
```



### 3.2 数据操作语言 (DML)

**插入/更新数据**（UPSERT 即 INSERT 或 UPDATE）：
```sql
UPSERT INTO student (id, name, age, class) VALUES (1, 'Alice', 18, 'ClassA');
UPSERT INTO student (id, name, age, class) VALUES (2, 'Bob', 19, 'ClassB');
UPSERT INTO student (id, name, class) VALUES (3, 'Charlie', 'ClassA');
```

**查询数据**：
```sql
SELECT * FROM student;
SELECT name, age FROM student WHERE age > 18;
SELECT class, COUNT(*) AS cnt FROM student GROUP BY class;
```

**在HBase Shell中查询数据：**

```sql
hbase(main):004:0> scan 'STUDENT'
ROW                                      COLUMN+CELL
 \x80\x00\x00\x01                        column=0:\x00\x00\x00\x00, timestamp=1776670853938, value=x
 \x80\x00\x00\x01                        column=0:\x80\x0B, timestamp=1776670853938, value=Alice
 \x80\x00\x00\x01                        column=0:\x80\x0C, timestamp=1776670853938, value=\x80\x00\x00\x12
 \x80\x00\x00\x01                        column=0:\x80\x0D, timestamp=1776670853938, value=ClassA
 \x80\x00\x00\x02                        column=0:\x00\x00\x00\x00, timestamp=1776670853991, value=x
 \x80\x00\x00\x02                        column=0:\x80\x0B, timestamp=1776670853991, value=Bob
 \x80\x00\x00\x02                        column=0:\x80\x0C, timestamp=1776670853991, value=\x80\x00\x00\x13
 \x80\x00\x00\x02                        column=0:\x80\x0D, timestamp=1776670853991, value=ClassB
2 row(s)
Took 0.0207 seconds
```

> **Phoenix 在 HBase 底层使用了自定义的编码和序列化机制**，而不是直接存储原始的字符串或可读文本。
>
> **HBase Shell 只适合查看原生 HBase 表的原始字节内容**，对于 Phoenix 管理的表，请始终使用 Phoenix 客户端（sqlline、JDBC 等）来读写数据，以获得可读的显示效果。

**删除数据**：

```sql
DELETE FROM student WHERE id = 3;
```

### 3.3 常用数据类型

| Phoenix 类型 | 说明           | 映射 HBase 存储 |
| ------------ | -------------- | --------------- |
| INTEGER      | 4 字节整数     | 固定宽度        |
| BIGINT       | 8 字节长整型   | 固定宽度        |
| VARCHAR(n)   | 可变长度字符串 | UTF-8 编码      |
| CHAR(n)      | 定长字符串     | 固定宽度        |
| DATE / TIME  | 日期时间       | 长整型时间戳    |
| DECIMAL      | 精确小数       | 变长编码        |
| BOOLEAN      | 布尔值         | 单字节          |

---

## 四、高级特性与性能优化

### 5.1 加盐表（Salted Table）

当 RowKey 设计存在热点写入时（如单调递增 ID），可通过加盐打散数据。

```sql
CREATE TABLE student_salted (
    id   INTEGER NOT NULL PRIMARY KEY,
    name VARCHAR
) SALT_BUCKETS = 4;
```
盐值会自动作为 RowKey 前缀，对用户透明。

### 5.2 预分区表（Pre-split）

根据 RowKey 分布提前切分 Region，避免写入热点。

```sql
CREATE TABLE student_presplit (
    id   INTEGER NOT NULL PRIMARY KEY,
    name VARCHAR
) SPLIT ON (10, 20, 30);
```

