---
marp: true
headingDivider: 6
theme: python-mini-pptx
book: 大数据技术原理与应用
title: MapReduce Combiner
subtitle: 
author: 屈庆涛
date: 2026-09-13 14:00:00
categories:
- Hadoop
tags:
- Hadoop
- MapReduce
- Partitioner
mode: slide
keywords: Mapper, Reducer, Partitioner, Hash, MapReduce,Job, Key
semicolons: true
# ── mdcode2run：文档级执行默认 ──────────────────────
code-exec:
  java:
    JAVA_HOME: "D:/Program Files/Java/jdk-17.0.20.1"
    class-path: "D:\bigdata\hadoop\hadoop-3.1.3\share\hadoop\common\*;D:\bigdata\hadoop\hadoop-3.1.3\share\hadoop\common\lib\*"
  python:
    PYTHON_PATH: "D:/ProgramData/anaconda3/python.exe"
  mysql:
    HOST: db.example.com          # PASSWORD 不能放这里（秘密只在引擎层）
    DATABASE: bigdata
mr-job:
  name: WordCount
  types:
    in: LongWritable, Text
    map-out: Text, IntWritable
    out: Text, IntWritable
  combine: reduce
  input: data/bigdata.txt
  output: out/wordcount
---


**环境**：Hadoop 3.x，Java 8+，本地模式或伪分布式
**配套代码**：WordCount 优化、平均值统计、反例演示

---

## 一、学习目标

学完本讲，学员应能：

1. 说清 Combiner 的**执行位置、执行时机、执行次数的不确定性**；
2. 说明 Combiner 与 Reducer 的**异同**，并解释"为什么常复用 Reducer 类"；
3. 判断一个聚合逻辑**能否**安全地用作 Combiner（结合律 / 交换律 / 不丢信息）；
4. 编写自定义 Combiner，解决"平均值"这类不能直接复用 Reducer 的问题；
5. 通过 Job Counters **验证** Combiner 是否生效，并评估其收益。

---

## 二、动机：MapReduce 的瓶颈在哪里

考虑一个日志统计任务：10 亿条记录，Map 输出 10 亿个 `<word, 1>`。

若没有 Combiner：

```
Map 端输出 10 亿条  →  写入本地磁盘  →  网络传输到 Reduce 端  →  Shuffle 排序  →  Reduce
```

问题：

- **磁盘 I/O**：Map 输出先落盘（spill），数据量大；
- **网络 I/O**：Shuffle 是 MapReduce 中最昂贵的阶段；
- **Reduce 端压力**：排序、归并的数据量巨大。

但注意：`<hello,1>` 在同一个 Map 内可能重复出现上万次，**完全可以在本地先合并**。这就是 Combiner 的出发点。

> **一句话**：Combiner = 在 Map 端提前做一次"小规模 Reduce"，把 `(k,v1),(k,v2),...` 压成更少的记录，减少落盘和网络传输。

---

## 三、Combiner 是什么

### 3.1 定义

Combiner 是 MapReduce 框架提供的**可选的 Map 端局部聚合组件**，其接口与 Reducer 完全相同：

```java
public class MyCombiner extends Reducer<KEYIN, VALUEIN, KEYOUT, VALUEOUT> {
    @Override
    protected void reduce(KEYIN key, Iterable<VALUEIN> values, Context context) { ... }
}
```

通过 Driver 注册：

```java
job.setCombinerClass(MyCombiner.class);
```

### 3.2 执行位置与时机

```
         Map 端                                   Reduce 端
┌──────────────────────────┐          ┌───────────────────────────┐
│ Mapper                   │          │                           │
│   ↓ 输出 <k,v> 写入环形缓冲区 │          │                           │
│   ↓ 缓冲区达阈值 → spill     │          │                           │
│ 【Combiner 在此执行】       │          │                           │
│   ↓ 分区 + 排序 + 合并      │          │                           │
│   ↓ 写本地磁盘（临时文件）   │          │                           │
│ 【merge 多个 spill 时可再执行】│  ──────→ │ Shuffle / Sort / Group    │
│   ↓ 最终 Map 输出           │  网络传输  │   ↓                       │
└──────────────────────────┘          │ Reducer（全局聚合）        │
                                       └───────────────────────────┘
```

