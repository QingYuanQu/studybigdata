# 第 4 篇 第三次尝试：Hadoop 的 Writable

> 上一篇用 `Serializable` 做到了全自动，但文件从 20 字节涨到 127 字节，而且那 107 字节全是 Java 专有的东西。
> Hadoop 的解法很有意思：**回到第 2 篇的手工写法，但把它变成一套标准。**

## 4.1 先看看 Hadoop 定的是什么规矩

Hadoop 要求：所有要在集群里传输的 key 和 value，都必须实现 `org.apache.hadoop.io.Writable` 接口。

这个接口和上一篇的 `Serializable` 正好相反——它不是空接口，里面有两个方法：

```java
public interface Writable {
    void write(DataOutput out) throws IOException;
    void readFields(DataInput in) throws IOException;
}
```

一个是"把自己写出去"，一个是"把别人写进来的填给自己"。

注意参数类型：`DataOutput` 和 `DataInput`。
这正是第 2 篇用过的 `DataOutputStream` / `DataInputStream` 的上层接口。
也就是说，**Hadoop 让你回到第 2 篇那套 `writeInt` / `writeUTF` / `writeDouble` 的写法**，只是把"写哪些字段、按什么顺序"这件事，装进类的一个方法里。

### 问答 4-1：少写一行 write，编译器会拦吗

#### 问题

上一篇的 `Serializable` 是个空接口，什么方法都没有；这一篇的 `Writable` 有两个方法。如果你的类实现了 `Writable`，但故意把 `write` 方法少写一行 `out.writeInt(id)`，Java 编译器会不会拦你？如果不会，那出错会发生在什么时候？

#### 答案

**编译器不会拦，因为语法完全合法。** `write` 方法存在、签名正确、有实现——编译器只检查这些。

出错的时机是**运行时读数据的时候**：

```
写：              out.writeUTF(name); out.writeDouble(height);      ← 少写了 id
读：in.readInt(); in.readUTF();       in.readDouble();              ← 照旧读三个
```

读的时候，`readInt()` 会把名字的长度前缀（2 字节）+ "张三"的前 2 个字节当成一个 `int`，然后后面的全部错位。

这和第 2 篇 2.9 节是同一个病：**位置错开，不报错，读到垃圾**。

注意一个对比：

| 接口 | 能强制什么 |
|---|---|
| `Serializable`（空接口） | **什么都强制不了**，挂了牌子就行 |
| `Writable`（两个方法） | 强制你**实现**这两个方法，但管不了方法**里面写什么** |

所以 `Writable` 比 `Serializable` 强，但强得有限——它能保证"有办法调"，不能保证"调对了"。

## 4.2 第一步：新建一个类

我们不改动原来的 `Student` —— 它是给 `object` 那套用的。
Hadoop 这边另建一个类，放在同一个 `entity` 包里：

```java
public class StudentWritable implements Writable {
}
```

字段还是那三个，一模一样的：

```java
public class StudentWritable implements Writable {

    private int id;
    private String name;
    private double height;
}
```

## 4.3 第二步：为什么必须写一个空构造方法

`Student` 里没有无参构造，我们从来没管过（Java 会自动补一个）。
`StudentWritable` 里**必须自己写出来**：

```java
public StudentWritable() {
}
```

为什么？回想上一篇 3.8 节的一个细节：

> `readObject()` 读回来的时候，**没有调用 `Student` 的构造方法**。

`Serializable` 可以不调构造方法就把对象造出来，`Writable` 做不到。
Hadoop 的做法是分两步走：

```
第 1 步：用反射调用无参构造，先 new 出一个空对象
第 2 步：调这个空对象的 readFields(dis)，把字节里的值一个个填进去
```

所以这个无参构造是**入口**。没有它，Hadoop 第 1 步就失败，根本走不到第 2 步。

## 4.4 顺带配一个带参构造

无参构造是给 Hadoop 用的。但我们自己写代码时，希望能一句话就把三个字段填好，所以再配一个带参的（`StudentWritableOut` 里要用）：

```java
public StudentWritable(int id, String name, double height) {
    this.id = id;
    this.name = name;
    this.height = height;
}
```

这个构造是给我们写代码用的，Hadoop 反序列化时不走它。

## 4.5 第三步：加 getter 和 setter

和 `Student` 完全一样，三个字段六种方法：

```java
public int getId() { return id; }
public void setId(int id) { this.id = id; }

public String getName() { return name; }
public void setName(String name) { this.name = name; }

public double getHeight() { return height; }
public void setHeight(double height) { this.height = height; }
```

