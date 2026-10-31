---
title: Hadoop MapReduce 自定义排序
date: 2026-09-13 10:00:00
categories:
- Hadoop
tags:
- Hadoop
- MapReduce
- Sort
---

<div class="cover"><h1>自定义排序</h1><p>WritableComparable 契约与全局有序</p></div>

## 案例概览

本案例用一份 14 行的员工表，实现"先按部门号升序、部门相同时再按工资升序"的两级排序。

### 业务问题

报表要求：同一部门的员工排在相邻位置，部门内部按工资从低到高。这类"多字段排序"是 MapReduce 里最容易踩坑的需求——因为排序并不是我们在代码里显式调用的，而是框架在 Shuffle 阶段替我们做的。

### 输入数据与预期输出

输入 `emp.csv`（每行 8 个字段，工资在第 6 列、部门号在第 8 列）：

```text
7369,SMITH,CLERK,7902,1980/12/17,800,,20
7782,CLARK,MANAGER,7839,1981/6/9,2450,,10
7902,FORD,ANALYST,7566,1981/12/3,3000,,20
```

预期输出（只列关键字段，升序）：

| 部门 | 结果（姓名 工资，升序） |
|---|---|
| 10 | MILLER 1300 → CLARK 2450 → KING 5000 |
| 20 | SMITH 800 → ADAMS 1100 → JONES 2975 → SCOTT 3000 → FORD 3000 |
| 30 | JAMES 950 → WARD 1250 → MARTIN 1250 → TURNER 1500 → ALLEN 1600 → BLAKE 2850 |

注意 20 和 30 部门里各有一组并列（工资相同），这正是本案例的核心难点。

### 前置与后继

| 关系 | 案例 | 承接的知识点 |
|---|---|---|
| 前置 | 自定义序列化 | Writable 的 write/readFields 规范 |
| 本案例 | 自定义排序 | key 的排序契约、全局有序的条件 |
| 后继 | Distinct 去重 | "每组 reduce 只调一次"的另一种用法 |

源码位置：`code/hadoop/src/main/java/com/studybigdata/hadoop/mapred/fsort/`

## 理论篇：MapReduce 为什么"天生会排序"

先把排序发生的位置搞清楚，再动手写代码——否则很容易写出"以为在排、其实没排"的程序。

### 排序的三次机会

框架在三个位置各排一次，它们比的全都是"map 输出的 key"。

```mermaid
flowchart LR
    A["Map 读切片"] --> B["环形缓冲区<br/>spill 内排序"]
    B --> C["spill 归并<br/>map 端整体有序"]
    C --> D["Reduce 拉取<br/>再归并"]
    D --> E["输出<br/>reduce 内有序"]
```

| 阶段 | 触发时机 | 排序对象 |
|---|---|---|
| Map 端内存排序 | 环形缓冲区达到阈值溢写 | 单个 spill 内的 key |
| Map 端归并 | spill 文件数达到 3 | 多个 spill 的 key |
| Reduce 端归并 | 拉完所有 map 的输出段 | 所有 map 输出段的 key |

### 排序键必须在 key 里

既然三次排序都比 key，那么想按某字段排序，就必须把该字段放进 key。这是本案例唯一的设计决策：

| 设计 | key | value | 结果 |
|---|---|---|---|
| 错误 | 部门号 | Employee 对象 | 只按部门分组，工资顺序随机 |
| 正确 | Employee 对象 | NullWritable | 按部门、工资两级有序 |

把整个 `Employee` 当 key 意味着它必须自己说清楚"怎么比大小"——这就是 `WritableComparable` 的作用。

### WritableComparable 的契约

`compareTo` 不是"随便写个比较逻辑"，它要满足三条约定，破坏任何一条都会得到不可预期的排序结果。

| 约定 | 要求 | 破坏后的现象 |
|---|---|---|
| 反对称性 | `a.compareTo(b)` 与 `b.compareTo(a)` 反号 | 并列元素顺序每次运行都不同 |
| 相等返回 0 | 所有排序字段相等时必须返回 0 | 同上，且归并结果不稳定 |
| 与 equals 一致 | 排序键组合应与 equals/hashCode 对应 | 分区结果不可复现 |

第三条最容易被忽略：`Employee` 不重写 `hashCode` 时，`HashPartitioner` 用的是 Object 的 identity hash，同一个部门可能被分到不同分区。

### 契约破坏了会怎样

