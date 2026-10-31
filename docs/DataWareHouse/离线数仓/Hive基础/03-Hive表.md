---
marp: true
headingDivider: 6
theme: python-mini-pptx
title: Hive表
date: 2022-10-14 09:55:26
categories:
- Hive
keywords:
- Hive内部表
- Hive外部表
- Hive分区表
- Hive桶表
- Hive视图
- HiveServer2
- Beeline
---

# Hive表

这一节对比 Hive 的几种**表类型与数据组织方式**：内部表 / 外部表、分区表、分桶表，以及视图。先准备三份相同的输入数据：

## 数据准备

```shell
[zhangsan@node0 ~]$ hdfs dfs -mkdir /input1
[zhangsan@node0 ~]$ hdfs dfs -mkdir /input2
[zhangsan@node0 ~]$ hdfs dfs -mkdir /input3
[zhangsan@node0 ~]$ hdfs dfs -put emp.csv dept.csv /input1
[zhangsan@node0 ~]$ hdfs dfs -put emp.csv dept.csv /input2
[zhangsan@node0 ~]$ hdfs dfs -put emp.csv dept.csv /input3
```

## 内部表

内部表（Managed Table）由 Hive **同时管理元数据和数据**：删除表时，数据和元数据一起被删，数据不可恢复。

- 源文件和目标文件夹在同一个文件系统中、且 `LOAD` 不带 `LOCAL` 时，加载后**原文件会移动到**目标文件夹（仓库目录）；

### 加载员工表

#### 创建表并加载数据

```sql
hive (default)> CREATE TABLE emp (
    empno int,
    ename string,
    job string,
    mgr int,
    hiredate string,
    sal int,
    comm int,
    deptno int) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';

hive (default)> LOAD DATA inpath '/input1/emp.csv' INTO TABLE emp;
```

#### 查看加载结果

```sql
hive (default)> SELECT *
FROM emp;
```



### 加载部门表

#### 创建表并加载数据

```sql
hive (default)> CREATE TABLE dept(
    deptno int,
    dname string,
    loc string) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';

-- hdfs
hive (default)> LOAD DATA inpath '/input1/dept.csv' INTO TABLE dept;
```

#### 查看加载结果

```sql
hive (default)>  SELECT *
FROM dept;
OK
dept.deptno	dept.dname	dept.loc
10	ACCOUNTING	NEW YARK
20	RESEARCH	DALLAS
30	SALES	CHICAGO
40	OPERATIONS	BOSTON
Time taken: 0.206 seconds, Fetched: 8 row(s)
```



### Local关键字

- 如果带 `LOCAL` 关键字，源文件只会**拷贝**本地 Linux 文件系统中的文件到目标文件夹（原文件保留）。

```mysql
hive (default)> CREATE TABLE emp1(
    empno int,
    ename string,
    job string,
    mgr int,
    hiredate string,
    sal int,
    comm int,
    deptno int) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';

-- linux file system
hive (default)> LOAD DATA LOCAL inpath '/home/zhangsan/emp.csv' 
INTO TABLE emp1;

hive (default)> SELECT *
FROM emp1;
```

##### Linux 本地仍存在原文件

```sql
-rw-rw-r--.  1 zhangsan zhangsan       615 Jul  2 18:12 emp.csv
```





## 外部表

外部表（External Table）的**数据在 HDFS 上本来就存在**，Hive 只在上面"挂"一个链接：

- 它与内部表的**元数据组织完全相同**，差异只在数据的存储归属；
- 建表和加载一步完成（`LOCATION` 指向已有目录），数据不会挪动，只是**与外部数据建立一个链接**；
- **删外部表只删元数据链接、不删数据**——适合多人共享、或不想因误删表而丢掉原始数据的场景。

**HIVE表**与**实际数据**的对应关系，记录在 `MySQL - hive 库 - TBLS, SDS` 等元数据库表中。

### 创建外部表

```sql
hive (default)> 
create EXTERNAL table 
emp_ext(empno int,
        ename string,
        job string,
        mgr int,
        hiredate string,
        sal int,
        comm int,
        deptno int) 
row format delimited fields terminated by ',' location '/input3/';
```

>   需要注意：location需要是目录。

### 查询外部表

