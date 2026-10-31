---
theme: python-mini-pptx
paginate: true
headingDivider: 5
title: Hadoop MapReduce 分组汇总
date: 2026-09-13 15:00:00
categories:
- Hadoop
tags:
- Hadoop
- MapReduce
- GroupBy
---

<div class="cover"><h1>分组汇总</h1><p>把明细压成统计值</p></div>

## 案例概览

本案例统计**每个部门的工资总额**，把 14 行员工明细压成 3 行部门汇总。

### 业务问题

员工表是一行一个员工的明细。报表要的是"每个部门总共发多少工资"——粒度从"员工"提升到"部门"。这是 MapReduce 最经典的用法，也是理解一切聚合类需求的起点。

### 输入数据与预期输出

#### 输出数据

输入 `emp.csv`，14 行，工资在第 6 列、部门号在第 8 列：

```csv
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

#### 预期输出

预期输出 3 行 `<部门号, 工资总额>`：

| 部门号 | 工资总额 | 人数 | 验算 |
|---|---|---|---|
| 10 | 8750 | 3 | 1300 + 2450 + 5000 |
| 20 | 10875 | 5 | 800 + 1100 + 2975 + 3000 + 3000 |
| 30 | 9400 | 6 | 950 + 1250 + 1250 + 1500 + 1600 + 2850 |



## 简要分析

汇总类需求看起来千变万化，但落到代码上只有三个决定：谁当 key、在哪累加、能不能提前合并。

### 分组键

Reduce 的每次调用对应一个 key。所以"按部门汇总"和"按岗位汇总"的差别，仅仅是把部门号换成岗位名：

| 需求 | Map 输出的 key | 输出的组数 |
|---|---|---|
| 按部门汇总 | 部门号（第 8 列） | 3 |
| 按岗位汇总 | 岗位名（第 3 列） | 5 |
| 按部门+岗位汇总 | 两者拼接 | 9 |

分组键是唯一需要仔细设计的部分，其余代码几乎不变。判断 key 选得对不对，看一个问题就够了：**同一个组的数据，是否都拥有相同的 key**。



### 字段下标

`split(",")` 之后按下标取值，下标数错一位就会得到完全错的结果，而且**不一定报错**。本案例用到的两个下标是：

| 字段 | 列号 | 下标 |
|---|---|---|
| 工资 | 第 6 列 | 5 |
| 部门号 | 第 8 列 | 7 |

因为工资和部门号都是纯数字，取错下标后 `Integer.parseInt` 仍可能成功（比如把工资当成了部门号），作业照常跑完，只是结果全错。所以取值前先自检下标，是必须的一步。



## 实训篇：统计部门工资总额

整个作业只有 Mapper 和 Reducer 各一个方法，重点在于下标确认与分组键的选择。

### 步骤一：先自检字段下标

包内有一个 13 行的小程序，专门用来打印切分结果，确认下标：

```java
String employeeData = "7369,SMITH,CLERK,7902,1980/12/17,800,,20";
String[] fields = employeeData.split(",");
System.out.println("工资: " + fields[5]);  // SMITH
System.out.println("部门编号: " + fields[7]);  // 20
```

源码位置：`bdeptsalary/DeptSalaryTest.java`

### 步骤二：准备数据

```shell
hdfs dfs -mkdir -p /input
hdfs dfs -put emp.csv /input/emp.csv
```

### 步骤三：实现 Mapper

只做一件事：把"部门号 → 工资"这一个映射关系发出去。

```java
String[] empArray = value.toString().split(",");

int dept = Integer.parseInt(empArray[7]);
int salary = Integer.parseInt(empArray[5]);

context.write(new IntWritable(dept), new IntWritable(salary));
```

注意 Mapper 的输出类型是 `<IntWritable, IntWritable>`：key 是部门号，value 是**单条工资**。原始行里的其他 6 个字段在这里全被丢弃了——MapReduce 不需要把明细带下去，只要保留参与分组和聚合的字段。

### 步骤四：实现 Reducer

遍历这一组的全部工资并累加，循环结束后写出一次。

```java
int total = 0;

for (IntWritable salary : salaries) {
    total = total + salary.get();
}

context.write(dept, new IntWritable(total));
```

`context.write` 在循环**外面**——每个部门只输出一行。如果误把写操作放进循环，就会退化成"逐条输出"，汇总效果完全消失。

### 步骤五：配置作业

泛型在三处必须一致，其中 `OutputKeyClass` 是 `IntWritable`（部门号），容易与 Map 输出的 value 类型混淆。

```java
job.setMapperClass(DeptMapper.class);
job.setReducerClass(DeptReduce.class);

job.setMapOutputKeyClass(IntWritable.class);
job.setMapOutputValueClass(IntWritable.class);

job.setOutputKeyClass(IntWritable.class);
job.setOutputValueClass(IntWritable.class);
```

本案例 Map 输出与最终输出类型恰好相同，所以两段看起来重复。一旦 reduce 需要改变输出类型（比如换成部门名），两者就必须分开写——`hmulti` 案例正是这种情况。

### 步骤六：运行与验证

```shell
hadoop jar hadoop-1.0-SNAPSHOT.jar \
  com.studybigdata.hadoop.mapred.bdeptsalary.DeptMain \
  /input/emp.csv /output/dept_salary
```

输出 3 行，且部门号必然升序（key 被排过序）：

```csv
10	8750
20	10875
30	9400
```

两道核对关：**三行相加必须等于 29025**；**总人数必须等于 14**。第一道关能挡住分组键错误，第二道关能挡住漏读行。

```shell
hdfs dfs -cat /output/dept_salary/part-r-00000
```

### 步骤七：变式训练

| 变式 | 做法 | 观察到的现象 |
|---|---|---|
| 1. 同时输出人数 | 用 `count` 变量计数 | 输出变成 `<部门号, 总额, 人数>` |
| 2. 求平均工资 | 总额 ÷ 人数 | 20 号部门为 2175 |
| 3. 改按岗位汇总 | key 换成 `empArray[2]` | 输出 5 行 |

变式 2 是下一个案例的引子：一旦引入除法，Combiner 就不能用了。变式 3 说明"换一个维度"的代价只有一行代码。



## 小结

汇总类需求的结构是固定的：key 用分组字段，value 用被聚合的字段，reduce 里累加后输出一次。

### 回顾

- 分组键是唯一需要设计的东西，它决定了输出的组数和每组的成员。
- 聚合必须发生在 Reduce 端，Mapper 端的任何累加都只是局部值。

### 与下一案例的衔接

本案例的 Mapper 把 14 行明细原封不动地发给了 reduce。如果能在 Map 端先把同一任务内的记录预聚合，"发出去的数据量"就会下降——这正是 Combiner 要做的事，也是下一个案例的主题。

<div class="end"><h1>分组汇总</h1><p>下一案例：Combiner 预聚合</p></div>