## 4.6 第四步：write —— 把字段写出去

这是 Writable 的核心。写法和第 2 篇的 `DataOut` 一模一样，只是搬进了类的方法里：

```java
@Override
public void write(DataOutput out) throws IOException {
    out.writeInt(id);
    out.writeUTF(name);
    out.writeDouble(height);
}
```

对比一下第 2 篇：

| | 第 2 篇（`DataOut` 里） | 第 4 篇（`StudentWritable` 里） |
|---|---|---|
| 写 id | `dos.writeInt(student.getId())` | `out.writeInt(id)` |
| 写 name | `dos.writeUTF(student.getName())` | `out.writeUTF(name)` |
| 写 height | `dos.writeDouble(student.getHeight())` | `out.writeDouble(height)` |

唯一的区别：第 2 篇是"从别人身上取字段再写"，这里是"写自己的字段"。所以不再需要 `getXxx()`，直接用字段名。

### 问答 4-3：加一个字段旧文件还能读吗

#### 问题

注意 `write` 一旦定下来，文件格式就定死了。如果以后给 `StudentWritable` 加一个 `email` 字段，文件会变成什么样？更麻烦的是：**已经存好的旧文件还能读吗？**

#### 答案

**新文件能读，旧文件会读错。**

加了字段之后，`write` 变成四行、`readFields` 变成四行，新写出的文件自然是四段。这部分没问题。

问题出在读**旧**文件时：

```
旧文件：  [id] [name] [height]                 （3 段）
新 readFields：readInt → readUTF → readDouble → readUTF(email)
                                                         ↑ 这一段开始已经读完了
```

前三段能正常读出来，第四段 `readUTF` 一读就发现文件到底了，**抛 `EOFException`**。

这比"读出错数据"要好一点——至少会报错。但也意味着：**旧数据彻底读不了了。**

对比第 3 篇的 `Serializable`：那里有 `serialVersionUID` 做版本校验，能明确告诉你"版本不匹配"；而 `Writable` **没有任何版本机制**，只能靠 `EOFException` 或读出错值来体现。

所以用 `Writable` 时要记住一条：**它的格式是"双方心照不宣的约定"，不是自描述的。改一处必须双方同步改，而且没有回头路。**

实际工程中，如果需要长期存盘且可能演进，通常会在数据里加一个版本号字段，或者干脆用 Avro 这类支持 schema 演进的格式。这就超出本项目范围了。

三行，顺序是 `id` → `name` → `height`。**记住这个顺序，下面要用。**

## 4.7 第五步：readFields —— 把字段读进来

反过来写一遍：

```java
@Override
public void readFields(DataInput in) throws IOException {
    this.id = in.readInt();
    this.name = in.readUTF();
    this.height = in.readDouble();
}
```

顺序必须和 `write` 完全一致：`id` → `name` → `height`。

这就是第 2 篇 2.9 节讲过的道理——`readInt()` 按位置往后读 4 个字节，不管那 4 个字节原本是什么。
如果这里写成了 `in.readUTF()` 打头，读出来的东西就全乱了。

而且第 2 篇说过：这种错误**不报错**。所以 `write` 和 `readFields` 这两个方法总是**挨着写、对着看**，代码里也把它们放在一起。

## 4.8 第六步：toString

为了打印结果，还是加一个：

```java
@Override
public String toString() {
    return "StudentWritable{" +
            "id=" + id +
            ", name='" + name + '\'' +
            ", height=" + height +
            '}';
}
```

## 4.9 StudentWritable 完整代码

```java
package com.studybigdata.hadoop.java.entity;

import org.apache.hadoop.io.Writable;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;

/**
 * 实现 Hadoop 的 Writable 接口：把对象"压扁"成字节、再从字节"还原"成对象。
 * 这是 MapReduce 在 shuffle 阶段序列化 key/value 的标准方式。
 */
public class StudentWritable implements Writable {

    private int id;
    private String name;
    private double height;

    // 1) 必须有无参构造：Hadoop 反序列化时先用反射 new 一个空对象，再调 readFields 填值
    public StudentWritable() {
    }

    public StudentWritable(int id, String name, double height) {
        this.id = id;
        this.name = name;
        this.height = height;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public double getHeight() {
        return height;
    }

    public void setHeight(double height) {
        this.height = height;
    }

    // 2) 序列化：按固定顺序把字段写进 DataOutput
    @Override
    public void write(DataOutput out) throws IOException {
        out.writeInt(id);
        out.writeUTF(name);
        out.writeDouble(height);
    }

    // 3) 反序列化：读取顺序必须和 write 完全一致，否则字段会错位
    @Override
    public void readFields(DataInput in) throws IOException {
        this.id = in.readInt();
        this.name = in.readUTF();
        this.height = in.readDouble();
    }

    @Override
    public String toString() {
        return "StudentWritable{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", height=" + height +
                '}';
    }
}
```