```hive
hive (default)>  SELECT *
FROM emp_ext;
OK
emp_ext.empno	emp_ext.ename	emp_ext.job	emp_ext.mgr	emp_ext.hiredate       emp_ext.sal	emp_ext.comm	emp_ext.deptno
10	ACCOUNTING	NEW YARK	NULL	NULL	NULL	NULL	NULL
20	RESEARCH	DALLAS	NULL	NULL	NULL	NULL	NULL
30	SALES	CHICAGO	NULL	NULL	NULL	NULL	NULL
40	OPERATIONS	BOSTON	NULL	NULL	NULL	NULL	NULL

7369	SMITH	CLERK	7902	1980/12/17	800	NULL	20
7499	ALLEN	SALESMAN	7698	1981/2/20	1600	300	30
7521	WARD	SALESMAN	7698	1981/2/22	1250	500	30
7566	JONES	MANAGER	7839	1981/4/2	2975	NULL	20
7654	MARTIN	SALESMAN	7698	1981/9/28	1250	1400	30
7698	BLAKE	MANAGER	7839	1981/5/1	2850	NULL	30
7782	CLARK	MANAGER	7839	1981/6/9	2450	NULL	10
7788	SCOTT	ANALYST	7566	1987/4/19	3000	NULL	20
7839	KING	PRESIDENT	NULL	1981/11/17	5000	NULL	10
7844	TURNER	SALESMAN	7698	1981/9/8	1500	0	30
7876	ADAMS	CLERK	7788	1987/5/23	1100	NULL	20
7900	JAMES	CLERK	7698	1981/12/3	950	NULL	30
7902	FORD	ANALYST	7566	1981/12/3	3000	NULL	20
7934	MILLER	CLERK	7782	1982/1/23	1300	NULL	10
Time taken: 0.225 seconds, Fetched: 18 row(s)

```

## 分区表

分区是把大表按某列（如部门号）**切成多个子目录**来存：`deptno=10`、`deptno=20`、`deptno=30` 各是一个目录。查询时若带了分区条件，Hive 只扫对应目录（**分区裁剪**），跳过其余目录，性能更好。

### 准备数据

准备一个只含 10 号部门员工的本地文件 `emp10.csv`：

Linux本地文件 `emp10.csv`

```sql
7782,CLARK,MANAGER,7839,1981/6/9,2450,,10
```

### 创建分区表

根据员工的部门号创建分区

```sql
CREATE TABLE emp_part(
    empno int,
    ename string,
    job string,
    mgr int,
    hiredate string,
    sal int,
    comm int) PARTITIONED BY (deptno int) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';
```

### 向分区表插入数据

往分区表中插入数据：指明导入的数据的分区（通过子查询导入数据） ----> MapReduce程序

```shell
hive (default)> load data local inpath '/home/zhangsan/emp10.csv' 
into table emp_part partition(deptno=10); 

hive (default)> select * from emp_part;
```

### 通过子查询加载到分区表

注意：用 `INSERT ... SELECT` 往分区表灌数据会真正跑 **MapReduce**（下面三次，对应三个分区），需要 YARN 已启动。

```sql
INSERT INTO TABLE emp_part partition(deptno=10)
SELECT empno,
       ename,
       job,
       mgr,
       hiredate,
       sal,
       comm
FROM emp1
WHERE deptno=10;
INSERT INTO TABLE emp_part partition(deptno=20)
SELECT empno,
       ename,
       job,
       mgr,
       hiredate,
       sal,
       comm
FROM emp1
WHERE deptno=20;
INSERT INTO TABLE emp_part partition(deptno=30)
SELECT empno,
       ename,
       job,
       mgr,
       hiredate,
       sal,
       comm
FROM emp1
WHERE deptno=30;
```

### 查看HDFS

```shell
[zhangsan@node0 ~]$ hdfs dfs -ls /user/hive/warehouse/emp_part
Found 3 items
drwx-wx-wx   - zhangsan supergroup          0 2022-05-16 08:26 /user/hive/warehouse/emp_part/deptno=10
drwx-wx-wx   - zhangsan supergroup          0 2022-05-16 08:26 /user/hive/warehouse/emp_part/deptno=20
drwx-wx-wx   - zhangsan supergroup          0 2022-05-16 08:27 /user/hive/warehouse/emp_part/deptno=30
```

## 桶表

分桶（Bucket）是对指定列做**哈希**，把数据打散进固定数量的文件（`INTO N BUCKETS`）。它和分区的区别：

- 分区是"按列值切目录"
- 分桶是"按哈希切文件"。
- 分区不依赖MapReduce的Partitioner， 分桶依赖Partitioner。

桶常用于**高效采样**（按比例抽桶）和 **Map 端 Join**（按连接键分桶可避免 shuffle）。

#### 开启分桶

先开强制分桶，再建表并灌数据（插入会触发 MapReduce）：

```mysql
hive (default)> SET hive.enforce.bucketing = TRUE;

# 创建一个桶表，根据员工的部门编号（deptno）进行分桶
hive (default)> CREATE TABLE emp_deptno_bucket(
    empno int,
    ename string,
    job string,
    mgr int,
    hiredate string,
    sal int,
    comm int,
    deptno int) CLUSTERED BY (deptno) INTO 3 BUCKETS 
    ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';

# 通过子查询插入数据
hive (default)> INSERT INTO emp_deptno_bucket
SELECT *
FROM emp1;
```