本项目原始实现里，`compareTo` 末尾写成 `if/else` 两分支，工资相等时两个方向都返回 `-1`——实测正好撞上输入里的两组并列：

| 并列组 | 成员 | 破坏契约时 | 用 empId 兜底后 |
|---|---|---|---|
| 工资 3000 | SCOTT(7788)、FORD(7902) | 顺序不可预期 | SCOTT → FORD |
| 工资 1250 | WARD(7521)、MARTIN(7654) | 顺序不可预期 | WARD → MARTIN |

所以在真实数据里，并列不是"不会遇到"的边界情况，而是必然会遇到。

## 实训篇：实现按部门、工资排序

理论篇已经确定了设计：key 用 `Employee`，value 用 `NullWritable`。下面分五步把它做出来。

### 步骤一：准备数据

把 `code/data/emp/emp.csv` 上传到 HDFS：

```shell
hdfs dfs -mkdir -p /input
hdfs dfs -put emp.csv /input/emp.csv
hdfs dfs -cat /input/emp.csv | head -3
```

数据本身很规整，但有两个空值字段需要注意：第 4 列（上级编号）和第 7 列（奖金）都可能是空的。

| 列号 | 含义 | 空值处理 |
|---|---|---|
| 1 / 2 | 员工号 / 姓名 | 必填 |
| 4 | 上级编号 | 解析失败默认 `-1` |
| 6 | 工资 | 必填，排序键之一 |
| 7 | 奖金 | 解析失败默认 `0` |
| 8 | 部门号 | 必填，排序键之一 |

### 步骤二：实现 compareTo

这是本案例的核心。要点是按"部门 → 工资 → 员工号"三档依次比较，前两档分出胜负就返回，全都相等才落到第三档。

```java
@Override
public int compareTo(Employee o) {
    // 第一排序键：部门号
    if (this.deptId != o.deptId) {
        return this.deptId > o.deptId ? 1 : -1;
    }
    // 第二排序键：工资
    if (this.salary != o.salary) {
        return this.salary > o.salary ? 1 : -1;
    }
    // 兜底排序键：员工号
    return Integer.compare(this.empId, o.empId);
}
```

第三档容易被当成"多此一举"，但它解决了两个问题：让并列元素的顺序稳定可复现；让 `compareTo` 在全等时返回 `0`，满足契约。

### 步骤二补充：让 equals 与 compareTo 对齐

排序键是"部门 + 工资 + 员工号"，那么 `equals`/`hashCode` 就必须用同一组键，否则会出现"`compareTo` 说相等、`equals` 说不等"的矛盾。

```java
@Override
public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    Employee other = (Employee) o;
    return deptId == other.deptId
            && salary == other.salary
            && empId == other.empId;
}

@Override
public int hashCode() {
    return Objects.hash(deptId, salary, empId);
}
```

用 `Objects.hash` 而不是 `Object` 默认实现，分区的哈希值就只由字段值决定，同一次输入无论跑多少遍，分区结果都一致。

### 步骤三：配置作业

Mapper 把整行解析成 `Employee` 后直接作为 key 输出，value 用 `NullWritable` 占位。

```java
job.setJarByClass(DeptMain.class);
job.setMapperClass(DeptMapper.class);
job.setMapOutputKeyClass(Employee.class);
job.setMapOutputValueClass(NullWritable.class);

job.setNumReduceTasks(1);
job.setOutputKeyClass(Employee.class);
job.setOutputValueClass(NullWritable.class);
```

两行配置值得单独解释，它们是本案例"能排对"的前提。

| 配置 | 为什么必须这样写 |
|---|---|
| `setNumReduceTasks(1)` | 每个 reduce 只保证自己输出有序，全局有序只在单 reduce 时成立 |
| `setOutputKeyClass(...)` | 不写会回退到 map 输出类型，一旦 map 输出改动就静默出错 |

注意这里没有显式设置 `reducerClass`。不设置不等于没有 reduce 阶段——框架会用默认的恒等 Reducer 原样输出，但 reduce 个数仍然是 1。

### 步骤四：运行与验证

本地模式在 IDE 里直接跑，输入输出都用 `file://` 前缀；集群模式用 `hadoop jar` 提交。

```shell
# 本地模式（IDE 运行参数）
file:///D:/studybigdata/code/data/emp/emp.csv file:///D:/output/sort

# 集群模式
hadoop jar hadoop-1.0-SNAPSHOT.jar \
  com.studybigdata.hadoop.mapred.fsort.DeptMain \
  /input/emp.csv /output/sort
```

