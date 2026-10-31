---
title: HBase_Shell 练习
date: 2022-03-23 15:55:26
categories:
- HBase
tags:
- HBase Shell
- 限定符
---

# HBase 练习

### 一、基础环境与通用命令

用于HBase Shell终端的进入退出、帮助查询、集群基础信息查看等通用操作。

| 命令语法                   | 核心功能说明                                                 | 标准使用示例        |
| :------------------------- | :----------------------------------------------------------- | :------------------ |
| `hbase shell`              | 进入HBase交互式命令行终端                                    | `hbase shell`       |
| `help` / `help '命令名'`   | 查看所有命令清单，或指定命令的详细用法、参数说明             | `help 'create'`     |
| `exit` / `quit`            | 退出HBase Shell交互终端                                      | `exit`              |
| `status` / `status '级别'` | 查看集群运行状态，支持`simple`/`summary`/`detailed`三个详情级别 | `status 'detailed'` |
| `version`                  | 查看当前HBase的版本信息                                      | `version`           |
| `whoami`                   | 查看当前登录HBase的用户及权限信息                            | `whoami`            |

#### 练习

##### 启动HBase Shell

```
```

##### 查看HBase版本

```shell

```

2.0.5, rUnknown, Thu Jun 18 15:10:52 CST 2020



##### 集群状态

```shell

```

1 active master, 0 backup masters, 3 servers, 0 dead, 17.6667 average load

##### 创建`Teacher`表，包含一个列族`Info` 

```ruby
hbase(main):041:0> create 'Teacher','Info'
0 row(s) in 2.3430 seconds
```





### 二、表结构DDL操作命令

用于HBase表的创建、修改、禁用/启用、删除等表结构定义操作，是表生命周期管理的核心命令。

| 命令语法                                                     | 核心功能说明                                                 | 标准使用示例                                                 |
| :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| `create '表名', '列族1', '列族2', ...` <br> `create '命名空间:表名', {NAME => '列族名', 属性 => 值}` | 创建HBase表，**必须指定至少一个列族**，支持自定义列族版本数、TTL、压缩算法等属性 | 极简版：`create 'user', 'info', 'contact'` <br> 高级版：`create 'ns_business:order', {NAME => 'detail', VERSIONS => 3, TTL => 2592000}` |
| `list`                                                       | 列出default默认命名空间下的所有用户表                        | `list`                                                       |
| `describe '表名'` / `desc '表名'`                            | 查看表的完整结构，包括列族配置、属性、预分区信息             | `desc 'user'`                                                |
| `exists '表名'`                                              | 判断指定表是否存在于集群中                                   | `exists 'user'`                                              |
| `disable '表名'`                                             | 禁用表（修改表结构、删除表前**必须先执行禁用**）             | `disable 'user'`                                             |
| `enable '表名'`                                              | 启用被禁用的表，恢复读写能力                                 | `enable 'user'`                                              |
| `is_disabled '表名'` / `is_enabled '表名'`                   | 查看表当前的禁用/启用状态                                    | `is_disabled 'user'`                                         |
| `alter '表名', {NAME => '列族名', 属性 => 新值}`             | 修改表或列族的配置，支持新增/删除列族、修改版本数、TTL、压缩规则等 | `alter 'user', {NAME => 'info', VERSIONS => 5}`              |
| `drop '表名'`                                                | 删除表，**仅能删除已禁用的表**                               | `drop 'user'`                                                |
| `truncate '表名'`                                            | 清空表全量数据，自动执行「禁用→删除→重建表」，**会丢失原表的预分区配置** | `truncate 'user'`                                            |
| `truncate_preserve '表名'`                                   | 清空表全量数据，同时保留原表的预分区配置                     | `truncate_preserve 'order'`                                  |

#### 练习

##### 创建`Student`表

两个列族`Info`和`Score`：

- 列族`Info`的数据在读取时关闭缓存`BLOCKCACHE`。

- 列族`Score`内的数据保留2个版本`VERSIONS`

```ruby
create 'Student',
{NAME=>'Info',BLOCKCACHE=>'false'},
{NAME=>'Score',VERSIONS=>2}
```

> **BLOCKCACHE** 是 HBase 的**读缓存**，作用是把刚读取过的数据块缓存在内存里，下次读相同数据直接从内存取，不用读磁盘，提升读速度。



##### 查看`Student`表结构

```ruby

```

##### 查看`HBase`中已有的表

```ruby

```

```sql
TABLE                                                                     
Student                                                         
Teacher                                                
2 row(s) in 0.0240 seconds
=> ["Student", "Teacher"]
```

##### 禁用表`Teacher`

```ruby

```

##### 判断表`Teacher`是否被禁用

```shell
      
```

