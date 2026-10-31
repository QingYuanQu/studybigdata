---
marp: true
headingDivider: 2
theme: python-mini-pptx
title: 从零组装一个完整 Job · 部门分区
date: 2026-10-25
categories:
- Hadoop
tags:
- Hadoop
- MapReduce
- Partitioner
- 演进式教学

JAVA_HOME: D:\Program Files\Java\jdk1.8.0_471
---

<div class="cover"><h1>从零组装一个完整 Job</h1><p>把 MapReduce 拆成零件，边讲边长，最后拼成可运行的部门分区 Job</p></div>

# 本篇主线：边讲边长

一份合格的教学文档，不该把"自定义分区器"当成一个孤立知识点讲完就结束。它应该是**一个完整 Job 的零件之一**——我们先看这个 Job 最终长什么样、跑出什么，再把它拆回零件，逐个加回去，每加一个就重新编译运行一次，对比输出变化。

你在本篇看到的每一段代码，都逐字对应工程里的真实文件，复制即可运行：

```
code/hadoop/src/main/java/com/studybigdata/hadoop/mapred/dpartition/
├── DeptMain.java          # 零件④ Driver：把下面四个零件装配成 Job
├── DeptMapper.java        # 零件① Mapper：解析每行 → <部门号, 员工>
├── DeptPartitioner.java   # 零件③ Partitioner：决定每条记录去哪个文件
├── DeptReduce.java        # 零件② Reducer：同一部门的员工聚到一起
└── Employee.java          # 前置零件：可序列化的员工对象（见序列化篇）
```

## 演进路线

| 里程碑 | 加入的零件 | 此刻 Job 的关键配置 | 跑出来的样子 |
| ------ | ---------- | ------------------ | ------------ |
| 0 | （先看结果） | 完整 Job | 3 个文件，部门 10 / 20 / 30 各一个 |
| 1 | Mapper | `setMapperClass` | 每行变一条 `<部门号, 员工>` 记录 |
| 2 | + Reducer | `+ setReducerClass` | 同一部门的员工被归并 |
| 3 | + Partitioner + `setNumReduceTasks` | `+ setPartitionerClass + setNumReduceTasks(3)` | 一个部门落进一个文件 |
| 4 | Driver 全貌 | `DeptMain` 完整 | 组合成完整可运行 Job |

> 这条路线的核心：**零件先独立讲清，再组合成完整 Job；每步都可运行、可对比。**

# 里程碑 0：先看到终点

目标：让 **14 行员工数据，按部门号落进 3 个独立文件**——`part-r-00000` 装 10 号部门、`part-r-00001` 装 20 号、`part-r-00002` 装 30 号。

输入 `emp.csv`（无表头，共 14 行）：

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

预期输出（详见文末「运行」小节，已用脚本验证逻辑）：

| 输出文件 | 部门号 | 员工数 |
| -------- | ------ | ------ |
| part-r-00000 | 10 | 3 |
| part-r-00001 | 20 | 5 |
| part-r-00002 | 30 | 6 |

> **文件名与部门号的对应关系，正是由分区器决定的**——不是 Hadoop 自动给的。这就是本案例要讲清楚的事。

# 零件① Mapper：把一行变成一条记录

## 它解决什么

MapReduce 处理的不是"行"，而是 `<key, value>` 对。Mapper 的职责就是**把原始文本行，翻译成我们想要的中间键值对**。

本案例里，key 选「部门号」、value 选「完整员工对象」——因为"按部门分文件"和"同部门聚合"都依赖部门号当 key。

## 代码（对应 `DeptMapper.java`）