要点：

- Combiner 在 **spill（溢写）阶段** 对**已按 key 排序**的缓冲区数据执行；
- 在 **merge 多个 spill 文件** 时**可能**再执行一次；
- **每个 Map 任务内独立执行**，不跨 Map；
- Combiner 只做局部聚合，**不改变分区**（不涉及 Partitioner）。

### 3.3 执行次数：不保证、不确定

这是最容易出错的一点：

- **可能执行 0 次**：Map 输出很小，未触发 spill；
- **可能执行 1 次**；
- **可能执行多次**：多次 spill、多次 merge。

因此：

> ⚠️ **不能假设 Combiner 一定执行，也不能假设它只执行一次。**
> 使用 Combiner 的前提是：**无论执行 0 次还是 N 次，最终结果都必须相同。**

### 3.4 硬约束：输入/输出类型必须与 Map 输出一致

```java
Mapper 输出：<K, V>
Combiner 输入：<K, Iterable<V>>
Combiner 输出：<K, V>        // 必须与 Mapper 输出类型一致！
Reducer 输入：<K, Iterable<V>>
```

因为 Combiner 的输出要继续参与分区、排序和 Shuffle，框架必须能把它当作"Map 输出"来对待。

这也解释了一个常见现象：

```java
// Reducer 输入 <Text, IntWritable>，输出 <Text, IntWritable> → 可复用
job.setCombinerClass(WordCountReducer.class);

// Reducer 输出 <Text, DoubleWritable> 而输入是 <Text, SumCount> → 不能直接复用
```

---

## 四、Combiner vs Reducer 对比

| 对比项                | Combiner                                     | Reducer                          |
| --------------------- | -------------------------------------------- | -------------------------------- |
| 执行位置              | Map 端（spill / merge）                      | Reduce 端                        |
| 作用范围              | **单个 Map 任务**内的局部数据                | 全局（同一 key 的所有 Map 输出） |
| 输入                  | Map 输出 `<K, Iterable<V>>`（已按 key 分组） | Shuffle 后 `<K, Iterable<V>>`    |
| 输出类型              | **必须**等于 Map 输出类型                    | 可任意                           |
| 是否必执行            | **不保证**，0~N 次                           | 每个 (分区, key) 必执行一次      |
| 是否可复用 Reducer 类 | 类型兼容且逻辑满足结合律时可复用             | —                                |
| 失败影响              | 无（只是优化）                               | 影响正确性                       |
| 数量                  | 随 Map 任务                                  | 由 `setNumReduceTasks` 决定      |

> **结论**：Combiner 是**优化手段**，Reducer 是**计算语义**。Combiner 删掉不影响结果正确性，只影响性能；Reducer 删掉则结果错误。

---

## 五、核心判据：什么样的逻辑能做 Combiner

Combiner 本质上要求聚合函数 `f` 满足：

1. **结合律**：`f(f(a,b),c) = f(a,f(b,c))`
2. **交换律**：`f(a,b) = f(b,a)`（因为分组顺序不确定）
3. **不丢失后续计算所需的信息**

只要满足这些，无论 Combiner 执行几次、如何分组，结果都不变。

| 聚合操作                   | 能否用 Combiner         | 说明                      |
| -------------------------- | ----------------------- | ------------------------- |
| Sum / Count                | ✅                       | 结合 + 交换               |
| Max / Min                  | ✅                       | 结合 + 交换               |
| 平均值                     | ❌（直接平均）           | 丢失 count 权重           |
| 平均值                     | ✅（改为 `(sum,count)`） | 保留权重信息              |
| 中位数 / 分位数            | ❌                       | 不可局部合并              |
| 去重计数（distinct count） | ❌（直接相加）           | 同一元素跨 Map 会重复计数 |
| 字符串拼接                 | ⚠️                       | 结果依赖顺序，通常不可用  |

---

## 六、案例一：WordCount 复用 Reducer

