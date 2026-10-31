# 实验：员工工资对象序列化

> 配套教程：4-3-1 ~ 4-3-6，以及「部门工资总额」实训。
> 上次做部门工资总额时，map 输出的 value 是一个 `IntWritable(工资)`——一行数据里我们只用到了一个字段。
> 这次把整行员工记录都装进对象里传，顺其自然地体会**自定义 Writable 存在的理由**。

## 一、实验目的

1. 把上一轮的部门工资实验升级为对象序列化版本，理解从 `IntWritable` 到自定义 `Writable` 的动机；
2. 实现 `EmployeeWritable`，处理「字段可能为空」的真实数据（`comm` 奖金字段经常为空）；
3. 在 Reducer 中同时使用对象里的多个字段（工资、奖金），完成单个 `IntWritable` 做不到的统计。

## 二、实验环境

- JDK 8、Maven 工程（依赖 hadoop-client 3.1.3）
- Windows 本地模式即可运行（`winutils.exe` 已配置）

## 三、数据回顾：emp 表

沿用部门工资总额实验用过的员工数据 `data/mapred/emps.txt`（8 个字段，逗号分隔）：

```csv
empno,ename,job,mgr,hiredate,sal,comm,deptno
7369,SMITH,CLERK,7902,1980/12/17,800,,20
7499,ALLEN,SALESMAN,7698,1981/2/20,1600,300,30
7521,WARD,SALESMAN,7698,1981/2/22,1250,500,30
7566,JONES,MANAGER,7839,1981/4/2,2975,,20
7654,MARTIN,SALESMAN,7698,1981/9/28,1250,1400,30
7698,BLAKE,MANAGER,7839,1981/5/1,2850,,30
7782,CLARK,MANAGER,7839,1981/6/9,2450,,10
7788,SCOTT,ANALYST,7566,1987/4/19,3000,,20
7839,KING,PRESIDENT,,1981/11/17,5000,,10
7844,TURNER,SALESMAN,7698,1981/9/8,1500,0,30
7876,ADAMS,CLERK,7788,1987/5/23,1100,,20
7900,JAMES,CLERK,7698,1981/12/3,950,,30
7902,FORD,ANALYST,7566,1981/12/3,3000,,20
7934,MILLER,CLERK,7782,1982/1/23,1300,,10
```

字段含义对照（下标从 0 开始）：

| 下标 | 字段 | 含义 |
|---|---|---|
| 0 | empno | 员工编号 |
| 1 | ename | 姓名 |
| 5 | sal | 工资 |
| 6 | comm | 奖金（**可能为空**） |
| 7 | deptno | 部门编号 |

注意第 1 行是表头、多数员工没有奖金（第 6 列为空串）——这两点都会在代码里处理。

## 四、实验一：EmployeeWritable 本地序列化

### 4.1 定义 EmployeeWritable

这次不选全部 8 个字段——**Writable 只序列化业务需要的字段**（对比 4-3-3 篇 `Serializable` 连字段带元数据全搬的做法）。我们选 5 个：

`empno`（int）、`ename`（String）、`sal`（int）、`comm`（int）、`deptno`（int）。

在 `entity` 包里新建（对照 4-3-6 篇 ComputerWritable 的六步）：

```java
# TODO
    
    
```

### 4.2 写出去、读回来

仿照 4-3-6 篇，用 emp 表第一行 SMITH 验证：

```java
# TODO
    
    
```

预期输出：

```
EmployeeWritable{empno=7369, ename='SMITH', sal=800, comm=0, deptno=20}
```

执行结果

```
# 截图



```

想一想：`comm` 我们传的是 `0`，不是「空」。**Writable 的字段类型是定死的，没有「空」这个状态**——缺失数据必须在进 Mapper 时兜底，这是和数据库 NULL 最大的区别。

## 五、实验二：MapReduce——按部门统计工资与奖金

### 5.1 业务背景：为什么 value 要换成对象

上一轮部门工资实验里，Reduce 只需要 `sal` 一个字段，`IntWritable` 够用。
现在需求升级为：**按部门统计 人数、工资合计、奖金合计**。

一条记录要同时带 `sal` 和 `comm` 两个字段过去，`IntWritable` 装不下了——这正是自定义 Writable 的用武之地：**map 输出的 value 从「一个数」变成「一条结构化记录」**。

### 5.2 Mapper

```java
# TODO
    


```

三个容易踩的坑，注释里都点了：

1. **表头行**：`empno` 解析不出数字，用正则挡掉；
2. **comm 为空**：`Integer.parseInt("")` 直接异常，空串兜底成 0（相当于 SQL 里的 `COALESCE(comm, 0)`）；
3. **对象复用**：`outValue` 在成员位置只 new 一次，每行重新 `set`——和 4-3-5 篇讲的一致。

### 5.3 Reducer

```java
# TODO
    
    
    
```

### 5.4 Driver

完整类（放 `cserializable` 包，输入 `data/mapred/emps.txt`）：

```java
# TODO
    
    
    
    
    
```

### 5.5 预期结果

`data/mapred/output-employee/part-r-00000`（按部门号排序）：

```
10    3 人, 工资合计=8750, 奖金合计=0
20    5 人, 工资合计=10875, 奖金合计=0
30    6 人, 工资合计=9400, 奖金合计=2200
```

实验截图

```
# 截图 




```



自检：3+5+6 = 14 名员工，与数据行数一致；只有 30 部门（销售）有奖金，合计 300+500+1400 = 2200。

## 六、思考题

如果需求只统计「每部门工资合计」，上一轮的 `IntWritable` 版本就够。对比两个版本，说说自定义 Writable 引入了哪些成本（代码量、序列化体积），换来什么？