```java
package com.studybigdata.hadoop.mapred.dpartition;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

import java.io.IOException;

public class DeptMapper extends Mapper<LongWritable, Text, IntWritable, Employee> {
    //7369,SMITH,CLERK,7902,1980/12/17,800,,20
    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {

        String lineContent = value.toString();
        // [7369,SMITH,CLERK,7902,1980/12/17,800,,20]
        String[] empArray = lineContent.split(",");

        int empId = Integer.parseInt(empArray[0]);
        String name = empArray[1];
        String position = empArray[2];
        int otherId = -1;
        try {
            otherId = Integer.parseInt(empArray[3]);
        }catch (Exception e){
            System.out.println("员工老板的id没有获取到，使用了前面设置的默认值： -1");
        }
        String hireDate = empArray[4];
        int salary = Integer.parseInt(empArray[5]);
        int bonus = 0;
        try {
            bonus = Integer.parseInt(empArray[6]);
        }catch (Exception e){
            System.out.println("无奖金，bonus设置为零");
        }
        int deptId = Integer.parseInt(empArray[7]);

        Employee employee = new Employee(empId, name, position, otherId, hireDate, salary, bonus, deptId);

        context.write(new IntWritable(deptId), employee);
    }
}
```

## 演进意义

- Mapper 的**输出类型** `<IntWritable, Employee>` 决定了整个 Job 中间数据的形态，后面所有零件都得和它对齐。
- `Employee` 是一个自定义的 `Writable` 对象（序列化篇详讲），因为只有它能把整行员工信息当作 value 在网络上传输。

## ⚠️ 可运行陷阱：数据不能有表头

`DeptMapper` **没有跳过首行**。如果 `emp.csv` 带 `empno,ename,...` 表头，`Integer.parseInt("deptno")` 会直接抛异常让任务失败。本案例数据文件**不含表头**——这是文档与工程对齐后才能发现的细节，也是"文档可运行"必须讲清楚的点。

# 零件② Reducer：把同部门的员工聚到一起

## 它解决什么

Shuffle 阶段会按 key（部门号）把记录分组，Reducer 拿到的是「一个部门号 → 该部门所有员工」。本案例 Reducer 不做聚合计算，只是**原样写出**，让同一部门的所有员工进入同一个输出流。

## 代码（对应 `DeptReduce.java`）

```java
public class DeptReduce extends Reducer<IntWritable, Employee, IntWritable, Text> {
    @Override
    protected void reduce(IntWritable dept, Iterable<Employee> employees, Context context) throws IOException, InterruptedException {

        for (Employee employee : employees) {
            context.write(dept, new Text(employee.toString()));
        }
    }
}
```

## 演进意义

- Reducer 的**输入类型**必须和 Mapper 的输出类型一致：`<IntWritable, Employee>`。
- 它的**输出类型**换成了 `<IntWritable, Text>`——最终落盘的是员工对象的文本形式。

> 到这里，如果只配 `Mapper + Reducer`（不设分区器、默认 1 个 Reduce），所有部门会混在一个文件里。分区，是下一步才发生的事。

# 零件③ Partitioner：决定一条记录去哪个文件

## 它解决什么

默认情况下，一个 Job 只有 1 个 Reduce，所有数据进同一个文件。Partitioner 的职责就是**在 Shuffle 之前，按 key 决定每条记录交给哪个 Reduce 任务**——进而决定它进哪个输出文件。

## 默认分区器为什么不够

默认 `HashPartitioner` 只有一行核心逻辑：

```java
(key.hashCode() & Integer.MAX_VALUE) % numPartitions
```

对部门号 10 / 20 / 30 来说，取模 3 的结果是 1 / 2 / 0——**三个部门确实分散到了三个文件，但文件名和部门号对不上**：`part-r-00000` 里装的是 30 号部门。业务方拿到文件无法凭名字判断内容。

## 自定义分区器（对应 `DeptPartitioner.java`）

```java
package com.studybigdata.hadoop.mapred.dpartition;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.mapreduce.Partitioner;

public class DeptPartitioner extends Partitioner<IntWritable, Employee> {

    /**
     * 部门号是不连续的（10、20、30），直接取余并不能实现"一个部门一个文件"：
     * 10 % 3 == 1、20 % 3 == 2、30 % 3 == 0，分区号与部门顺序对不上。
     * 这里做显式映射——部门 10 → 分区 0、20 → 1、30 → 2；
     * 最后再与 numPartitions 取余，保证任何 reduce 个数下返回值都落在 [0, numPartitions)。
     */
    @Override
    public int getPartition(IntWritable key, Employee value, int numPartitions) {

        int deptId = key.get();

        // 部门号 / 10 - 1：10 → 0、20 → 1、30 → 2、40 → 3 ...
        int partition = Math.abs(deptId / 10 - 1);

        // 与 numPartitions 取余，保证返回值永远落在 [0, numPartitions)
        // （numPartitions 即 job.setNumReduceTasks(n) 的值）
        return partition % numPartitions;
    }
}
```