##### 删除表`Teacher`

```ruby

```

##### 判断表`Teacher`是否还存在

```ruby

```

Table Teacher does not exist

##### 修改`Student`表，列族` Score` 内的数据保留`3`个版本

```ruby

```

查看表结构，验证是否修改成功。

```
```



##### 修改`Student`表，增加一个列族`hobby`

```ruby

```

查看表结构，验证是否修改成功。

```
```

##### 修改`Student`表，删除列族`hobby`

```shell
alter 'Student',
{NAME=>'hobby',
METHOD=>'delete'
}
```

查看表结构，验证是否修改成功。

```
```



### 三、数据读写DML操作命令

用于单行数据的写入、查询、删除操作，是HBase数据读写的核心基础命令。

| 命令语法                                                     | 核心功能说明                                                 | 标准使用示例                                                 |
| :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| `put '表名', '行键RowKey', '列族:列名', '值' [, 时间戳]`     | 写入/更新一个单元格数据，重复对同一单元格执行put为更新操作   | `put 'user', '001', 'info:name', '张三'`                     |
| `get '表名', '行键' [, {COLUMNS => ['列族:列名'], VERSIONS => 版本数}]` | 查询指定RowKey的整行数据，也可指定列、返回历史版本数精准查询 | 全行查询：`get 'user', '001'` <br> 精准查询：`get 'user', '001', {COLUMNS => ['info:name'], VERSIONS => 3}` |
| `delete '表名', '行键', '列族:列名' [, 时间戳]`              | 删除指定列的单个/指定版本数据，**不会删除整行**              | `delete 'user', '001', 'info:age'`                           |
| `deleteall '表名', '行键'`                                   | 删除指定RowKey的整行所有列数据                               | `deleteall 'user', '001'`                                    |

### 四、数据扫描与统计操作命令

用于范围扫描、全表扫描、行数统计等批量数据查询与统计操作，支持丰富的过滤条件。

| 命令语法                                                     | 核心功能说明                                      | 标准使用示例                                                 |
| :----------------------------------------------------------- | :------------------------------------------------ | :----------------------------------------------------------- |
| `scan '表名'`                                                | 全表扫描，返回表中所有数据                        | `scan 'user'`                                                |
| `scan '表名', {COLUMNS => ['列族:列名1', '列族:列名2']}`     | 扫描并仅返回指定列的数据                          | `scan 'user', {COLUMNS => ['info:name', 'contact:phone']}`   |
| `scan '表名', {STARTROW => '起始行键', STOPROW => '终止行键'}` | 按行键范围扫描，规则为**左闭右开**                | `scan 'user', {STARTROW => '001', STOPROW => '010'}`         |
| `scan '表名', {LIMIT => 行数}`                               | 限制扫描返回的行数，避免全表扫描溢出              | `scan 'user', {LIMIT => 5}`                                  |
| `scan '表名', {VERSIONS => 版本数}`                          | 扫描并返回数据的多个历史版本                      | `scan 'user', {VERSIONS => 3}`                               |
| `scan '表名', {TIMERANGE => [起始时间戳, 终止时间戳]}`       | 按数据写入的时间戳范围扫描                        | `scan 'user', {TIMERANGE => [1713542400000, 1713628800000]}` |
| `count '表名' [, CACHE => 缓存行数]`                         | 统计表的总行数，大表场景建议设置CACHE提升扫描速度 | `count 'user', CACHE => 1000`                                |



#### 期末考试数据读写

将以下同学的期末考试成绩存入`Student`表，然后查询全表。

<table>
   <tr>
      <td rowspan="2">No</td>
      <td colspan="2">Info</td>
      <td colspan="3">Score</td>
   </tr>
   <tr>
      <td>name</td>
      <td>age</td>
      <td>Hadoop</td>
      <td>HBase</td>
      <td>Spark</td>
   </tr>
   <tr>
      <td>001</td>
      <td>qiaofeng</td>
      <td>30</td>
      <td>93</td>
      <td>85</td>
      <td>70</td>
   </tr>
   <tr>
      <td>002</td>
      <td>duanyu</td>
      <td>27</td>
      <td>95</td>
      <td>98</td>
      <td>50</td>
   </tr>
   <tr>
      <td>003</td>
      <td>wangyuyan</td>
      <td>18</td>
      <td>95</td>
      <td>97</td>
      <td>92</td>
   </tr
</table>
##### 插入数据

```shell
put 'Student','001','Info:name','qiaofeng'
... ...
... ...
```

##### 全表查询

```shell

```



##### 补考

段誉补考了一次`Spark`，老师给登记了`55`分。

```ruby
put 'Student','002','Score:Spark','55'
```

段誉登录学校教务系统，查询一下`002个人信息和成绩`