```java
public class WordCountMapper extends Mapper<LongWritable, Text, Text, IntWritable> {
    private final Text word = new Text();
    private final static IntWritable ONE = new IntWritable(1);

    @Override
    protected void map(LongWritable key, Text value, Context context)
            throws IOException, InterruptedException {
        for (String w : value.toString().split("\\s+")) {
            if (w.isEmpty()) continue;
            word.set(w);
            context.write(word, ONE);
        }
    }
}

public class WordCountReducer extends Reducer<Text, IntWritable, Text, IntWritable> {
    private final IntWritable result = new IntWritable();

    @Override
    protected void reduce(Text key, Iterable<IntWritable> values, Context context)
            throws IOException, InterruptedException {
        int sum = 0;
        for (IntWritable v : values) sum += v.get();
        result.set(sum);
        context.write(key, result);
    }
}
```

Driver 中：

```java
job.setMapperClass(WordCountMapper.class);
job.setReducerClass(WordCountReducer.class);
job.setCombinerClass(WordCountReducer.class);   // 关键：类型兼容 + 求和满足结合律

job.setMapOutputKeyClass(Text.class);
job.setMapOutputValueClass(IntWritable.class);
job.setOutputKeyClass(Text.class);
job.setOutputValueClass(IntWritable.class);
```

**为什么可以复用？** 因为求和满足结合律、交换律，且 Combiner 的输入输出都是 `<Text, IntWritable>`，与 Map 输出类型一致。

**效果**：原本 Map 输出 N 条，Combiner 后可能只剩"每个 Map 内不同单词数"条，Shuffle 数据量大幅下降。

---

## 七、案例二：平均值 —— 自定义 Combiner

### 7.1 错误做法

```java
// ❌ 错误：直接对局部平均值再求平均
public class AvgCombiner extends Reducer<Text, IntWritable, Text, IntWritable> {
    protected void reduce(Text key, Iterable<IntWritable> values, Context ctx) {
        int sum = 0, cnt = 0;
        for (IntWritable v : values) { sum += v.get(); cnt++; }
        ctx.write(key, new IntWritable(sum / cnt));   // 输出局部平均值
    }
}
```

数据：Map1 处理 `1,2,3` → 输出 `2`；Map2 处理 `4` → 输出 `4`；Reducer 平均 → `3`，而正确结果是 `2.5`。

**根本原因**：平均值丢失了"样本数量"这个权重，`avg(A∪B) ≠ (avg(A)+avg(B))/2`。

### 7.2 正确做法：携带 `(sum, count)`

**自定义 Writable：**

```java
public class SumCountWritable implements Writable {
    private long sum;
    private long count;

    public SumCountWritable() {}
    public SumCountWritable(long sum, long count) { this.sum = sum; this.count = count; }

    public void add(SumCountWritable o) { this.sum += o.sum; this.count += o.count; }
    public long getSum()   { return sum; }
    public long getCount() { return count; }

    @Override
    public void write(DataOutput out) throws IOException {
        out.writeLong(sum);
        out.writeLong(count);
    }

    @Override
    public void readFields(DataInput in) throws IOException {
        sum = in.readLong();
        count = in.readLong();
    }

    @Override
    public String toString() { return sum + "/" + count; }
}
```

**Mapper：输出 `<Text, SumCountWritable>`**

```java
public class AvgMapper extends Mapper<LongWritable, Text, Text, SumCountWritable> {
    private final Text key = new Text();
    private final SumCountWritable val = new SumCountWritable();
    private final LongWritable dummy = new LongWritable();

    @Override
    protected void map(LongWritable k, Text value, Context context)
            throws IOException, InterruptedException {
        // 输入格式： "类别\t数值"
        String[] parts = value.toString().split("\t");
        key.set(parts[0]);
        val.setSum(Long.parseLong(parts[1]));  // 注意：框架会复用对象，需每次重置
        val.setCount(1);
        context.write(key, val);
    }
}
```

**Combiner：类型必须与 Map 输出一致**