由于 value 是 `NullWritable`，`TextOutputFormat` 会跳过它并同时省略制表符，所以每行输出就是一个完整的对象字符串：

```text
Employee{empId=7934, name='MILLER', ..., salary=1300, deptId=10}
```

查看结果并按上文预期表逐行核对：

```shell
hdfs dfs -cat /output/sort/part-r-00000
```

### 步骤五：变式训练

三个变式从易到难，分别对应"改比较方向""改 reduce 个数""改分区方式"。

| 变式 | 做法 | 观察到的现象 |
|---|---|---|
| 1. 工资降序 | 把工资的比较返回值取反 | 部门仍升序，部门内工资倒序 |
| 2. reduce 数改为 2 | `setNumReduceTasks(2)` | 两个文件各自有序，但整体无序 |
| 3. 部门各占一个文件 | 自定义 Partitioner 按部门分区 | 需要配合全排序才能保持全局有序 |

变式 2 最能说明问题：`HashPartitioner` 此时按 `Employee` 的哈希分区，同一个部门可能被切到两个文件里，于是"部门内相邻"的约束也被打破。这直接引出"分区器决定负载均衡、reduce 个数决定全局有序"的主题。

## 常见坑

这一节汇总本案例在实际作业中最容易出现的五类问题，按排查顺序排列。

### 坑一：输出完全没排序

最常见的原因是排序键没放进 key——比如 key 仍是 `LongWritable` 行号，或者干脆用了 `NullWritable`。

| 现象 | 原因 | 修法 |
|---|---|---|
| 顺序与输入一致 | key 是行号，框架按行号排了 | 把排序字段做成 key |
| 顺序随机 | key 是 `NullWritable` | 同上 |
| 部分有序 | 用了多个 reduce | `setNumReduceTasks(1)` |

### 坑二：并列元素顺序不稳定

两个元素在排序键上相等时，若 `compareTo` 不返回 `0`，归并阶段的相对顺序取决于遍历次序，多次运行结果可能不同。

| 现象 | 原因 | 修法 |
|---|---|---|
| 同一份数据两次输出不同 | `compareTo` 相等时返回了非 0 值 | 相等时 `return 0` |
| 想固定并列顺序 | 缺少兜底排序键 | 追加一个唯一字段（如员工号） |

### 坑三：多文件时顺序是断的

每个 reduce 任务只保证自己写出的文件内部有序，跨文件不存在全局有序。

| 现象 | 原因 | 修法 |
|---|---|---|
| part-r-00000 与 00001 之间无序 | reduce 个数大于 1 | 单 reduce，或用 `TotalOrderPartitioner` |
| 同一 key 出现在多个文件 | 分区器把同 key 分到了不同 reduce | 检查 `getPartition` 是否只依赖 key |

### 坑四：用对象做 key 时分区不可复现

不重写 `hashCode` 就使用 `Object` 的 identity hash，同一份输入在不同 JVM 上分区可能不同。

| 现象 | 原因 | 修法 |
|---|---|---|
| 每次运行分区不同 | 未重写 `hashCode`/`equals` | 重写，且与 `compareTo` 用同一组键 |
| 自定义分区器不生效 | 分区器类未注册 | `job.setPartitionerClass(...)` |

### 坑五：提交后找不到类

`setJarByClass` 指错的类，或泛型与实现不一致，都会在集群上抛出 `ClassNotFoundException`。

| 现象 | 原因 | 修法 |
|---|---|---|
| `ClassNotFoundException` | `setJarByClass` 指向了非本作业类 | 指向 Driver 类 |
| 类型转换异常 | 泛型签名与 `context.write` 不符 | 核对 Mapper 四处泛型 |

## 小结

本案例的全部复杂度都集中在"排序契约"这一件事上，代码量其实很小。

### 三句话回顾

- 排序由框架在 Shuffle 阶段完成，比的是 map 输出的 key，所以排序依据必须放进 key。
- `compareTo` 必须满足反对称性与"相等返回 0"，否则并列元素顺序不可预期。
- 全局有序只在单个 reduce 时成立；reduce 个数和分区器共同决定输出的文件划分。

### 与下一案例的衔接

本案例只排序、不聚合，输出是"有序的明细"。下一个案例"分组汇总"会在同样的 key 设计之上加一层聚合，把明细压成统计值——届时 `Iterable` 里的元素顺序，正是本案例刚刚建立起来的有序性。