## 演进意义

- 分区函数**只能依赖 key**（部门号），不能读 value——否则同一个部门号配上不同员工会得到不同分区，"一个部门一个文件"立刻失效。
- 末尾 `% numPartitions` 不能省：返回值越界会直接让任务抛 `IllegalArgumentException`。

# 零件④ Driver：把零件装配成 Job

## 它解决什么

`DeptMain` 是唯一告诉框架"用哪些零件、怎么接起来"的地方。前面三个零件只是类，真正让它们生效的是这里的配置。

## 完整代码（对应 `DeptMain.java`）

```java
package com.studybigdata.hadoop.mapred.dpartition;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

import java.io.IOException;

public class DeptMain {

    //hadoop jar xxx.jar arg0 arg1
    public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {

        Configuration configuration = new Configuration();
        //create a mapreduce job
        Job job = Job.getInstance(configuration);


        job.setJarByClass(DeptMain.class);

        job.setMapperClass(DeptMapper.class);

        job.setMapOutputKeyClass(IntWritable.class);
        job.setMapOutputValueClass(Employee.class);

        // 部门号有 10、20、30 三种，故开 3 个 Reduce 任务 → 3 个输出文件
        job.setNumReduceTasks(3);
        job.setPartitionerClass(DeptPartitioner.class);

        job.setReducerClass(DeptReduce.class);
        //<word,3>
        job.setOutputKeyClass(IntWritable.class);
        job.setOutputValueClass(Text.class);

        //input path
        //output path
        FileInputFormat.setInputPaths(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        job.waitForCompletion(true);

    }
}
```

## 两行配置必须成对出现

```java
job.setNumReduceTasks(3);                 // 定义分区号值域 [0,3)，同时决定文件个数
job.setPartitionerClass(DeptPartitioner.class);  // 决定 key→分区的映射
```

- 只设 Partitioner、不设 `setNumReduceTasks` → 默认 1 个 Reduce，**分区器根本不会被调用**。
- 设了 3 个 Reduce 但分区逻辑只产生 0~2 → 正好 3 个文件；若部门数超过 Reduce 数，多出的部门只能挤进已有分区。

# 完整 Job：五个零件拼在一起

把前面四个零件 + 前置的 `Employee` 放在一起，就是工程里 `dpartition` 包的全部内容。其中 `Employee` 是实现了 `Writable` 的可序列化对象（序列化篇详讲），此处给全量以便拼装：

```java
package com.studybigdata.hadoop.mapred.dpartition;

import org.apache.hadoop.io.Writable;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;

public class Employee implements Writable {
    //员工ID,名字, 职位, otherID,雇佣时间,工资,奖金,部门号
    //7369,SMITH,CLERK,7902,1980/12/17,800,   ,20
    private int empId;
    private String name;
    private String position;
    private int otherId;
    private String hireDate;
    private int salary;
    private int bonus;
    private int deptId;

    public Employee(int empId, String name, String position, int otherId, String hireDate, int salary, int bonus, int deptId) {
        this.empId = empId; this.name = name; this.position = position; this.otherId = otherId;
        this.hireDate = hireDate; this.salary = salary; this.bonus = bonus; this.deptId = deptId;
    }

    @Override
    public void write(DataOutput out) throws IOException {
        out.writeInt(this.empId); out.writeUTF(this.name); out.writeUTF(this.position);
        out.writeInt(this.otherId); out.writeUTF(this.hireDate); out.writeInt(this.salary);
        out.writeInt(this.bonus); out.writeInt(this.deptId);
    }

    @Override
    public void readFields(DataInput in) throws IOException {
        this.empId = in.readInt(); this.name = in.readUTF(); this.position = in.readUTF();
        this.otherId = in.readInt(); this.hireDate = in.readUTF(); this.salary = in.readInt();
        this.bonus = in.readInt(); this.deptId = in.readInt();
    }

}
```

