---
title: Hadoop MapReduce 去重
date: 2026-09-13 11:00:00
categories:
- Hadoop
tags:
- Hadoop
- MapReduce
- Distinct
---

<div class="cover"><h1>数据去重</h1><p>把"分组"本身当作去重机制</p></div>

## 案例概览

本案例从 14 行员工明细中提取出**所有出现过的岗位**，输出一份不含重复值的岗位清单。

### 业务问题

员工表里同一岗位会反复出现（SALESMAN 出现 4 次、CLERK 出现 4 次）。报表需要一份"岗位字典"——每个岗位只列一次。这类需求在数据清洗里极其常见，而 MapReduce 实现它的代码量少得出奇。

### 输入数据与预期输出

输入 `emp.csv`，共 14 行，岗位在第 3 列（下标 2）：

```text
7369,SMITH,CLERK,7902,1980/12/17,800,,20
7499,ALLEN,SALESMAN,7698,1981/2/20,1600,300,30
7521,WARD,SALESMAN,7698,1981/2/22,1250,500,30
```

14 行输入里只有 5 个不同岗位，预期输出恰好 5 行：

| 岗位 | 出现次数 | 说明 |
|---|---|---|
| ANALYST | 2 | SCOTT、FORD |
| CLERK | 4 | SMITH、ADAMS、JAMES、MILLER |
| MANAGER | 3 | JONES、BLAKE、CLARK |
| PRESIDENT | 1 | KING |
| SALESMAN | 4 | ALLEN、WARD、MARTIN、TURNER |

注意输出顺序是字典序——这不是本案例刻意做的，而是 key 排序的副产品。

### 前置与后继

| 关系 | 案例 | 承接的知识点 |
|---|---|---|
| 前置 | 自定义排序 | 有序性是分组的副产品 |
| 本案例 | 数据去重 | 分组机制本身就是去重机制 |
| 后继 | 多表关联 | 用同一套分组键做连接 |

源码位置：`code/hadoop/src/main/java/com/studybigdata/hadoop/mapred/gdistinct/`

## 理论篇：去重为什么不需要额外机制

关键在于认清一件事：Reduce 阶段拿到的输入，**已经被框架按 key 分好组了**。

### Reducer 的入参形态

`reduce` 方法的签名决定了去重是"免费的"：

```java
protected void reduce(Text key,
        Iterable<NullWritable> values,
        Context context)
```

同一个 key 的所有 value 被打包成一个 `Iterable` 交给 reduce，**这个方法对一个 key 只调用一次**。所以"每个 key 只输出一行"不需要任何判重逻辑。

### 去重的三个条件

| 条件 | 本案例的做法 | 违反后的现象 |
|---|---|---|
| 去重字段当 key | `Text` 装岗位名 | 去重粒度不对 |
| value 用 `NullWritable` | `NullWritable.get()` | 白白浪费网络传输 |
| reduce 里不遍历 values | 直接写 key | 同一 key 输出多次 |

第三条是最容易写错的。看到 `Iterable` 就想 `for` 循环，一循环就退化成"逐条输出"，去重彻底失效。

### 三种需求只差 reduce 里的几行

`fsort`、`bdeptsalary`、本案例的骨架完全一样，区别只在 reduce 内部：

| 需求 | key | reduce 里做什么 |
|---|---|---|
| 排序 | 排序字段 | 原样写出 |
| 分组统计 | 统计字段 | 遍历累加 |
| 去重 | 去重字段 | 只写一次 |

所以 MapReduce 编程的思维顺序应该是：**先想清楚分组键是什么，再想每一组要产出什么**。

### 去重与排序对 reduce 个数的敏感度不同

这是本案例最有价值的一个对比。`fsort` 必须限制 reduce 个数，而去重不受影响：

| 指标 | 排序 | 去重 |
|---|---|---|
| reduce 个数 > 1 | 失去全局有序 | 结果依然正确 |
| 原因 | 有序性是文件级属性 | 每个 key 只落一个分区 |
| 结论 | 必须单 reduce | 随便几个 reduce |

