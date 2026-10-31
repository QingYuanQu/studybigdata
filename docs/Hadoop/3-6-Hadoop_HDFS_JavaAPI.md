---
theme: python-mini-pptx
paginate: true
headingDivider: 5
title: HDFS Java API 常用操作
date: 2026-09-21 15:00:00
categories:
- Hadoop
tags:
- Hadoop
- HDFS
- Java API
---

# HDFS Java API 常用操作

### 前置条件

- Windows 本地开发环境（Maven / IDEA / winutils / HADOOP_HOME）配置成功；
- 默认已能连上 `hdfs://node0:9000`、操作用户为 `zhangsan`，且项目已引入 `hadoop-client` 依赖。

## 一、开发环境与依赖

任何 Java 程序读写 HDFS 前，都要先拿到 `FileSystem` 这个统一入口；而拿到它之前，得把依赖与运行配置就位。

### 01 Maven 依赖

`hadoop-client` 把 HDFS / YARN / MapReduce 所需的所有客户端类打包进来，普通业务程序引入它即可。

```xml
<dependency>
    <groupId>org.apache.hadoop</groupId>
    <artifactId>hadoop-client</artifactId>
    <version>3.1.3</version>
</dependency>
```

### 02 连接三要素

无论用哪种方式获取 `FileSystem`，本质都是在组装三样东西：

| 要素 | 含义 | 来源 |
| --- | --- | --- |
| URI | NameNode 地址，如 `hdfs://node0:9000` | 代码中 `URI`，或配置文件 `fs.defaultFS` |
| Configuration | 客户端配置，决定连哪个集群、副本数等 | `new Configuration()` 自动读 classpath 下 `core-site.xml`，或代码 `set` |
| 用户 | 决定以谁的权限操作 HDFS | `FileSystem.get(uri, conf, user)` 的第三个参数 |

URI 末尾的 `/` 只影响"根路径"基准，写不写都不影响连接；`node0` 换成你集群实际的主机名或 IP 即可。

## 二、获取 FileSystem

`FileSystem` 本质是一个与 NameNode 通信的客户端

### FileSystem.get(URI, conf, user)

把地址、配置、用户一次性交给 `get`。下面这段也是验证"能不能连上"的最小 demo。

```java
public class ConnectDemo {
    public static void main(String[] args) throws Exception {
        URI uri = URI.create("hdfs://node0:9000");
        Configuration conf = new Configuration();
        // 第三参数指定以 zhangsan 的身份操作，决定权限与家目录
        FileSystem fs = FileSystem.get(uri, conf, "zhangsan");
        
        System.out.println("FileSystem 连接成功: " + fs.getUri());
        Path dst = new Path("/user/zhangsan/hadoop/hdfs/bigdata.txt");
        System.out.println("exists? " + fs.exists(dst));
        fs.close();
    }
}
```

真实输出（集群正常时）：

```java
FileSystem 连接成功: hdfs://node0:9000
exists? true
```

若输出 `java.io.IOException: ... node0:9000 failed on connection` 之类，先查 NameNode 是否起来、地址/端口是否写错、以及 Windows 下 `HADOOP_HOME` 是否配置。

## 三、目录与文件基本操作（CRUD）

增删改查是最高频的操作，API 大多集中在 `FileSystem` 上，语义与 Shell 命令一一对应：会 `hdfs dfs -put` 就大致知道 `copyFromLocalFile` 在做什么。

### 01 创建目录 mkdirs

对应 Shell 的 `hdfs dfs -mkdir -p`。父目录不存在时也会一并创建。

```java
Path dir = new Path("/user/zhangsan/hadoop/hdfs/logs/name");
boolean ok = fs.mkdirs(dir);
System.out.println("mkdirs -> " + ok);

// 也可带权限位（类比 -mkdir -p 后再 chmod）
fs.mkdirs(dir, new FsPermission(FsAction.ALL, FsAction.NONE, FsAction.NONE));
```