>   insert 语句会触发MapReduce，可在YARN中观察到YARN Application状态。

#### 相关日志

```shell
Starting Job = job_1716805761992_0005, Tracking URL = http://node1:8088/proxy/application_1716805761992_0005/
Kill Command = /opt/bigdata/hadoop/default/bin/hadoop job  -kill job_1716805761992_0005
Hadoop job information for Stage-1: number of mappers: 1; number of reducers: 3
2024-05-28 06:06:06,094 Stage-1 map = 0%,  reduce = 0%
2024-05-28 06:06:17,166 Stage-1 map = 100%,  reduce = 0%, Cumulative CPU 3.54 sec
2024-05-28 06:06:39,948 Stage-1 map = 100%,  reduce = 22%, Cumulative CPU 7.09 sec
2024-05-28 06:06:41,206 Stage-1 map = 100%,  reduce = 44%, Cumulative CPU 10.68 sec
2024-05-28 06:06:42,481 Stage-1 map = 100%,  reduce = 56%, Cumulative CPU 12.48 sec
2024-05-28 06:06:44,720 Stage-1 map = 100%,  reduce = 89%, Cumulative CPU 17.84 sec
2024-05-28 06:06:45,859 Stage-1 map = 100%,  reduce = 100%, Cumulative CPU 19.6 sec
MapReduce Total cumulative CPU time: 19 seconds 600 msec
Ended Job = job_1716805761992_0005
Loading data to table default.emp_deptno_bucket
MapReduce Jobs Launched:
Stage-Stage-1: Map: 1  Reduce: 3   Cumulative CPU: 19.6 sec   HDFS Read: 20864 HDFS Write: 871 SUCCESS
Total MapReduce CPU Time Spent: 19 seconds 600 msec
OK
emp1.empno      emp1.ename      emp1.job        emp1.mgr        emp1.hiredate   emp1.sal   emp1.comm        emp1.deptno
Time taken: 63.952 seconds
```



## 视图

视图不存数据，只存一条 SQL 定义；每次查询视图，都等于现执行那条定义 SQL。

-   视图是一种**虚表**，是一个**逻辑概念**；可以跨越多张表

-   视图建立在已有表的基础上, 视图赖以建立的这些表称为基表

-   视图可以简化复杂的查询，但不能提高查询的效率

```mysql
hive (default)> CREATE VIEW myview AS
SELECT dept.dname,
       emp.ename
FROM emp,
     dept
WHERE emp.deptno=dept.deptno;
OK
dname	ename
Time taken: 0.186 seconds
hive (default)> SELECT *
FROM myview;
```

### 查询

下面用 `emp` / `dept` 两张内部表演示 Hive 的关联与条件表达式。

#### 	内连接：查询部门名称、员工名字

```sql
SELECT dept.dname,
       emp.ename
FROM emp,
     dept
WHERE emp.deptno=dept.deptno;
```

##### 查询结果

```mysql
dept.dname	emp.ename
RESEARCH	SMITH
SALES	ALLEN
SALES	WARD
RESEARCH	JONES
SALES	MARTIN
SALES	BLAKE
ACCOUNTING	CLARK
RESEARCH	SCOTT
ACCOUNTING	KING
SALES	TURNER
RESEARCH	ADAMS
SALES	JAMES
RESEARCH	FORD
ACCOUNTING	MILLER
```

#### 做报表，根据职位给员工涨工资：

用 `CASE WHEN` 按职位算涨幅（总裁 +1000、经理 +800、其余 +400），在一行里同时列出涨前 `sal` 与涨后结果：

```sql
PRESIDENT  1000
MANAGER    800
其他       400
```

#### 把涨前、涨后的薪水显示出来

```mysql
hive (default)> SELECT empno,
       ename,
       job,
       sal,
       CASE job
           WHEN 'PRESIDENT' THEN sal+1000
           WHEN 'MANAGER' THEN sal+800
           ELSE sal+400
       END
FROM emp;
```

##### 查询结果

```sql
empno   ename   job     sal     _c4
7369    SMITH   CLERK   800     1200
7499    ALLEN   SALESMAN        1600    2000
7521    WARD    SALESMAN        1250    1650
7566    JONES   MANAGER 2975    3775
7654    MARTIN  SALESMAN        1250    1650
7698    BLAKE   MANAGER 2850    3650
7782    CLARK   MANAGER 2450    3250
7788    SCOTT   ANALYST 3000    3400
7839    KING    PRESIDENT       5000    6000
7844    TURNER   SALESMAN        1500    1900
7876    ADAMS   CLERK   1100    1500
7900    JAMES   CLERK   950     1350
7902    FORD   ANALYST 3000    3400
7934    MILLER  CLERK   1300    1700
Time taken: 16.229 seconds, Fetched: 14 row(s)
```
