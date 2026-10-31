---
title: Hadoop MapReduce 多表关联
date: 2026-09-13 12:00:00
categories:
- Hadoop
tags:
- Hadoop
- MapReduce
- Join
---

<div class="cover"><h1>多表关联</h1><p>用分组键把两张表拉进同一个 Reduce</p></div>

## 案例概览

本案例把员工表和部门表关联起来，输出"部门名 → 员工名"，也就是把员工表里的部门号翻译成部门名。

### 业务问题

员工表只存部门号（`20`），部门名在另一张表里。要输出可读的报表，就得把两张表按部门号拼起来。这正是 SQL 里 `JOIN` 做的事，而 MapReduce 没有 `JOIN` 关键字——得自己用分组键搭出来。

### 输入数据与预期输出

两张表放在**同一个输入目录**下，共 18 行：

```text
# emp.csv（14 行，8 列，部门号在第 8 列）
7369,SMITH,CLERK,7902,1980/12/17,800,,20
# dept.csv（4 行，3 列）
10,ACCOUNTING,NEW YARK
20,RESEARCH,DALLAS
30,SALES,CHICAGO
40,OPERATIONS,BOSTON
```

预期输出 14 行 `<部门名, 员工名>`：

| 部门名 | 员工（部门号） | 行数 |
|---|---|---|
| ACCOUNTING | CLARK、KING、MILLER（10） | 3 |
| RESEARCH | SMITH、JONES、SCOTT、ADAMS、FORD（20） | 5 |
| SALES | ALLEN、WARD、MARTIN、BLAKE、TURNER、JAMES（30） | 6 |
| — | **部门 40 没有员工，整行不出现在结果里** | 0 |

最后一行是本案例最容易误判的地方：`dept.csv` 有 4 个部门，结果却只出现 3 个。这不是 bug，是内连接的定义。

### 前置与后继

| 关系 | 案例 | 承接的知识点 |
|---|---|---|
| 前置 | 数据去重 | 分组键决定一切 |
| 本案例 | 多表关联 | 打标签区分数据来源 |
| 后继 | 天气两阶段统计 | 多次作业串联 |

源码位置：`code/hadoop/src/main/java/com/studybigdata/hadoop/mapred/hmulti/`

## 理论篇：连接键就是分组键

MapReduce 没有专门的连接算子。能用的只有一件事：**让相同连接键的记录落进同一个 reduce**。而框架已经保证了这一点——分区函数只依赖 key。

### 两张表如何汇进同一个 Reduce

关键在于 Mapper 必须让两张表输出**相同类型**的 key：

| 输入行 | 来源表 | 字段数 | Map 输出 |
|---|---|---|---|
| `7369,SMITH,...,20` | emp | 8 | `<20, SMITH>` |
| `20,RESEARCH,DALLAS` | dept | 3 | `<20, *RESEARCH>` |

带部门号 20 的两行，无论来自哪张表，都会被分到同一个 reduce。reduce 收到的是：

```text
<20, [SMITH, JONES, SCOTT, ADAMS, FORD, *RESEARCH]>
```

一次遍历就能把它们分成"部门名"和"员工列表"两堆，然后做笛卡尔积输出。

### 打标签：为什么需要，怎么打

问题来了：reduce 拿到的 `Iterable<Text>` 里，**部门和员工都是 Text**，怎么区分谁是谁？只能约定一个标记。

| 方式 | 做法 | 优点 | 缺点 |
|---|---|---|---|
| 字符串前缀 | `"*" + deptName` | 改动最小 | 与数据内容可能撞车 |
| 复合 Writable | 自定义 `<来源, 数据>` | 类型安全 | 多写一个类 |
| 按文件名判断 | `FileSplit` 取文件名 | 不动数据 | 代码略复杂 |

本案例用第一种。**前缀要比 `contains` 严格**：如果部门名本身含 `*`，用 `contains("*")` 判定就会把员工名误判成部门名。所以判定必须写 `startsWith("*")`。

### 为什么不能在 Mapper 端连接

第一反应通常是"在 Mapper 里把部门表装进 HashMap，逐行查表不就完了"。这条路的问题是：

| 条件 | 本案例 | 真实场景 |
|---|---|---|
| 能放进内存 | 4 行，可以 | 部门表可能上亿行 |
| 每个 map 都要加载 | 浪费但可接受 | 传输与内存开销巨大 |
| 数据分布 | 无要求 | map 端连接要求小表且需广播 |

Mapper 端连接（Map-side Join）是真实存在的优化手段，但前提是"小表能广播"。本案例的数据确实能这么干，但那样就学不到分组机制了——而且一旦部门表变大就会崩。

