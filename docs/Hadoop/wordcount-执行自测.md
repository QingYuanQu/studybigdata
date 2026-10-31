---
title: WordCount 执行自测
categories:
- Hadoop
tags:
- MapReduce
- WordCount
- 自测
code-exec:
  java:
    JAVA_HOME: "D:/Program Files/Java/jdk-17.0.20.1"
    class-path: "D:/bigdata/hadoop/hadoop-3.1.3/share/hadoop/common/*;D:/bigdata/hadoop/hadoop-3.1.3/share/hadoop/common/lib/*"
---

本文档用于**自测可执行讲义功能**（物化 / 引导块 / 会话 / 作业 / 重放 / 过期链），不是授课讲义。
数据与标本（4-1-1）刻意不同——每个块都跑对了，才能证明机制在工作，而不是巧合。

# 准备：输入数据

输入 `bigdata.txt`，3 行，以文件块随讲义自包含（会话建立时物化进本章工作目录）：

```text file=bigdata.txt
a b
a b c
c a
```

预期输出，按单词升序：

| 单词 | 次数 |
| ---- | ---- |
| a    | 3    |
| b    | 2    |
| c    | 2    |

# 单机版：不用 Hadoop 数一遍

读文件、切词、用 `HashMap` 累加——直接 ▶，读到的就是上面的三行：

```java
Map<String, Integer> counts = new HashMap<>();

try (BufferedReader reader = new BufferedReader(new FileReader("bigdata.txt"))) {
    String line;
    while ((line = reader.readLine()) != null) {
        for (String word : line.split(" ")) {
            counts.put(word, counts.getOrDefault(word, 0) + 1);
        }
    }
}

counts.forEach((word, count) -> System.out.println(word + "\t" + count));
```

# 拆解：mapper 与 reducer 片段

真实拆解讲义里，map / reduce 方法体不是完整程序——本章会话由引导块开路：把框架调用你的那一刻的
入参（当前行 `value`、同词列表 `values`）和收集输出的 `context` 备好，片段即可原样执行。引导块在
会话建立时**自动执行**，也可以手动 ▶ 看它的内容。

```java setup
// 脚手架：模拟"框架调用你"的那一刻（幂等，重放时重跑无害）
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

class MockContext {
    List<String> out = new ArrayList<>();
    void write(Text word, IntWritable count) {
        out.add(word + "\t" + count);
    }
}

// map 的世界：当前行取输入第 2 行 "a b c"，收集输出的 context
Text value = new Text("a b c");
LongWritable offset = new LongWritable(0);
MockContext context = new MockContext();

// reduce 的世界：当前词 key、同词的 value 列表（图解里 a 的 <a,[1,1,1]>）
Text key = new Text("a");
Iterable<IntWritable> values = Arrays.asList(new IntWritable(1), new IntWritable(1), new IntWritable(1));
```

步骤二：mapper 方法体。直接 ▶（引导块会自动先跑）：

```java
String[] wordArray = value.toString().split(" ");

IntWritable one = new IntWritable(1);

for (String word : wordArray) {
    context.write(new Text(word), one);
}
```

检查点一：看 mapper 发出了什么——`<a,1> <b,1> <c,1>`：

```java
context.out;
```

步骤三：reducer 方法体，消费 `values` 累加：

```java
int count = 0;
for (IntWritable value : values) {
    count += value.get();
}
context.write(key, new IntWritable(count));
```

检查点二：末尾应多出 `a	3`：

```java
context.out;
```

初学者最容易绕过的弯：value 为什么是常量 `1` 不是单词本身？看两张对照表就够了——

```java demo
map(输入 key, 输入 value, Context)  →  context.write(输出 key, 常量 1)
```

| 写法           | 含义           | 问题                            |
| -------------- | -------------- | ------------------------------- |
| `<word, word>` | 把单词再发一遍 | reduce 端还得自己数个数，没意义 |
| `<word, 1>`    | 发一个计数器   | reduce 把一堆 `1` 加起来即可    |

# 模拟作业：日志流与终止

先跑一条前置检查（普通一次性执行）：

```bash
echo "检查本地环境：bash 与 JDK 就位"
java -version 2>&1 | head -1
```

再把作业标上 `job`：启动即返回，状态条计时、日志实时滚、随时终止。跑满约 24 秒，
足够先点一次"终止"、再 ▶ 一次让它自然完成：

```bash job
echo "启动 WordCount 作业（本地模拟，无集群）"
for i in 1 2 3 4 5 6 7 8 9 10 11 12; do
  echo "$(date +%T)  map 3/3 complete  reduce $((i * 8))%"
  sleep 2
done
echo "作业完成：output/part-r-00000"
```

真实集群上的对应命令长这样（转写展示，不执行）：

```bash demo
[zhangsan@node0 ~]$ hadoop jar hadoop-1.0-SNAPSHOT.jar /input/bigdata.txt /output/wordcount
26/10/24 19:00:00 INFO mapreduce.Job:  map 100% reduce 100%
[zhangsan@node0 ~]$ jps
53296 ResourceManager
103509 YarnChild
```

# 自测清单

| # | 功能点         | 操作                                   | 预期                                                       |
| - | -------------- | -------------------------------------- | ---------------------------------------------------------- |
| 1 | file= 物化     | ▶ 单机版块                             | 输出 a 3 / b 2 / c 2（读到的是文件块的三行）               |
| 2 | setup 自动引导 | 不碰引导块，直接 ▶ 步骤二              | 引导块自动先跑，片段正常执行                               |
| 3 | 会话状态链     | ▶ 两个检查点块                         | 检查点一 3 条 `<词,1>`；检查点二多出 `a	3`            |
| 4 | 过期链         | 改 mapper 块任一字符，▶ 检查点二       | 卡片标"过期"，提示 ⏩ 连跑                                  |
| 5 | 重放           | 在检查点二点 ⏩                        | setup→步骤二→步骤三→检查点二按序连跑，最后一块的输出上屏   |
| 6 | 作业：终止     | ▶ 模拟作业块，几秒后点"终止"           | 状态条"已终止 · Xs"，日志停在终止那一刻                    |
| 7 | 作业：自然完成 | 再 ▶ 一次，等约 24 秒                  | 状态条"完成 · Xs"，末行 `作业完成`                          |
| 8 | 重放跳过作业   | 在作业块上点 ⏩                        | 前置检查被重跑，注明"跳过 1 个作业块"                      |
| 9 | demo 无 ▶      | 看伪代码块与集群转写块                 | 没有 ▶ 按钮；text/xml 等未注册语言同样没有                 |