到这里，类本身完整了。但还差一步——**证明它真的能读写文件**。

## 4.10 第七步：写出去

`writable` 包里新建 `StudentWritableOut`。开头和前面一样，开文件流：

```java
FileOutputStream fos = new FileOutputStream("stu_writable.bin");
DataOutputStream dos = new DataOutputStream(fos);
```

注意这里包的是 **`DataOutputStream`**，不是 `ObjectOutputStream`。
因为 `Writable` 的 `write` 方法要的就是 `DataOutput`，`DataOutputStream` 正好是它的实现。

然后创建一个对象，调用它自己的 `write` 方法：

```java
StudentWritable stu = new StudentWritable(1, "张三", 180.0);
stu.write(dos);   // 调我们自己实现的 write 方法
```

对比第 2 篇：那里是三行 `dos.writeXxx(...)`，这里是**一行 `stu.write(dos)`**。
那三行并没有消失，只是被收进了 `write` 方法里。

完整代码：

```java
package com.studybigdata.hadoop.java.writable;

import com.studybigdata.hadoop.java.entity.StudentWritable;

import java.io.DataOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;

public class StudentWritableOut {
    public static void main(String[] args) throws IOException {
        StudentWritable stu = new StudentWritable(1, "张三", 180.0);

        // Writable 底层还是用 java.io 的流，只是多了一层 write/readFields 协议
        FileOutputStream fos = new FileOutputStream("stu_writable.bin");
        DataOutputStream dos = new DataOutputStream(fos);
        stu.write(dos);   // 调我们自己实现的 write 方法
        dos.close();
    }
}
```

## 4.11 第八步：读回来

读的关键在 4.3 节讲过的那两步。先自己 new 一个空对象：

```java
StudentWritable stu = new StudentWritable();
```

然后让流把数据填进这个空对象：

```java
FileInputStream fis = new FileInputStream("stu_writable.bin");
DataInputStream dis = new DataInputStream(fis);
stu.readFields(dis);   // 调我们自己实现的 readFields 方法
```

**注意 `readFields` 没有返回值。** 它直接把读到的值塞进 `stu` 自己身上。
所以必须事先有对象——这就是无参构造的用处。

### 问答 4-4：readFields 为什么不返回对象

#### 问题

对比第 3 篇的 `readObject()`，它会 `return` 一个对象给你。为什么两个接口的设计差这么多？`readFields` 不返回对象，换来了什么好处？

#### 答案

**换来了"对象复用"，也就是省内存。**

| | `Serializable` | `Writable` |
|---|---|---|
| 每次读 | `readObject()` 造一个**新对象**返回 | 把值填进**你给的那个对象** |
| 读 100 万条 | 造 100 万个对象，等 GC 回收 | 只造 1 个对象，反复改值 |

在 MapReduce 里，Reducer 可能要处理上百万条记录。如果每条都 `new` 一个新对象，垃圾回收会把 CPU 吃掉一大块。

`readFields` 的设计就是为这个场景准备的：**框架手里只有一个对象，每次读新记录就重新填一遍。**

一句话总结：

> **`Serializable` 用起来方便，`Writable` 用起来省资源。方便和省资源通常不可兼得。**

完整代码：

```java
package com.studybigdata.hadoop.java.writable;

import com.studybigdata.hadoop.java.entity.StudentWritable;

import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.IOException;

public class StudentWritableIn {
    public static void main(String[] args) throws IOException {
        // 反序列化：必须先有一个空对象，再让流把数据填进去
        StudentWritable stu = new StudentWritable();

        FileInputStream fis = new FileInputStream("stu_writable.bin");
        DataInputStream dis = new DataInputStream(fis);
        stu.readFields(dis);   // 调我们自己实现的 readFields 方法
        dis.close();

        System.out.println(stu);
    }
}
```

运行结果：

```
StudentWritable{id=1, name='张三', height=180.0}
```

## 4.12 三种方式放在一起比

现在三套都跑通了。同一个学生，三种结果：

