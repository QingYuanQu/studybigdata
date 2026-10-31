# 实验：Computer 对象序列化

> 配套教程：4-3-1 ~ 4-3-5（Student → DataOut → Serializable → Writable → MapReduce 里的序列化）。
> 这次不用 Student，换成一台真实存在的机器——**你自己电脑上的 Computer**。

## 一、实验目的

1. 学会用 `InetAddress` 获取本机的主机名和 IP 地址；
2. 独立实现一个自定义 `Writable` 类（`ComputerWritable`），掌握 `write` / `readFields` 的对称写法；
3. 把自定义 Writable 用到 MapReduce 中作为 map 输出的 value，理解 shuffle 阶段的对象序列化；
4. 体会 Reducer 中「同一个实例反复填值」的规则及其陷阱。

## 二、实验环境

- JDK 8、Maven 工程（依赖 hadoop-client 3.1.3）
- Windows 本地模式即可运行（`winutils.exe` 已配置）

## 三、实验一：ComputerWritable 本地序列化

### 3.1 先拿到真实数据：本机的主机名和 IP

在写 Writable 类之前，先用两行 JDK 自带的代码，看看你自己的机器长什么样。
在任意类的 `main` 方法里写：

```java
import java.net.InetAddress;

InetAddress local = InetAddress.getLocalHost();
System.out.println("hostname = " + local.getHostName());
System.out.println("localIP  = " + local.getHostAddress());
```

运行后输出类似（各人机器不同）：

```
hostname = DESKTOP-3F8KQ2
localIP  = 192.168.1.105
```

这两个值，就是第一个 `Computer` 对象的真实数据。其余机器的数据我们手工编造（见实验二的样例数据）。

### 3.2 定义 ComputerWritable

在 `entity` 包里新建 `ComputerWritable`，字段三个：`id`（int）、`hostname`（String）、`ip`（String）。

要求（对照 4-3-4 篇 StudentWritable 的六步）：

1. **必须有无参构造**——Hadoop 反序列化时先反射 new 空对象，再 `readFields` 填值；
2. `write` 与 `readFields` **字段顺序必须完全一致**：id → hostname → ip；
3. String 字段用 `writeUTF` / `readUTF`，int 字段用 `writeInt` / `readInt`。

```java
package com.studybigdata.hadoop.java.entity;

import org.apache.hadoop.io.Writable;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;

/**
 * 一台机器：编号、主机名、IP。
 * 实现 Writable 后可以作为 MapReduce 中 map 输出的 value 跨机器传输。
 */
public class ComputerWritable implements Writable {

    private int id;
    private String hostname;
    private String ip;

    // 必须有无参构造：框架反序列化的第一步是 new 空对象
    public ComputerWritable() {
    }

    public ComputerWritable(int id, String hostname, String ip) {
        this.id = id;
        this.hostname = hostname;
        this.ip = ip;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getHostname() { return hostname; }
    public void setHostname(String hostname) { this.hostname = hostname; }
    public String getIp() { return ip; }
    public void setIp(String ip) { this.ip = ip; }

    // 序列化：三个字段的顺序是约定，写好后不可单方面改动
    @Override
    public void write(DataOutput out) throws IOException {
        out.writeInt(id);
        out.writeUTF(hostname);
        out.writeUTF(ip);
    }

    // 反序列化：读取顺序必须和 write 完全一致
    @Override
    public void readFields(DataInput in) throws IOException {
        this.id = in.readInt();
        this.hostname = in.readUTF();
        this.ip = in.readUTF();
    }

    @Override
    public String toString() {
        return "ComputerWritable{id=" + id + ", hostname='" + hostname + "', ip='" + ip + "'}";
    }
}
```

### 3.3 写出去、读回来

仿照 4-3-4 篇的 `StudentWritableOut` / `StudentWritableIn`，写两个测试类验证：

```java
// ComputerOut：写出
ComputerWritable c1 = new ComputerWritable(1,
        InetAddress.getLocalHost().getHostName(),
        InetAddress.getLocalHost().getHostAddress());

DataOutputStream dos = new DataOutputStream(new FileOutputStream("computer.bin"));
c1.write(dos);
dos.close();

// ComputerIn：读回
ComputerWritable c2 = new ComputerWritable();   // 先有对象，再填值
DataInputStream dis = new DataInputStream(new FileInputStream("computer.bin"));
c2.readFields(dis);
dis.close();
System.out.println(c2);
```

### 3.4 预期结果

控制台打印出与写入一致的对象：

```
ComputerWritable{id=1, hostname='DESKTOP-3F8KQ2', ip='192.168.1.105'}
```

另外右键查看 `computer.bin` 文件大小：约 30 字节左右（4 + 长度前缀+字符 + 长度前缀+字符）。可以和 4-3-3 篇 `Serializable` 的 127 字节对比，体会 Writable 的紧凑。

## 四、实验二：MapReduce 对象序列化——机房心跳稽核

### 4.1 业务背景：Reduce 阶段干什么

机房里的每台机器会周期性向监控服务器上报一条心跳：`编号,主机名,IP`。
运维关心两件事：

1. **每台机器上报了几次**（掉线的机器次数会偏少）；
2. **同一台主机每次上报的 IP 是否一致**（机器被重装或被抢占 DHCP 后会换 IP，是异常）。