根本原因：**同一个 key 永远只会被分到同一个 reduce**。有序需要"跨文件也有序"，去重只需要"同 key 不跨文件"——后者是分区机制自动保证的。

### 不要试图在 Mapper 里解决

一个常见诱惑是在 Mapper 里用 `Set` 缓存已见的值来提前去重。这样做：

| 做法 | 效果 | 问题 |
|---|---|---|
| Mapper 内 `Set` 去重 | 减少发给 reduce 的数据量 | 每个 map 任务各自一份 Set，**无法跨 map 去重** |
| Reduce 端去重 | 结果正确 | 需要把重复数据传一遍 |

正确做法是两者结合：Mapper 端用 Set 做**局部压缩**（可选优化），Reduce 端做**最终去重**（保证正确）。只做前者会得到错误结果——因为不同的 map 任务之间不共享内存。

## 实训篇：实现岗位去重

Mapper 只做一件事：把岗位名抽出来当 key。Reducer 也只做一件事：写一次。

### 步骤一：准备数据

上传 `code/data/emp/emp.csv`，并确认它能正常读取：

```shell
hdfs dfs -mkdir -p /input
hdfs dfs -put emp.csv /input/emp.csv
hdfs dfs -cat /input/emp.csv | wc -l
```

14 行输入、8 个字段。和 `fsort` 用的是同一份数据，区别只在于本次只关心第 3 列。

### 步骤二：实现 Mapper

只需切分、取下标、写出三步。注意输出类型是 `<Text, NullWritable>`。

```java
public class DeptMapper extends Mapper<LongWritable, Text, Text, NullWritable> {

    @Override
    protected void map(LongWritable key, Text value, Context context)
            throws IOException, InterruptedException {

        String[] tmp = value.toString().split(",");
        String empPosition = tmp[2];

        context.write(new Text(empPosition), NullWritable.get());
    }
}
```

`NullWritable.get()` 返回的是单例，不会产生对象分配开销。value 类型选它不是"省事"，而是明确告诉读代码的人：**这个 value 没有语义**。

### 步骤三：实现 Reducer

整个 reducer 只有一行有效代码——注意没有 `for` 循环。

```java
public class DeptReducer extends Reducer<Text, NullWritable, Text, NullWritable> {

    @Override
    protected void reduce(Text key, Iterable<NullWritable> values, Context context)
            throws IOException, InterruptedException {

        context.write(key, NullWritable.get());
    }
}
```

方法签名里的 `values` 参数一次都没用到。这正是去重的实现方式：**把"一组"当成"一个"输出**。

### 步骤四：配置作业

泛型类型在三处必须完全一致，否则运行期报类型转换异常。

```java
job.setMapperClass(DeptMapper.class);
job.setReducerClass(DeptReducer.class);

job.setMapOutputKeyClass(Text.class);
job.setMapOutputValueClass(NullWritable.class);

job.setOutputKeyClass(Text.class);
job.setOutputValueClass(NullWritable.class);
```

Map 输出与最终输出类型相同，本案例中直接复用即可。注意没有设置 reduce 个数——按理论篇的结论，去重对 reduce 个数不敏感。

### 步骤五：运行与验证

本地模式与集群模式二选一：

```shell
# 本地模式（IDE 运行参数）
file:///D:/studybigdata/code/data/emp/emp.csv file:///D:/output/distinct

# 集群模式
hadoop jar hadoop-1.0-SNAPSHOT.jar \
  com.studybigdata.hadoop.mapred.gdistinct.DeptMain \
  /input/emp.csv /output/distinct
```

value 是 `NullWritable`，所以输出行只有 key 本身，结果是干净的 5 行：

```text
ANALYST
CLERK
MANAGER
PRESIDENT
SALESMAN
```

用行数验证去重生效——输入 14 行、输出 5 行：