返回 `true` 表示创建成功或目录已存在；`false` 通常是权限不足。

### 02 上传文件 copyFromLocalFile

对应 `hdfs dfs -put` / `-copyFromLocal`

##### 复制

```java
Path src = new Path("D:/studybigdata/software/2.hadoop/hadoop-3.1.3.tar.gz");          // 本地文件
Path dst = new Path("/user/zhangsan/hadoop/hdfs/hadoop-3.1.3.tar.gz");

// 基础版：本地 -> HDFS，dst 写成具体文件名
fs.copyFromLocalFile(src, dst);
```

##### 复制并删除

```java
Path src = new Path("D:/studybigdata/code/data/hadoop/bigdata.txt");          // 本地文件
Path dst = new Path("/user/zhangsan/hadoop/hdfs/bigdata.txt");

// 复制并删除版：带 delSrc（传 true 上传后删除本地源）
fs.copyFromLocalFile(true, src, dst);
```



### 03 下载文件 copyToLocalFile

对应 `hdfs dfs -get`。**Hadoop 3.x 推荐用四参版本**，二参 `copyToLocalFile(src, dst)` 在新版已被更严格的校验取代，容易因 `.crc` 处理或路径问题报错。

```java
Path src = new Path("/user/zhangsan/hadoop/hdfs/bigdata.txt");
Path dst = new Path("D:/studybigdata/code/data/hadoop/bigdata.txt"); // 必须是"文件名"，不是目录

// 四参：delSrc / 源 / 目的 / useRawLocalFileSystem
fs.copyToLocalFile(false, src, dst, true);
```

注意点：

- `dst` 要写到**具体文件名**；若写成已存在的目录会失败。
- `useRawLocalFileSystem=true` 可避免下载时在本地落 `.crc` 文件。
- 本地父目录需先存在，否则抛 `FileNotFoundException`。

### 04 删除 delete / deleteOnExit

对应 `hdfs dfs -rm` / `-rm -r`。删除非空目录必须把第二个参数 `recursive` 设为 `true`。

```java
Path p = new Path("/user/zhangsan/hadoop/hdfs/logs");

// 删文件或空目录
fs.delete(p, false);

// 递归删整个目录树
fs.delete(p, true);
```

> 集群若开启回收站（默认 `fs.trash.interval>0`），`delete` 实际是把文件移进 `.Trash`，可用 `hdfs dfs -mv` 从回收站找回；想彻底删除需 `-skipTrash` 对应到 API 的 `Trash` 类处理（进阶，本文不展开）。

### 05 重命名 rename（兼移动）

`rename` 不只是改名，跨目录调用它就是"移动"，对应 `hdfs dfs -mv`。

```java
Path src = new Path("/user/zhangsan/hadoop/hdfs/bigdata.txt");
Path dst = new Path("/user/zhangsan/hadoop/hdfs/bigdata_v2.txt");
boolean ok = fs.rename(src, dst); // 同源目录内 = 改名
System.out.println("rename -> " + ok);

// 跨目录即移动
fs.rename(src, new Path("/tmp/bigdata.txt"));
```

### 06 判断与状态 exists / isDirectory / isFile

在真正读写前先判断路径类型，能避免一大批 `FileNotFoundException` / `PathIsDirectoryException`。

```java
Path p = new Path("/user/zhangsan/hadoop/hdfs");
System.out.println("exists   -> " + fs.exists(p));
System.out.println("isDir    -> " + fs.isDirectory(p));
System.out.println("isFile   -> " + fs.isFile(p));

FileStatus st = fs.getFileStatus(p);
System.out.println("length   -> " + st.getLen());
System.out.println("owner    -> " + st.getOwner());
System.out.println("modTime  -> " + st.getModificationTime());
```

## 四、列举与文件状态

遍历目录、查看元数据、定位块位置，是写"按文件处理"程序和就近读取的基础。Shell 的 `-ls` 背后就是这一节的方法。

### 01 listStatus 列举一层

