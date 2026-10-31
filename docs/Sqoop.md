---
title: Sqoop
date: 2023-01-13 15:55:26
categories:
- Sqoop
---

## 文档

https://sqoop.apache.org/docs/1.4.7/SqoopUserGuide.html

## 安装

略

## 配置

```shell
HIVE_CONF_DIR=/opt/bigdata/sqoop/default
cp /opt/bigdata/hive/default/lib/hive-common-2.3.9.jar /opt/bigdata/sqoop/default/lib/
```



将 `mysql-connector-java.jar` 放入`$SQOOP_HOME/lib`目录。

## 准备数据

在MySQL中创建DataBase: `emp`

执行SQL文件导入数据： `emp.sql`

## 使用

### 基础命令

##### 列出所有数据库

```shell
[zhangsan@node0 default]$ bin/sqoop list-databases --connect jdbc:mysql://localhost:3306 --username root --password 123456
```



##### 列出数据库中的表

```shell
[zhangsan@node0 default]$ bin/sqoop list-tables --connect jdbc:mysql://localhost:3306/emp --username root --password 123456
```



##### 生成JavaBean

根据关系型数据库中的`emp`表，生成`Java Bean`

```shell
[zhangsan@node0 default]$ bin/sqoop codegen --connect jdbc:mysql://localhost:3306/emp --username root --password 123456 --table emp --outdir /home/zhangsan/javabean
```



### 导入导出

#### HDFS

##### MySQL To HDFS

```shell
[zhangsan@node0 default]$ bin/sqoop import --connect jdbc:mysql://localhost:3306/emp --username root --password 123456 --table emp -m 1
```

注意：默认字段分隔符为`,`

其中 `-m` 为 导出文件个数，当 `m>1` 时，源表要有主键。

增量导出: https://sqoop.apache.org/docs/1.4.7/SqoopUserGuide.html#_incremental_imports

##### HDFS To MySQL

```shell
[zhangsan@node0 default]$ bin/sqoop export  --connect jdbc:mysql://localhost:3306/emp --username root --password 123456 --table emp --export-dir /user/zhangsan/emp -m 1 --input-fields-terminated-by ','
```



#### Hive

##### MySQL To Hive

```shell
[zhangsan@node0 default]$ bin/sqoop import --connect jdbc:mysql://localhost:3306/emp --username root --password 123456 --table emp --hive-import --hive-table hive_emp -m 1
```

注意：默认字段分隔符为`\001`

https://sqoop.apache.org/docs/1.4.7/SqoopUserGuide.html#_importing_data_into_hive_2



##### Hive To MySQL

```shell
[zhangsan@node0 default]$ bin/sqoop export  --connect jdbc:mysql://localhost:3306/emp --username root --password 123456 --table emp --export-dir /user/hive/warehouse/hive_emp/	part-m-00000 -m 1 --input-fields-terminated-by '\001'
```



#### HBase

##### MySQL To HBase

```shell
[zhangsan@node0 default]$ bin/sqoop import --connect jdbc:mysql://localhost:3306/emp --username root --password 123456 --table emp --columns emp_id,emp_name,emp_salary,emp_dept_id  --hbase-create-table --column-family empinfo --hbase-row-key emp_id --hbase-table emp
```



##### HBase To MySQL

不支持。

