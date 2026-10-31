---
marp: true
headingDivider: 6
theme: python-mini-pptx
paginate: true
title: Hive数据类型
date: 2022-10-14 09:55:26
categories:
- Hive
keywords:
- Hive数据类型
- Hive复杂类型
- Array
- Map
- Struct
---

# Hive数据类型

下面用一张 `student` 表演示 Hive 对**复杂类型**的支持：除了常见的 `BIGINT`/`STRING`，还能用 `ARRAY`、`MAP`、`STRUCT` 表达"一个字段里套多个值"，非常适合半结构化数据。列设计如下：

### 表设计

| 字段     | 类型                | 示例值                                                       | 说明                        |
| -------- | ------------------- | ------------------------------------------------------------ | --------------------------- |
| 编号     | `Bigint`            | `1`                                                          |                             |
| 姓名     | `CHAR(10)`          | `张三`                                                       |                             |
| 年龄     | `Tinyint`           | `18`                                                         |                             |
| 爱好     | `Array<CHAR(4)>`    | `篮球`                                                       | 数组，每个元素为 `CHAR(4)`  |
|          |                     | `羽毛球`                                                     |                             |
|          |                     | `足球`                                                       |                             |
| 成绩     | `Map<CHAR(2), INT>` | `语文: 70`<br>`数学: 80`<br>`英语: 90`                       | Map，键为 `CHAR(2)`         |

---

| 字段     | 类型                | 示例值                                                       | 说明                        |
| -------- | ------------------- | ------------------------------------------------------------ | --------------------------- |
| 联系地址 | `Struct`            | `province: 山东省`<br>`city: 泰安市`<br>`district: 高新区`<br>`street: 正阳门大街66号` | `province` 为 `VARCHAR(20)` |
| 入学日期 | `Date`              | `2020-09-01`                                                 |                             |
| 余额     | `Decimal`           | `100.19`                                                     |                             |
| 个人介绍 | `String`            | -                                                            |                             |
| 是否在校 | `Boolean`           | `true`                                                       |                             |

### 表创建

建表时除了列类型，还要用 `ROW FORMAT DELIMITED` 声明**文本文件怎么解析**：字段之间、集合元素之间、Map 的 k/v 之间各用什么分隔。下面的分隔符必须和后面 `stu.txt` 的内容一一对应，否则读出来是 `NULL` 或错位。

```sql
create table student(
id BIGINT comment '编号',
name char(6) comment '姓名', --定长字符串，超长就被截断，在MySQL中超长报错。
age tinyint comment '年龄', -- 1 byte
hobby Array<char(4)> comment '兴趣', 
score Map<Char(2),TINYINT> comment '成绩',
address Struct<province:varchar(10),city:varchar(10),district:varchar(10),street:varchar(10)>  comment '地址',
enterdate Date comment '入学年龄', --不符合规则，null
balance DECIMAL comment '校园卡余额',
intro string comment '个人介绍',
status boolean comment '是否在校') --不符合规则，null
row format delimited fields TERMINATED by ','
collection items TERMINATED by '-'
map keys TERMINATED by ':'
lines TERMINATED by '\n'
stored as textfile;
```

---



```sql
enterdate Date comment '入学年龄', --不符合规则，null
balance DECIMAL comment '校园卡余额',
intro string comment '个人介绍',
status boolean comment '是否在校') --不符合规则，null
row format delimited fields TERMINATED by ','
collection items TERMINATED by '-'
map keys TERMINATED by ':'
lines TERMINATED by '\n'
stored as textfile;
```



### stu.txt

数据文件的分隔方式必须与上面的建表声明对应：字段用 `,`、集合元素用 `-`、Map 的键与值用 `:`、行用换行。

```sql
1,张三,22,游泳-乒乓球,语文:90-数学:80-英语:70,山东省-泰安市-高新区-正阳门大街,2018-09-01,100.19,好好学习天天向上,True
2,李四,21,足球-太极拳-篮球,语文:80-数学:80,山东省-济南市-长清区-舜耕路,2019-09-01,2000.00,学而时习之，不亦说乎,True
3,王五,20,足球-乒乓球-网球,语文:99-数学:98-英语:97,山东省-北京市-海淀区,2020-09-01,1000.00,士不可以不弘毅，任重而道远,False
```

### load data

`LOAD DATA` 把数据文件"搬"进表对应的 HDFS 目录。`LOCAL` 表示源在 **Linux 本地文件系统**（会上传），去掉 `LOCAL` 则源在 **HDFS**（只移动）。`OVERWRITE` 会先清空再写入。

```sql
hive (default)> load data local inpath '/home/zhangsan/stu.txt' overwrite into table student;
```

> 提示：`exit;` 或 `quit;` 可退出 Hive CLI。

### HDFS

`LOAD DATA LOCAL` 之后，文件其实被上传到了 Hive 的仓库目录 `/user/hive/warehouse/student/`。用 `hdfs dfs -ls -R /user/hive` 可以确认：

```sql
[zhangsan@node0 ~]$ hdfs dfs -ls -R /user/hive
drwxr-xr-x   - zhangsan supergroup          0 2025-10-13 00:36 /user/hive/warehouse
drwxr-xr-x   - zhangsan supergroup          0 2025-10-13 00:37 /user/hive/warehouse/student
-rwxr-xr-x   1 zhangsan supergroup        465 2025-10-13 00:37 /user/hive/warehouse/student/stu.txt
```

##### 使用指定的用户浏览HDFS网页

HDFS Web 页面（9870）默认以静态用户 `dr.who` 浏览，可能没权限看到 `/user/hive` 下 zhangsan 的文件。在 `core-site.xml` 把 `hadoop.http.staticuser.user` 设成 `zhangsan`，刷新后即可用该用户身份查看：

```xml
    <property>
        <name>hadoop.http.staticuser.user</name>
        <value>zhangsan</value>
    </property>
```

### 查询

Hive 访问复杂类型的语法：`ARRAY` 用下标 `col[i]`（从 0 开始），`MAP` 用 `col['key']`，`STRUCT` 用 `col.field`。

```sql
hive (default)> select * from student;

-- 数组
hive (default)> select hobby,hobby[0],hobby[1],hobby[2] from student;

-- Map
hive (default)> select score['语文'], score['数学'], score['英语'] from student;

-- struct
hive (default)> select address, address.province, address.city, address.district, address.street from student;
```