`listStatus` 只列举**当前目录**的直接子项，不递归，对应 `hdfs dfs -ls`。

```java
Path dir = new Path("/user/zhangsan");
FileStatus[] statuses = fs.listStatus(dir);
for (FileStatus s : statuses) {
    String type = s.isDirectory() ? "DIR " : "FILE";
    System.out.printf("%s %s %12d  %s%n",
            type, s.getPermission(), s.getLen(), s.getPath());
}
```

### 02 listFiles 递归列举（带块位置）

需要"遍历整棵目录树"时用 `listFiles`，第二个参数 `true` 表示递归；它返回的 `LocatedFileStatus` 直接带块位置信息，省去再调一次 `getFileBlockLocations`。

```java
RemoteIterator<LocatedFileStatus> it = fs.listFiles(dir, true);
while (it.hasNext()) {
    LocatedFileStatus f = it.next();
    System.out.println(f.getPath() + "  blocks=" + f.getBlockLocations().length);
}
```

### 03 getFileStatus 与 getFileChecksum

`getFileStatus` 拿单个文件的完整元数据；

```java
Path p = new Path("/user/zhangsan/hadoop/hdfs/hadoop-3.1.3.tar.gz");
FileStatus st = fs.getFileStatus(p);
System.out.println("replication=" + st.getReplication());
System.out.println("blockSize  =" + st.getBlockSize());
```

`getFileChecksum` 取校验和，可用来比对"上传前后内容是否一致"。

```java
FileChecksum cs = fs.getFileChecksum(p);
System.out.println("checksum   =" + cs);
```

### 04 getFileBlockLocations 块位置

返回文件每个块的物理位置（落在哪些 DataNode 上）。这是"就近读取"和"计算切分（split）"的底层依据：MapReduce 正是先查块位置，再把任务调度到离数据最近的节点。

```java
FileStatus st = fs.getFileStatus(p);
BlockLocation[] blocks = fs.getFileBlockLocations(p, 0, st.getLen());
for (BlockLocation b : blocks) {
    System.out.printf("offset=%d len=%d hosts=%s%n",
                      b.getOffset(), b.getLength(), Arrays.toString(b.getHosts()));
}
```

返回字段含义：

| 字段 | 含义 |
| --- | --- |
| `getOffset()` | 该块在文件中的起始字节偏移 |
| `getLength()` | 该块大小（最后一块通常不足 `blockSize`） |
| `getHosts()` | 存放该块副本的 DataNode 主机名 |



## 五、IO 流方式读写

- `copyFromLocalFile` / `copyToLocalFile` 是封装好的便捷方法；

- 要精细控制（断点续传、定位读、追加写）就得直接用流。

- `FSDataInputStream` / `FSDataOutputStream` 是带定位能力的增强流。

### 01 流方式上传 create + IOUtils.copyBytes

`fs.create(path)` 拿到输出流，把本地输入流拷过去即可，等价于手写版 `copyFromLocalFile`。

```java
try (InputStream in = new FileInputStream("D:/studybigdata/software/2.hadoop/hadoop-3.1.3.tar.gz");
     FSDataOutputStream out = fs.create(new Path("/user/zhangsan/hadoop/hdfs/hadoop-3.1.3.tar.gz"))) {
    IOUtils.copyBytes(in, out, 4096, false); // 最后一个 false = 不关闭输入流
}
```

`IOUtils.copyBytes(in, out, bufferSize, closeStreams)`：第四个参数决定是否由它顺手关流；用 try-with-resources 管理时传 `false`。

### 02 流方式下载 open + IOUtils.copyBytes

`fs.open(path)` 拿到输入流，拷到本地文件输出流，等价于手写版 `copyToLocalFile`。

```java
FSDataInputStream in = fs.open(new Path("/user/zhangsan/hadoop/hdfs/hadoop-3.1.3.tar.gz"));
OutputStream out = new FileOutputStream("D:/studybigdata/software/2.hadoop/hadoop-3.1.3.tar.gz");
IOUtils.copyBytes(in, out, 4096, false);
```