## 预期输出（由代码逻辑确定）

```
---- 输出目录 ----
/output/partition/part-r-00000
/output/partition/part-r-00001
/output/partition/part-r-00002

===== part-r-00000  (行数 3) =====     # 部门 10
Employee{empId=7782, ..., deptId=10}
Employee{empId=7839, ..., deptId=10}
Employee{empId=7934, ..., deptId=10}

===== part-r-00001  (行数 5) =====     # 部门 20
...（7369 / 7566 / 7788 / 7876 / 7902）

===== part-r-00002  (行数 6) =====     # 部门 30
...（7499 / 7521 / 7654 / 7698 / 7844 / 7900）
```

**判据**：每个文件里的部门号必须唯一。若 `part-r-00000` 同时出现 10 和 40，说明取模那步把两个部门合并了（见下节变式 1）。

# 证伪实验：亲手跑过才记得住

| 变式 | 做法 | 观察到的现象 |
| ---- | ---- | ------------ |
| 1. 去掉 `% numPartitions` | 直接 `return deptId/10 - 1` | 部门号 ≥ 40 时分区号越界，任务抛异常 |
| 2. 只设 Partitioner | 注释掉 `setNumReduceTasks(3)` | 只剩 1 个文件，分区器根本没被调用 |
| 3. 数据带表头 | `emp.csv` 首行加 `empno,ename,...` | Mapper 解析表头 `deptno` 失败，任务崩溃 |

变式 1 演示「返回值必须落在 `[0, numPartitions)`」；变式 2 演示最常见失效场景；变式 3 演示前文提到的表头陷阱。三个都亲手改一遍，比记住结论有效。

# 理论精华：为什么这样设计

## 分区函数必须满足两条约束

| 约束 | 要求 | 违反后的现象 |
| ---- | ---- | ------------ |
| 值域 | 返回值必须落在 `[0, numPartitions)` | 任务抛 `IllegalArgumentException` |
| 稳定性 | 同一个 key 必须总是返回同一个分区 | 同一部门数据被拆到多个文件 |

## 一个"看起来自定义、实际没有"的反例

若把分区器写成：

```java
if (key.get() % numPartitions == 0)      return 0;
else if (key.get() % numPartitions == 1) return 1;
else                                     return 2;
```

在 `numPartitions = 3` 时，`key % 3` 只可能是 0/1/2，三个分支恰好等价于 `key % 3` 本身——**与默认 `HashPartitioner` 逐字节一致**。写了 8 行什么也没改变。

> 判断自定义分区器是否生效，不看它写没写，看**返回值是否和默认实现不同**。

## 分区不当会导致数据倾斜

| 分区策略 | 负载 | 后果 |
| -------- | ---- | ---- |
| 均匀哈希 | 各任务相近 | 正常 |
| 按业务键切分 | 取决于数据分布 | 大部门所在任务成瓶颈 |
| 全部挤进一个分区 | 单任务扛全量 | 其他任务空转 |

销售部 100 万人而其他部门几百人时，按部门分区会让一个 Reduce 独自处理绝大部分数据——这就是数据倾斜。分区器既是成因，也是解法。

# 小结

- 一个 Job = Driver + Mapper + Reducer + Partitioner（+ 前置 Writable 对象）等零件；**先独立讲清每个零件，再组合成完整 Job**。
- 分区器只有一行职责：给定 key，返回一个 `[0, numPartitions)` 内的分区号；它只能依赖 key。
- **文档可运行**：本篇每段代码逐字对应 `code/hadoop/.../dpartition/` 真实文件，配 `run-dpartition.sh` 一键编译运行；工程与文档已对齐（3 个 Reduce、`% numPartitions`）。

<div class="end"><h1>从零组装一个完整 Job</h1><p>下一案例：自定义排序（文件内的顺序）</p></div>