```java
public class AvgCombiner extends Reducer<Text, SumCountWritable, Text, SumCountWritable> {
    private final SumCountWritable out = new SumCountWritable();

    @Override
    protected void reduce(Text key, Iterable<SumCountWritable> values, Context context)
            throws IOException, InterruptedException {
        long s = 0, c = 0;
        for (SumCountWritable v : values) {
            s += v.getSum();
            c += v.getCount();
        }
        out.setSum(s);
        out.setCount(c);
        context.write(key, out);       // ✅ 输出 (sum, count)，未丢失权重
    }
}
```

**Reducer：计算最终平均值**

```java
public class AvgReducer extends Reducer<Text, SumCountWritable, Text, DoubleWritable> {
    private final DoubleWritable out = new DoubleWritable();

    @Override
    protected void reduce(Text key, Iterable<SumCountWritable> values, Context context)
            throws IOException, InterruptedException {
        long s = 0, c = 0;
        for (SumCountWritable v : values) { s += v.getSum(); c += v.getCount(); }
        out.set((double) s / c);
        context.write(key, out);
    }
}
```

> **注意**：此处 Reducer 的输入类型 `<Text, SumCountWritable>` 与输出类型 `<Text, DoubleWritable>` **不同**，所以**不能**把 `AvgReducer` 直接当 Combiner 用，必须单独写 `AvgCombiner`。

### 7.3 教学讨论点

- 为什么 `(sum, count)` 可合并？因为它**完整保留了**计算平均值所需的全部信息；
- 这是一个通用模式：**把"不可合并的聚合"转化为"可合并的中间状态"**——类似 SQL 中的 `STDDEV`、`AVG` 在分布式执行引擎内部的实现。

---

## 八、案例三：反例——去重计数（Distinct Count）

需求：统计每个类别下**不同用户**的数量。

```java
// Map 输出 <类别, userId>
// 若 Combiner 输出 <类别, 该 Map 内 distinct 数量>
```

问题：同一 userId 可能出现在 Map1 和 Map2 中，各自计数为 1，Combiner 相加得 2，**重复计数**。

正确方案：

- Map 输出 `<类别, userId>`，用 `<类别, userId>` 作为 key 去重；
- 或 Map 端用 `Set` 局部去重后再输出 `<类别, userId>`，Reducer 用 `Set` 全局去重后 `size()`；
- 关键点：**中间结果必须是可合并的集合/去重集合，而不是"计数"**。

类似地，**中位数、Top-N 的某些实现、依赖顺序的字符串拼接**都不适合直接做 Combiner。

---

## 九、实验：观察 Combiner 的效果

### 9.1 观察 Counters

运行作业后，在控制台或 JobHistory 中查看：

```
Combine input records=1000000
Combine output records=13742
Map output records=1000000
Map output bytes=...
Reduce shuffle bytes=...
```

- `Combine input records` / `Combine output records` **为 0** → Combiner **未执行**（Map 输出太小未 spill，或未注册）；
- 两者比值反映**压缩比**，比值越大收益越明显。

### 9.2 对比实验

| 组别 | 配置                             | 观察指标                                           |
| ---- | -------------------------------- | -------------------------------------------------- |
| A    | 不设 Combiner                    | `Map output records`、`Reduce shuffle bytes`、耗时 |
| B    | 设 Combiner（WordCount）         | 同上，对比降幅                                     |
| C    | 用错误 Combiner 求平均           | 输出结果与正确值不符                               |
| D    | 用 `(sum,count)` Combiner 求平均 | 结果正确 + Shuffle 降低                            |

> **教师提示**：可用 `-D mapreduce.job.reduces=1` 并在小数据集上运行，便于快速观察；若本地数据量不足触发 spill，可调小 `mapreduce.map.sort.spill.percent` 或加大输入数据。

### 9.3 验证"不保证执行"

- 用极小的输入（如 3 行文本）运行 WordCount + Combiner，观察 `Combine input records` 是否为 0；
- 让学员理解：**结果正确性不能依赖 Combiner 执行**。

---

## 十、常见坑与最佳实践

### 常见坑