### 03 定位读取 seek（分片下载思想）

`FSDataInputStream` 支持 `seek(offset)` 跳到任意字节位置再读，这是"大文件分片下载 / 断点续传"的核心：把文件按偏移切成 N 段，每段独立 `seek` 后读取。

```java
FSDataInputStream in = fs.open(new Path("/user/zhangsan/hadoop/hdfs/bigdata.txt"));
in.seek(2);                 // 跳到第 2 字节
byte[] buf = new byte[5];
int n = in.read(buf);        // 从 offset=2 起读 5 字节
System.out.println(new String(buf, StandardCharsets.UTF_8));
```

##### 循环读到文件末尾

```java
FSDataInputStream in = fs.open(new Path("/user/zhangsan/hadoop/hdfs/bigdata.txt"));
in.seek(2);                 // 跳到第 2 字节
byte[] buf = new byte[5];
for (int n; (n = in.read(buf)) != -1; ) {   // 循环读到文件末尾
    System.out.print(new String(buf, 0, n, StandardCharsets.UTF_8));
}
System.out.println();
```

## 六、综合实战：可运行 Demo

把前面操作串成一个完整程序：上传 → 校验 → 列目录 → 读内容 → 下载 → 删除，并打印真实输出。照着跑一遍，所有 API 就串起来了。

### 01 完整代码

下面是一个自包含的主类，按顺序演示六类操作；`LOCAL` 改成你机器上的真实路径即可运行。

```java
package com.studybigdata.hadoop.hdfs;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.*;
import java.io.*;
import java.net.URI;

public class HdfsApiDemo {
    public static void main(String[] args) throws Exception {
        String LOCAL = "D:/studybigdata/code/data/hadoop/bigdata.txt"; // 本地待上传文件，请先自行创建
        URI uri = URI.create("hdfs://node0:9000");
        Configuration conf = new Configuration();

        try (FileSystem fs = FileSystem.get(uri, conf, "zhangsan")) {
            
            Path dir  = new Path("/user/zhangsan/hadoop/hdfs");
            Path file = new Path(dir, "bigdata.txt");

            // 1) 建目录
            fs.mkdirs(dir);
            // 2) 上传（已存在则先删）
            if (fs.exists(file)) fs.delete(file, false);
            fs.copyFromLocalFile(new Path(LOCAL), file);
            System.out.println("[upload] exists=" + fs.exists(file));

            // 3) 列目录
            System.out.println("[list]");
            for (FileStatus s : fs.listStatus(dir)) {
                System.out.println("  " + (s.isDirectory() ? "DIR " : "FILE")
                        + " " + s.getLen() + " " + s.getPath().getName());
            }

            // 4) 流方式读取前 64 字节
            try (FSDataInputStream in = fs.open(file)) {
                byte[] buf = new byte[64];
                int n = in.read(buf);
                System.out.println("[read] " + n + " bytes: " + new String(buf, 0, n).trim());
            }

            // 5) 下载到本地
            fs.copyToLocalFile(false, file, new Path("D:/download/bigdata.txt"), true);
            System.out.println("[download] done");

            // 6) 清理
            fs.delete(dir, true);
            System.out.println("[cleanup] exists=" + fs.exists(dir));
        }
    }
}
```

<div class="end"><h1>HDFS Java API 小结</h1>
<ul>
<li>入口统一是 <code>FileSystem</code>：连接 = URI + Configuration + 用户</li>
<li>便捷方法（copyFromLocalFile / copyToLocalFile / mkdirs / delete / rename）语义与 Shell 一一对应</li>
<li>列举与状态靠 listStatus / listFiles / getFileStatus / getFileBlockLocations</li>
<li>精细控制（定位读、分片、追加）走 FSDataInputStream / FSDataOutputStream</li>
<li>资源用完即关，地址与权限是两大高频坑</li>
</ul>
<p>API 是 Shell 的程序化映射：先理解命令，再看方法名就一目了然。</p></div>
