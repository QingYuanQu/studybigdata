---
title: Flink CDC
date: 2026-03-14 21:36:26
categories:
- Flink 
tags:
- Flink
- Flink CDC
---

```xml
<dependency> 
    <groupId>org.apache.phoenix</groupId> 
    <artifactId>phoenix-spark</artifactId> 
    <version>5.0.0-HBase-2.0</version> 
    <exclusions>  
        <exclusion>   
            <groupId>org.glassfish</groupId>   
            <artifactId>javax.el</artifactId>  
        </exclusion> 
    </exclusions>
</dependency>
```





## 示例数据

### 示例数据库

```mysql
-- 创建数据库
CREATE DATABASE IF NOT EXISTS flink_cdc_demo 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE flink_cdc_demo;
```

### 示例数据表

```mysql
-- 创建用户表
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '用户ID',
    username VARCHAR(50) NOT NULL COMMENT '用户名',
    phone VARCHAR(20) COMMENT '手机号',
    age INT COMMENT '年龄'
) ENGINE=InnoDB COMMENT='用户表';
```

### 示例数据

```mysql
-- 插入用户数据
INSERT INTO users (username, phone, age) VALUES
('张三', '13800138001', 25),
('李四', '13800138002', 30),
('王五', '13800138003', 28),
('赵六', '13800138004', 35),
('田七', '13800138005', 22);
```

## 启用binlog

```bash
[root@node1 ~]# vim /etc/my.cnf

server-id=1
log-bin=mysql-bin
binlog_format=row
binlog-do-db=flink_cdc_demo
```

重启MySQL服务。



## MySQL CDC

### pom

```xml
<dependency>
    <groupId>org.apache.flink</groupId>
    <artifactId>flink-connector-jdbc</artifactId>
    <version>${flink.version}</version>
</dependency>
<dependency>
    <groupId>com.ververica</groupId>
    <artifactId>flink-connector-mysql-cdc</artifactId>
    <version>2.3.0</version>
</dependency>
<dependency>
    <groupId>org.apache.flink</groupId>
    <artifactId>flink-table-api-java-bridge</artifactId>
    <version>${flink.version}</version>
</dependency>
```

### Java

```java
MySqlSource<String> mySqlSource = MySqlSource.<String>builder()
        .hostname("node1")
        .port(3306)
        .username("root")
        .password("123456")
        .databaseList("flink_cdc_demo")
        .tableList("flink_cdc_demo.users")
        // 定义读取数据的格式
        .deserializer(new JsonDebeziumDeserializationSchema())
        // 设置读取数据的模式
        .startupOptions(StartupOptions.initial())
        .build();
```



### 输出

```json
{"before":null,"after":{"id":1,"username":"张三","phone":"13800138001","age":26},"source":{"version":"1.6.4.Final","connector":"mysql","name":"mysql_binlog_source","ts_ms":0,"snapshot":"false","db":"flink_cdc_demo","sequence":null,"table":"users","server_id":0,"gtid":null,"file":"","pos":0,"row":0,"thread":null,"query":null},"op":"r","ts_ms":1773572116411,"transaction":null}
{"before":null,"after":{"id":2,"username":"李四","phone":"13800138002","age":30},"source":{"version":"1.6.4.Final","connector":"mysql","name":"mysql_binlog_source","ts_ms":0,"snapshot":"false","db":"flink_cdc_demo","sequence":null,"table":"users","server_id":0,"gtid":null,"file":"","pos":0,"row":0,"thread":null,"query":null},"op":"r","ts_ms":1773572116412,"transaction":null}
{"before":null,"after":{"id":3,"username":"王五","phone":"13800138003","age":28},"source":{"version":"1.6.4.Final","connector":"mysql","name":"mysql_binlog_source","ts_ms":0,"snapshot":"false","db":"flink_cdc_demo","sequence":null,"table":"users","server_id":0,"gtid":null,"file":"","pos":0,"row":0,"thread":null,"query":null},"op":"r","ts_ms":1773572116412,"transaction":null}
{"before":null,"after":{"id":4,"username":"赵六","phone":"13800138004","age":35},"source":{"version":"1.6.4.Final","connector":"mysql","name":"mysql_binlog_source","ts_ms":0,"snapshot":"false","db":"flink_cdc_demo","sequence":null,"table":"users","server_id":0,"gtid":null,"file":"","pos":0,"row":0,"thread":null,"query":null},"op":"r","ts_ms":1773572116414,"transaction":null}
{"before":null,"after":{"id":5,"username":"田七","phone":"13800138005","age":22},"source":{"version":"1.6.4.Final","connector":"mysql","name":"mysql_binlog_source","ts_ms":0,"snapshot":"false","db":"flink_cdc_demo","sequence":null,"table":"users","server_id":0,"gtid":null,"file":"","pos":0,"row":0,"thread":null,"query":null},"op":"r","ts_ms":1773572116414,"transaction":null}
```

### 修改

修改`张三`年龄为`27`

```json
{"before":{"id":1,"username":"张三","phone":"13800138001","age":26},"after":{"id":1,"username":"张三","phone":"13800138001","age":27},"source":{"version":"1.6.4.Final","connector":"mysql","name":"mysql_binlog_source","ts_ms":1773572140000,"snapshot":"false","db":"flink_cdc_demo","sequence":null,"table":"users","server_id":1,"gtid":null,"file":"mysql-bin.000009","pos":1171,"row":0,"thread":null,"query":null},"op":"u","ts_ms":1773572141769,"transaction":null}
```