所以 Reduce 按 `hostname` 分组，统计**上报次数 + 出现过的所有 IP**。这就是 value 必须是整个 `ComputerWritable` 对象而不是单个文本的理由——IP 是随心跳一起传过来的结构化数据。

### 4.2 样例数据

`data/writable/computers.txt`，12 行心跳（注意 node3 有一次上报用了不同的 IP）：

```csv
1,node1,192.168.1.101
2,node2,192.168.1.102
3,node3,192.168.1.103
4,node1,192.168.1.101
5,node2,192.168.1.102
6,node3,192.168.1.103
7,node1,192.168.1.101
8,node4,192.168.1.104
9,node3,10.0.0.103
10,node4,192.168.1.104
11,node2,192.168.1.102
12,node1,192.168.1.101
```

### 4.3 Mapper

四个泛型中，第 4 个是本实验的主角 `ComputerWritable`：

```java
package com.studybigdata.hadoop.mapred.cserializable;

import com.studybigdata.hadoop.java.entity.ComputerWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

import java.io.IOException;

/**
 * 把每行 "id,hostname,ip" 解析成 ComputerWritable，key 用主机名，便于按机器分组。
 */
public class ComputerMapper extends Mapper<LongWritable, Text, Text, ComputerWritable> {

    private final Text outKey = new Text();
    private final ComputerWritable outValue = new ComputerWritable();

    @Override
    protected void map(LongWritable key, Text value, Context context)
            throws IOException, InterruptedException {
        String line = value.toString().trim();
        if (line.isEmpty()) {
            return;
        }
        String[] parts = line.split(",");
        if (parts.length < 3) {
            return;
        }
        outValue.setId(Integer.parseInt(parts[0].trim()));
        outValue.setHostname(parts[1].trim());
        outValue.setIp(parts[2].trim());
        outKey.set(outValue.getHostname());
        context.write(outKey, outValue);
    }
}
```

### 4.4 Reducer（本实验的核心）

```java
package com.studybigdata.hadoop.mapred.cserializable;

import com.studybigdata.hadoop.java.entity.ComputerWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

import java.io.IOException;
import java.util.TreeSet;

/**
 * 按主机名统计上报次数，并收集出现过的所有 IP。
 * IP 集合超过 1 个说明该主机换过 IP，标记为异常。
 */
public class ComputerReducer extends Reducer<Text, ComputerWritable, Text, Text> {

    @Override
    protected void reduce(Text key, Iterable<ComputerWritable> values, Context context)
            throws IOException, InterruptedException {
        int count = 0;
        TreeSet<String> ips = new TreeSet<>();

        for (ComputerWritable c : values) {
            count++;
            // 关键：必须当场把 ip 取出来。values 里自始至终是同一个实例，
            // 框架每次循环前用 readFields 重新填值；把 c 本身存起来最后全是最后一条的数据。
            ips.add(c.getIp());
        }

        String remark = ips.size() == 1 ? "正常" : "异常：检测到 " + ips.size() + " 个 IP";
        context.write(key, new Text(count + " 次, IP=" + ips + ", " + remark));
    }
}
```

### 4.5 Driver

对照 4-3-5 篇的 `StudentAvgJob`，唯一必须写对的是这一行——框架靠它选择序列化器、靠它反射 new 空对象：

```java
job.setMapOutputValueClass(ComputerWritable.class);
```

```java
package com.studybigdata.hadoop.mapred.cserializable;

import com.studybigdata.hadoop.java.entity.ComputerWritable;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class ComputerJob {

    public static void main(String[] args) throws Exception {
        String input = args.length > 0 ? args[0] : "data/writable/computers.txt";
        String output = args.length > 1 ? args[1] : "data/writable/output-computer";

        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf, "computer-heartbeat");
        job.setJarByClass(ComputerJob.class);

        job.setMapperClass(ComputerMapper.class);
        job.setReducerClass(ComputerReducer.class);

        // Map 输出类型：value 是我们自定义的 Writable
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(ComputerWritable.class);

        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(Text.class);

        FileInputFormat.addInputPath(job, new Path(input));
        FileOutputFormat.setOutputPath(job, new Path(output));

        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
```

### 4.6 预期结果

`data/writable/output-computer/part-r-00000`（按主机名字典序）：

```
node1    4 次, IP=[192.168.1.101], 正常
node2    3 次, IP=[192.168.1.102], 正常
node3    3 次, IP=[10.0.0.103, 192.168.1.103], 异常：检测到 2 个 IP
node4    2 次, IP=[192.168.1.104], 正常
```

自检：4+3+3+2 = 12 行，与输入行数一致；node3 的两个 IP 正是第 6、9 行埋的"换 IP"。

## 五、思考题

1. 把 `ComputerReducer` 里的 `ips.add(c.getIp())` 改成把 `c` 存进 `ArrayList`、循环结束后再取 IP，会发生什么？为什么？（提示：4-3-5 篇 5.9 节）
2. 若给 `ComputerWritable` 加一个 `mem`（内存大小，double）字段，旧的 `computer.bin` 还能读回来吗？会报什么错？
3. 本实验为什么把 `hostname` 作为 map 输出的 key？如果想统计「每个 IP 的上报次数」，代码要改哪几行？
4. 如果只是统计每台机器的上报次数（不需要 IP），value 用 `IntWritable(1)` 就够了。对比两种写法，说说什么时候才值得自定义 Writable。