### 内连接与左连接只差一个判断

结果里部门 40 消失了，因为 reduce 遍历结束后 `empList` 是空的，循环体一次都不执行。

| 想要的效果 | reduce 里的写法 |
|---|---|
| 内连接（只要匹配上的） | 循环输出 `empList`，空就自然不输出 |
| 左连接（保留所有部门） | `empList` 为空时补写一行，值填占位符 |

注意：`deptName` 本身也可能为空——当某个部门号只出现在员工表、部门表里没有对应行时就是这种情况。所以取值前必须先判空。

### 标签会污染数据

`"*" + deptName` 这个前缀是**你加的，不是数据里的**。写出前必须去掉，否则结果里会出现 `*RESEARCH`。

| 阶段 | 值 | 说明 |
|---|---|---|
| Mapper 输出 | `*RESEARCH` | 带标签 |
| reduce 内部 | `*RESEARCH` | 靠标签分类 |
| 写出 | `RESEARCH` | 必须 `replace("*", "")` |

一步忘记剥标签，整份结果的部门名就全错了。

## 实训篇：实现两表关联

Mapper 负责"打标签"，Reducer 负责"拆标签并拼装"。两边各改一处，骨架和之前的案例完全一样。

### 步骤一：准备数据

两张表必须放进**同一个输入目录**，否则一个 map 任务读不到另一张表：

```shell
hdfs dfs -mkdir -p /input/join
hdfs dfs -put emp.csv /input/join/
hdfs dfs -put dept.csv /input/join/
hdfs dfs -ls /input/join
```

本案例不区分处理哪张表，全靠 Mapper 自己判断行来自哪里，所以目录混放是设计的一部分。

### 步骤二：实现 Mapper（按文件名区分来源）

核心是两个分支：部门表行加 `*` 前缀，员工表行原样输出。靠**输入文件名**判断行来自哪张表，而不是字段数（需导入 `org.apache.hadoop.mapreduce.lib.input.FileSplit`）。

```java
// 当前记录来自哪张表，框架通过输入分片告知，不靠字段数猜测
FileSplit split = (FileSplit) context.getInputSplit();
String fileName = split.getPath().getName();

String[] strings = value.toString().split(",");

if (fileName.equals("dept.csv")) {
    // 部门表：部门号在第 1 列，部门名在第 2 列
    context.write(new IntWritable(Integer.parseInt(strings[0])),
                  new Text("*" + strings[1]));
} else {
    // 员工表：部门号在第 8 列
    context.write(new IntWritable(Integer.parseInt(strings[7])),
                  new Text(strings[1]));
}
```

注意两张表取部门号的位置完全不同：部门表在第 1 列（下标 0），员工表在第 8 列（下标 7）。这是关联能够成立的前提。文件名判断要求你 `put` 到 HDFS 的文件就叫 `dept.csv` / `emp.csv`，否则对应不上。

### 步骤三：为什么不能靠字段数判断来源

如果换一种写法——用 `strings.length == 3` 区分两张表——它对本案例**恰好有效**，但非常脆弱：

| 破坏条件 | 后果 |
|---|---|
| 部门名里含逗号 | 列数变成 4，被当成员工表 |
| 员工行缺字段 | 列数变成 3，被当成部门表 |
| 部门表增加一列 | 全部误判 |

字段数是数据的"形状"，不是"身份"。正确的判据是记录来自哪个文件——这正是步骤二改用 `FileSplit` 取文件名的原因。这样无论两张表怎么增删列，关联都不再受影响。

### 步骤四：实现 Reducer

先遍历一遍分成两堆，再对员工列表输出。

```java
String deptName = null;
ArrayList<String> empList = new ArrayList<>();

for (Text value : values) {
    String tmp = value.toString();
    if (tmp.startsWith("*")) {
        deptName = tmp;              // 部门名，只有一个
    } else {
        empList.add(tmp);            // 员工名，可能多个
    }
}

String name = (deptName == null) ? "未知部门" : deptName.replace("*", "");
for (String empName : empList) {
    context.write(new Text(name), new Text(empName));
}
```

三个细节值得单独看：`startsWith` 而非 `contains`；`replace` 剥掉标签；`deptName == null` 的兜底。

### 步骤五：配置作业

注意 map 输出的 value 是 `Text`（承载两种数据），最终输出的 key 也是 `Text`（部门名）。

```java
job.setMapperClass(DeptMapper.class);
job.setReducerClass(DeptReducer.class);

job.setMapOutputKeyClass(IntWritable.class);
job.setMapOutputValueClass(Text.class);

job.setOutputKeyClass(Text.class);
job.setOutputValueClass(Text.class);
```