1. **以为 Combiner 一定执行** → 结果依赖执行次数，产生不确定行为；
2. **Combiner 输出类型与 Map 输出不一致** → 运行时报类型错误或结果异常；
3. **直接把求平均/中位数/去重的 Reducer 复用为 Combiner** → 结果错误；
4. **在 Combiner 中保存 `Iterable` 中的对象引用** → 框架会复用 value 对象，导致数据错乱；
   ```java
   // ❌ 危险
   List<IntWritable> list = new ArrayList<>();
   for (IntWritable v : values) list.add(v);   // 引用被复用！
   ```
5. **在 Combiner 中做副作用**（写外部系统、计数依赖）→ Combiner 执行次数不确定，不可靠；
6. **期望 Combiner 替代 Reducer** → Combiner 只在 Map 端局部聚合，全局聚合仍由 Reducer 完成；
7. **Reduce 数量为 0 时** Combiner 也不会执行（纯 Map 作业无 Combine 阶段）。

### 最佳实践

- 优先使用**求和、计数、最值**等天然可结合的聚合；
- 复杂聚合（平均、方差、去重）→ **设计可合并的中间状态**（`(sum,count)`、`(sum,sumSq,count)`、`Set`）；
- 用 Counters 验证收益，**数据量小时收益可忽略**；
- Combiner 逻辑保持**纯函数**、无副作用；
- 类型兼容且逻辑满足结合律时，才复用 Reducer 类。

---

## 十一、课堂练习

**练习 1（判断）** 下列哪些可以作为 Combiner？说明理由。
(a) 求和 (b) 求最大值 (c) 求方差 (d) 统计不同 IP 数 (e) 拼接字符串（顺序敏感）

**练习 2（改错）** 下面的 Combiner 用于统计每类商品的平均价格，找出错误并修正：

```java
public class PriceCombiner extends Reducer<Text, DoubleWritable, Text, DoubleWritable> {
    protected void reduce(Text key, Iterable<DoubleWritable> values, Context ctx) {
        double sum = 0; int cnt = 0;
        for (DoubleWritable v : values) { sum += v.get(); cnt++; }
        ctx.write(key, new DoubleWritable(sum / cnt));
    }
}
```

**练习 3（设计）** 设计一个计算**方差**的 Combiner，说明中间状态应包含哪些字段，为什么。

**练习 4（实验）** 在 WordCount 作业中分别开启/关闭 Combiner，记录 `Map output records`、`Combine input/output records`、`Reduce shuffle bytes` 和执行时间，制作对比表格并给出结论。

**练习 5（思考）** 如果 Combiner 执行了 3 次（3 次 spill），WordCount 结果会变吗？如果换成"求平均值的错误 Combiner"呢？为什么？

---

## 十二、小结

| 要点            | 结论                                                     |
| --------------- | -------------------------------------------------------- |
| 本质            | Map 端可选的局部聚合器，用于减少 spill 与 Shuffle 数据量 |
| 与 Reducer 关系 | 接口相同，常复用；但**语义、位置、执行保证**不同         |
| 硬约束          | 输入/输出类型必须与 Map 输出一致                         |
| 执行保证        | **0~N 次，不保证**，正确性不能依赖它                     |
| 使用前提        | 聚合满足结合律、交换律，且中间状态不丢信息               |
| 典型可用        | sum、count、max、min、`(sum,count)`                      |
| 典型不可用      | 直接平均、中位数、distinct count、顺序敏感拼接           |

> **一句话收尾**：Combiner 是"Map 端的性能优化器"，不是"Reduce 的替代品"；它能不能用，取决于你的聚合函数是否**可结合、可交换、且不丢信息**。

---

## 附录：延伸阅读

- Hadoop 官方文档：`mapreduce.job.combine.class` 参数说明
- 论文：*MapReduce: Simplified Data Processing on Large Clusters*（Dean & Ghemawat, 2004）中关于 Combiner 的描述
- 类比：Spark 的 `reduceByKey`（Map 端预聚合）vs `groupByKey`（无预聚合）
- 进阶：二次排序、Map-side Join、Combiner 在 merge 阶段的复用