| 方式 | 代码 | 文件 | 大小 |
|---|---|---|---|
| Java 原生序列化（第 3 篇） | `oos.writeObject(stu)` | `stu_object.bin` | **127 字节** |
| `DataOutputStream` 手工（第 2 篇） | `dos.writeInt` + `writeUTF` + `writeDouble` | `stu_data.bin` | **20 字节** |
| Hadoop Writable（本篇） | `stu.write(dos)` | `stu_writable.bin` | **20 字节** |

### 问答 4-5：为什么两个文件一样大

#### 问题

先别看下面，猜一猜：为什么 `stu_data.bin` 和 `stu_writable.bin` 都是 20 字节？

#### 答案

因为 `stu.write(dos)` 展开之后，里面就是 `out.writeInt(id)`、`out.writeUTF(name)`、`out.writeDouble(height)` 三行——**和第 2 篇的 `DataOut` 逐字相同**。

写进文件的字节完全一样，所以大小也一样。

换句话：Writable 没有引入任何新的格式，它只是把第 2 篇那三行代码**搬进了类里**。

**后两个一模一样大。**

所以 Writable 并不神秘。它没有发明新的序列化格式——它就是第 2 篇那套手工写法，被装进了一个接口里。

## 4.13 那 Writable 到底比第 2 篇多了什么

文件一样大，写法看起来还更绕（要专门建个类）。多出来的东西是**规矩**。

第 2 篇的问题在于：`DataOut` 和 `DataIn` 只是两个普通的 `main` 方法，谁也不知道它们之间存在约定。
Hadoop 不能靠"猜"来工作——它要处理几百万条记录、跑在几百台机器上，必须有一个统一的方式说：

> "任何一个对象，只要实现了 `Writable`，我就能 `write` 它出去、`readFields` 它回来。"

有了这个接口，Hadoop 就能写一段通用代码：

```java
// 伪代码：Hadoop 内部大致就是这么干的
out.write(outValue);           // 不管 outValue 是什么，只要能 Writable
```

不用判断它是 `IntWritable` 还是 `StudentWritable`，也不用知道它有几个字段。

| | 第 2 篇 | 第 4 篇 |
|---|---|---|
| 怎么写 | `DataOut` 里三行 | `StudentWritable.write` 里的三行 |
| 谁来调用 | 只有 `DataOut` 自己 | 任何认 `Writable` 接口的框架代码 |
| 字段顺序 | 一个 `main` 里的约定 | 类自己的方法，跟着类走 |
| 文件大小 | 20 字节 | 20 字节 |

体积没变，但**从"一段代码"变成了"一个契约"**。

### 问答 4-6：Writable 的价值在哪

#### 问题

到现在为止，`StudentWritable` 和 `DataOut` 干的事完全一样，文件也一样大。单看这个本地文件，你**根本看不出 Writable 有什么价值**。那它到底在哪一刻变得不可替代？

#### 答案

**在"别人要调用你的代码"那一刻。**

`DataOut` 的问题是：那三行 `writeInt/writeUTF/writeDouble` 写在一个 `main` 方法里，**只有 `DataOut` 自己知道它们存在**。

如果有人（或某个框架）手上拿着一个 `Student` 对象，想把它写成字节，它做不到——它没法去调用 `DataOut.main()`，那是个程序入口，不是给人调的方法。

而 `StudentWritable` 把这三行放进了 `write(DataOutput out)` 方法里。这样一来，**任何拿到这个对象的人，都能调用它的 `write`**，不需要知道里面有几个字段、什么顺序。

所以差别是：

| | `DataOut` 里的三行 | `StudentWritable.write` 里的三行 |
|---|---|---|
| 位置 | 一个 `main` 方法的局部 | 类的一个公开方法 |
| 谁能用 | 只有它自己 | **任何人**（只要知道 `Writable` 这个接口） |

一句话：**代码从"一段流程"变成了"一个能力"。**

下一篇你会看到，这个"能力"确实被用上了——而且调用它的，是一段你永远看不到的 Hadoop 内部代码。

## 4.14 下一篇：这套契约用在哪

到此为止，三种方式都只是往一个本地文件里写、再读回来。看不出 `Writable` 的"规矩"到底有多大用处。

真正的用途在下一篇：MapReduce。

在 MapReduce 里，Mapper 处理完的数据要**跨机器**传给 Reducer。
数据必须先变成字节才能上网络，到了另一台机器再变回对象——这一步，就是靠 `Writable` 完成的。

下一篇看 `mapred/cserializable/` 里的三个类。

---

上一篇：[第 3 篇 第二次尝试：加上 Serializable](03-object-自动序列化.md) ｜ 下一篇：[第 5 篇 终点：MapReduce 里的序列化](05-mapreduce.md)