Map 输出用 `IntWritable`（部门号，决定分组），最终输出用 `Text`（部门名，给人看）——两个阶段的 key 类型可以不同，容易写错。

### 步骤六：运行与验证

```shell
# 集群模式
hadoop jar hadoop-1.0-SNAPSHOT.jar \
  com.studybigdata.hadoop.mapred.hmulti.DeptMain \
  /input/join /output/join
```

结果按部门名分组，共 14 行：

```text
ACCOUNTING	CLARK
ACCOUNTING	KING
ACCOUNTING	MILLER
RESEARCH	SMITH
...
```

重点核对两件事：行数是 **14**（与员工数一致），且**没有 OPERATIONS**。

```shell
hdfs dfs -cat /output/join/part-r-00000 | wc -l
```

### 步骤七：变式训练

| 变式 | 做法 | 观察到的现象 |
|---|---|---|
| 1. 左连接 | `empList` 为空时补写 `部门名, 无` | 出现第 4 行 OPERATIONS |
| 2. 改用 MultipleInputs | 为 dept.csv / emp.csv 分别指定 Mapper | 连打标签都省了，最规范 |
| 3. 输出员工人数 | 用 `empList.size()` 代替循环 | 变成 3 行 `<部门名, 人数>` |

变式 1 最能说明内连接与左连接的差别——只差一个"空列表也要输出"的判断。变式 3 顺带回到了分组统计，和 `bdeptsalary` 的思路一致。

## 常见坑

这一节的五类问题里，前两个会直接让结果错误，后三个属于容易被误判成 bug 的正常行为。

### 坑一：用 contains 判定数据来源

前缀标记的判定必须比 `contains` 更严格。

| 现象 | 原因 | 修法 |
|---|---|---|
| 部门名被当成员工名 | 部门名里含 `*`，`contains` 误判 | 改 `startsWith("*")` |
| 员工名出现在部门名位置 | 同上 | 同上 |

### 坑二：忘记剥掉标签

标签是传输用的中间产物，写出前必须清理。

| 现象 | 原因 | 修法 |
|---|---|---|
| 结果里部门名带 `*` | 直接写出了 `deptName` | `replace("*", "")` |
| 部门名对不上原表 | 同上 | 同上 |

### 坑三：部门表缺失导致空指针

只要输入目录里没有部门表，或部门表被过滤掉，`deptName` 就会一直是 `null`。

| 现象 | 原因 | 修法 |
|---|---|---|
| 单个 reduce 抛 `NullPointerException` | `null.replace(...)` | 取值前判空并给默认值 |
| 只有部分分区失败 | 数据恰好都落到那个分区 | 同上 |

### 坑四：把"部门 40 消失"当成 bug

这是内连接的定义，不是缺陷。判断依据是**结果的业务含义**，不是行数。

| 现象 | 原因 | 修法 |
|---|---|---|
| 4 个部门只输出 3 个 | 部门 40 无员工，`empList` 为空 | 需要保留就改成左连接 |
| 行数少于部门数 | 同上 | 同上 |

### 坑五：在 Reducer 里缓存整张大表

为了做关联，Reducer 必须把一组的 value 全部读进内存——这是分组键只有部门号时不可避免的。

| 现象 | 原因 | 修法 |
|---|---|---|
| reduce 阶段 OOM | 某个热点 key 的员工数极大 | 检查数据倾斜 |
| 单个 reduce 特别慢 | 同上 | 加 Combiner 或做二次分区 |

注意 `empList` 存的是整组数据。如果某个部门占全表一半的记录，那个 reduce 任务就会成为瓶颈——这就是数据倾斜。

## 小结

关联的本质是把"两张表的连接键"变成"MapReduce 的分组键"，剩下的工作框架已经替你做好了。

### 三句话回顾

- 想让两张表的数据相遇，就必须让它们的连接键成为 Map 输出的 key。
- 同类型的 value 需要用前缀（或复合类型）打标签区分来源，写出前必须剥掉。
- 内连接与左连接的差别，只在 reduce 里"员工列表为空时要不要输出"这一个判断。

### 与下一案例的衔接

本案例把两个数据集塞进了一次作业。下一案例"天气两阶段统计"要解决的问题不同：目标口径无法用一次分组算出来，必须把第二个作业的输入接到第一个作业的输出上——重点从"分组键"转向"作业之间的衔接"。

<div class="end"><h1>多表关联</h1><p>下一案例：天气两阶段统计</p></div>