```shell
hdfs dfs -cat /output/distinct/part-r-00000 | wc -l
```

### 步骤六：变式训练

| 变式 | 做法 | 观察到的现象 |
|---|---|---|
| 1. 统计每个岗位人数 | reduce 里改成遍历 `values` 计数 | 输出变成 5 行 `<岗位, 人数>` |
| 2. 按"岗位+部门"去重 | key 改成 `岗位,部门` 拼接串 | 输出 8 行，粒度更细 |
| 3. reduce 个数改为 3 | `setNumReduceTasks(3)` | 结果仍正确，只是分到 3 个文件 |

变式 3 是理论篇结论的实测验证。作为对照，同样的改动落在 `fsort` 上会直接破坏全局有序——两个案例一起做，区别会非常直观。

## 常见坑

这一节按排查顺序列出五类问题，前两个几乎每个初学者都会踩一次。

### 坑一：在 reduce 里循环了 values

这是去重失败的头号原因。写了 `for` 循环，每个重复项都会输出一行，结果和不去重完全一样。

| 现象 | 原因 | 修法 |
|---|---|---|
| 输出仍是 14 行 | reduce 里遍历了 `values` | 删掉循环，直接写 key |
| 输出行数比预期多 | 循环体内写了 `context.write` | 把 write 移到循环外 |

### 坑二：value 类型选错

value 用 `NullWritable` 是去重的标准搭配；用了 `Text` 也能跑，但要多一次无意义的字符串构造与传输。

| 现象 | 原因 | 修法 |
|---|---|---|
| 功能正常但传输量大 | value 塞了整行数据 | 改 `NullWritable` |
| 输出多一列空白 | value 写成空 `Text` | 改 `NullWritable`，输出不会多制表符 |

### 坑三：去重字段取错下标

`emp.csv` 有 8 列且中间有连续逗号（空奖金），`split(",")` 产生的数组长度是固定的 8，但**下标容易数错**。

| 现象 | 原因 | 修法 |
|---|---|---|
| 输出的是日期或工资 | 下标数错 | 岗位是第 3 列 → 下标 `2` |
| `ArrayIndexOutOfBounds` | 行末有缺失字段 | 取值前检查数组长度 |

### 坑四：以为多 reduce 会重复

与直觉相反，多 reduce **不会**产生重复行——同一个 key 只落一个分区。

| 现象 | 原因 | 修法 |
|---|---|---|
| 输出被拆成多个文件 | 多个 reduce 各写一份 | 属正常；需要单文件时设 1 |
| 担心跨文件重复 | 误以为 key 会广播 | 分区函数只依赖 key，不可能重复 |

### 坑五：在 Mapper 里用 Set 假装去重

`Set` 只在单个 map 任务的内存里有效，跨任务无效，因此结果**可能**正确、**可能**错误，比稳定错误更难排查。

| 现象 | 原因 | 修法 |
|---|---|---|
| 数据量大时对了，量小时错了 | 小数据全落一个 map 任务，侥幸通过 | 去重必须在 reduce 端做 |

## 小结

本案例的代码是全部案例里最短的，但它揭示的机制最重要：**分组是 MapReduce 的核心能力，去重只是它的一种用法**。

### 三句话回顾

- Reduce 的每个 key 只调用一次 reduce 方法，所以"每组输出一行"就是去重。
- value 用 `NullWritable`、reduce 里不遍历 `values`，是去重的标准写法。
- 同一个 key 只落一个分区，所以去重对 reduce 个数不敏感——这一点与排序恰好相反。

### 与下一案例的衔接

本案例用单字段当 key。下一案例"多表关联"会把两个数据集拼进同一个 key 空间，靠**打标签**在 reduce 端区分数据来源——分组键仍然是全部设计的核心，只是这次一组里会混着两种来源的数据。

<div class="end"><h1>数据去重</h1><p>下一案例：多表关联</p></div>