```ruby

```

后来段誉动了歪脑筋，托关系走后门，获得了一次补考机会。结果事与愿违，老师登记补考成绩`56`分。

```ruby

```

段誉又去查询了一下`个人成绩`

```ruby

```

没错，又挂了。

##### 重修

经过两次补考，认真重修了`Spark`，最终老师批阅试卷，登记了`98`分

```ruby

```

段誉登录教务系统查询了一下自己`Spark单科成绩`。

```ruby

```

后来他回顾了一下`Spark历史成绩`（查询002用户Spark课程的历史成绩）

```
```



```sql
COLUMN                                      CELL    
 Score:Spark                                timestamp=1648557259939, value=98   
 Score:Spark                                timestamp=1648556808780, value=56    
 Score:Spark                                timestamp=1648556643468, value=55
```



##### 教务老师

查询所有同学的个人信息(Info) （**列族**）

```sql

```

```sql
ROW                 COLUMN+CELL                        
 001                column=Info:age, timestamp=1648555932178, value=30
 001                column=Info:name, timestamp=1648555865078, value=qiaofeng
 002                column=Info:age, timestamp=1648555981987, value=27 
 002                column=Info:name, timestamp=1648555873577, value=duanyu 
 003                column=Info:age, timestamp=1648555988871, value=18
 003                column=Info:name, timestamp=1648555884874, value=wangyuyan   
```



查看所有同学的Hadoop成绩(Scoe:Hadoop) （**列**）

```ruby

```

```sql
ROW                  COLUMN+CELL
 001                 column=Score:Hadoop, timestamp=1648556188482, value=93
 002                 column=Score:Hadoop, timestamp=1648556200639, value=95
 003                 column=Score:Hadoop, timestamp=1648556207324, value=95
```



查询所有同学的姓名(Info:name)和各科成绩(Score) （**列与列族混查**）

```ruby

```

```sql
ROW                COLUMN+CELL                                          
 001               column=Info:name, timestamp=1648555865078, value=qiaofeng
 001               column=Score:Hadoop, timestamp=1648556188482, value=93
 001               column=Score:Hbase, timestamp=1648556219092, value=85
 001               column=Score:Spark, timestamp=1648556262488, value=70
 002               column=Info:name, timestamp=1648555873577, value=duanyu
 002               column=Score:Hadoop, timestamp=1648556200639, value=95
 002               column=Score:Hbase, timestamp=1648556226943, value=98
 002               column=Score:Spark, timestamp=1648557259939, value=98
 003               column=Info:name, timestamp=1648555884874, value=wangyuyan
 003               column=Score:Hadoop, timestamp=1648556207324, value=95
 003               column=Score:Hbase, timestamp=1648556249759, value=97
 003               column=Score:Spark, timestamp=1648556278852, value=92
```



查询前两名同学的姓名(Info:name)和各科成绩(Score) (**列、列族、行键多条件查询**)

```ruby

```

```sql
ROW                   COLUMN+CELL                                    
 001                  column=Info:name, timestamp=1648555865078, value=qiaofeng
 001                  column=Score:Hadoop, timestamp=1648556188482, value=93
 001                  column=Score:Hbase, timestamp=1648556219092, value=85
 001                  column=Score:Spark, timestamp=1648556262488, value=70
 002                  column=Info:name, timestamp=1648555873577, value=duanyu
 002                  column=Score:Hadoop, timestamp=1648556200639, value=95
 002                  column=Score:Hbase, timestamp=1648556226943, value=98 
 002                  column=Score:Spark, timestamp=1648557259939, value=98
```



##### 删除

删除乔峰的Hadoop成绩，

```ruby

```

查询一下是否删除成功。

```

```

```sql
COLUMN                                      CELL   
 Score:Hbase                                timestamp=1648556219092, value=85 
 Score:Spark                                timestamp=1648556262488, value=70
```



查询段誉三次Spark成绩，删除段誉第一次补考成绩，再次查询段誉的三次成绩。

##### 查询三次历史成绩

```sql
```

```sql
COLUMN                                      CELL         
 Score:Spark                                timestamp=1648557259939, value=98
 Score:Spark                                timestamp=1648556808780, value=56
 Score:Spark                                timestamp=1648556643468, value=55
```

##### 删除第一次补考成绩

```sql
```

##### 再次查询三次历史成绩

```

```

```ruby
COLUMN                                      CELL                              
 Score:Spark                                timestamp=1648557259939, value=98
 Score:Spark                                timestamp=1648556808780, value=56 
 Score:Spark                                timestamp=1648556271299, value=50 
```



##### 删除王语嫣整条记录

```ruby

```

##### 退出 - exit

```ruby
hbase(main):014:0> exit
```