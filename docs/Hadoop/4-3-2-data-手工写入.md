# 第 2 篇 第一次尝试：手工把字段写进文件

> 上一篇的结尾留下一个问题：`Student` 对象活不过程序，怎么把它存下来？
>
> 这一篇用最直接的办法试试：把三个字段一个一个拆出来，写进文件。

## 2.1 先想清楚要做什么

一个 `Student` 里有三样东西：

```properties
id     = 1
name   = "张三"
height = 180.0
```

文件里只能放字节。所以要做的事是：

```text
写：Student 的三个字段  →  一串字节  →  存进 stu_data.bin
读：stu_data.bin 里的字节  →  三个值   →  填回一个 Student
```

我们把"写"的部分放在 `DataOut` 类里，"读"的部分放在 `DataIn` 类里。

## 2.2 第一步：准备一个学生

先创建一个 `Student`，把字段填好。这一步和上一篇的 `main` 一模一样：

```java
Student student = new Student();
student.setId(1);
student.setName("张三");
student.setHeight(180.0);
```

现在 `student` 在内存里，随时能把三个值取出来。

## 2.3 第二步：打开一个文件

要往文件里写，需要先打开一个输出流：

```java
FileOutputStream fileOutputStream = new FileOutputStream("stu_data.bin");
```

`FileOutputStream` 是"文件输出流"。`new` 的时候传一个文件名进去，它就去把那个文件打开（不存在就创建，存在就清空）。之后往它里面写什么，都会落到这个文件里。

### 问答 2-1：文件已存在会怎样

#### 问题

如果文件已经存在，里面有上次的内容，`new FileOutputStream("stu_data.bin")` 会怎么做？如果你想在末尾追加，而不是清空，该怎么办？

#### 答案

**会清空。** 默认是"覆盖模式"：文件被截断成 0 字节，然后从头写。

要追加，用另一个构造方法：

```java
FileOutputStream fos = new FileOutputStream("stu_data.bin", true);
//                                                               ↑ append
```

第二个参数 `true` 表示"追加到末尾，不清空"。

多追加几条之后，文件里就有多份数据首尾相接，得循环读才能全部读出来。

文件名用的是相对路径 `stu_data.bin`，不带目录。所以文件会生成在**程序运行时的工作目录**下——在 IDE 里跑，就是项目根目录。

## 2.4 第三步：换成能写数据类型的流

`FileOutputStream` 只能写字节：`write(byte)`、`write(byte[])`。但我们手上是 `int`、`String`、`double`，不能直接写。

所以外面再包一层 `DataOutputStream`：

```java
DataOutputStream dos = new DataOutputStream(fileOutputStream);
```

`DataOutputStream` 提供的是一组按类型写的方法：

| 方法 | 写什么 |
|---|---|
| `writeInt(int)` | 一个整数 |
| `writeUTF(String)` | 一个字符串 |
| `writeDouble(double)` | 一个带小数的数 |

它的作用就是：**把你给的类型，翻译成字节，交给里面的 `FileOutputStream` 落到磁盘上。**

调用关系是这样的：

```
dos.writeInt(1)
     ↓ 翻译成 4 个字节
fileOutputStream.write(...)
     ↓
stu_data.bin
```

### 问答 2-2：关外层流，内层会被关吗

#### 问题

既然 `dos` 里面包着 `fileOutputStream`，那最后 `dos.close()` 的时候，里面的 `fileOutputStream` 会被一起关掉吗？还是要把两个都关？

#### 答案

**会被一起关掉。** 只关 `dos` 就够了。

因为 `DataOutputStream.close()` 内部会继续调用它包着的那一层的 `close()`，一层一层传下去，最后真正关掉文件。这种"关最外层即可"的行为，是 Java 流的通用约定。

## 2.5 第四步：一个字段一个字段写

现在把三个字段依次写进去：

```java
dos.writeInt(student.getId());
dos.writeUTF(student.getName());
dos.writeDouble(student.getHeight());
```

三行，对应三个字段。注意每一行都是**先从对象里取出来，再交给流**：`student.getId()` 拿 `int`，`dos.writeInt` 负责写。

按这个顺序写，文件里就是：

```text
① id      →  32bit  → 4 个字节                      
② name    →   3B    → 变长（"张三"是 6 个字节，前面还有 2 个字节记长度，共 8 个）
③ height  →  64bit  → 8 个字节

合计：4 + 8 + 8 = 20 字节
```

`writeUTF` 会额外在前面写 2 个字节记录长度，这样读的时候才知道这个字符串到哪儿结束。这一点很重要，下面会用到。

### 问答 2-3：为什么 String 要记长度

#### 问题

`int` 和 `double` 都是定长的（4 字节、8 字节），读的时候按固定个数读就行。为什么 `String` 就必须额外记一个长度？

#### 答案

因为**字符串是变长的**。"张三"是 2 个字，"欧阳修文"是 4 个字，文件里都没有标记，光看字节分不出边界。

## 2.6 DataOut 完整代码

```java
package com.studybigdata.hadoop.java.data;

import com.studybigdata.hadoop.java.entity.Student;

import java.io.DataOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;

public class DataOut {
    public static void main(String[] args) throws IOException {
        Student student = new Student();
        student.setId(1);
        student.setName("张三");
        student.setHeight(180.0);

        FileOutputStream fileOutputStream = new FileOutputStream("stu_data.bin");
        DataOutputStream dos = new DataOutputStream(fileOutputStream);
        dos.writeInt(student.getId());
        dos.writeUTF(student.getName());
        dos.writeDouble(student.getHeight());
    }
}
```

跑一下，控制台没有任何输出——这是正常的，它只负责写文件，不打印东西。

去看项目根目录，多了一个文件：

```
stu_data.bin      20 字节
```

**对象变成字节了。** 这是本讲第一个成果。

## 2.7 第五步：把字节读回来

写进去不算完，要能读出来才有意义。读的过程，基本就是把写的过程反过来。

先准备一个空的 `Student`，等着往里填：

```java
Student student = new Student();
```

再打开输入流，包一层 `DataInputStream`：

```java
FileInputStream fileInputStream = new FileInputStream("stu_data.bin");
DataInputStream dis = new DataInputStream(fileInputStream);
```

`DataInputStream` 的方法和 `DataOutputStream` 一一对应：

| 输出 | 输入 |
|---|---|
| `writeInt(int)` | `readInt()` → 返回 `int` |
| `writeUTF(String)` | `readUTF()` → 返回 `String` |
| `writeDouble(double)` | `readDouble()` → 返回 `double` |

然后按顺序读出来，填进对象：

```java
int id = dis.readInt();
String name = dis.readUTF();
double height = dis.readDouble();

student.setId(id);
student.setName(name);
student.setHeight(height);
System.out.println(student);
```

## 2.8 DataIn 完整代码

```java
package com.studybigdata.hadoop.java.data;

import com.studybigdata.hadoop.java.entity.Student;

import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.IOException;

public class DataIn {
    public static void main(String[] args) throws IOException {
        Student student = new Student();
        FileInputStream fileInputStream = new FileInputStream("stu_data.bin");
        DataInputStream dis = new DataInputStream(fileInputStream);
        int id = dis.readInt();
        String name = dis.readUTF();
        double height = dis.readDouble();

        student.setId(id);
        student.setName(name);
        student.setHeight(height);
        System.out.println(student);
    }
}
```

运行结果：

```
Student{id=1, name='张三', height=180.0}
```

和当初写进去的一模一样。**这一来一回，就是序列化和反序列化。**

## 2.9 写和读的顺序必须对上

这是本篇最需要注意的一点。

`DataOut` 里的顺序是：

```
1. writeInt
2. writeUTF
3. writeDouble
```

那么 `DataIn` 里**必须**是同样的顺序：

```
1. readInt
2. readUTF
3. readDouble
```

为什么不能换？因为 `readInt()` 是"从当前读到的位置，往后取 4 个字节"。它不知道也不关心这 4 个字节原本是什么意思，只按位置读。

文件里的字节是这样排的，每一步都依赖上一步停在哪里。

```
位置    0    1    2    3    4  5    6  7  8  9  10 11  12  13............. 19
        └────  id ────┘   └名字长┘  └──     张 三      ──┘  └──── height ────┘
```

- 先 `readInt()`：读 0~3 这 4 个字节 → 得到 `1`，指针移到位置 4
- 再 `readUTF()`：先读位置 4、5 得到长度 6，再读后面 6 个字节 → 得到 `"张三"`，指针移到位置 12
- 最后 `readDouble()`：读 12~19 这 8 个字节 → 得到 `180.0`

### 问答 2-4：把读取顺序改一下会怎样

#### 问题

假如你有意把 `DataIn` 里的 `readUTF()` 和 `readDouble()` 调换一下，会发生什么？是抛出异常，还是安静地读出几个乱七八糟的值？

#### 答案

**两种情况都可能，取决于运气。** 这一点最要命。

改完之后大概是这样：

```java
int id = dis.readInt();
double height = dis.readDouble();   // 它读的是原本名字那 8 个字节
String name = dis.readUTF();        // 它读的是原本 height 那 8 个字节
```

具体会怎样：

- `readInt()` 正常读出 `id = 1`，指针到第 4 字节。
- `readDouble()` 把名字那 8 个字节（长度 2 字节 + "张三" 6 字节）当成了 `double`。这 8 个字节不管内容是什么，都能解释成某个 `double`，**不会报错**，只是那个数完全没有意义。
- `readUTF()` 接下来把 `height` 的 8 个字节当作"长度 + 内容"来读。它先读前 2 个字节当长度——`180.0` 的字节是 `40 66`，即 **16486**。它于是认为后面还有 16486 个字节，但文件早就读完了，**这时会抛 `EOFException`**。

## 2.10 这个方案的毛病

方案是可行的。对象存进去了，也读回来了，数据一点没丢。但它有两个明显的问题。

##### **问题一：每加一个字段，两个类都要改。**

现在 `Student` 有三个字段，`DataOut` 要写三行，`DataIn` 要读三行。

哪天 `Student` 加了一个 `email` 字段：

- `DataOut` 得加一行 `dos.writeUTF(student.getEmail())`
- `DataIn` 得加一行 `String email = dis.readUTF()`

**漏改任何一处，或者两处顺序不一致，数据就错了。** 而且错得悄无声息。

##### **问题二：顺序这件事全靠人记。**

文件本身不记录"第一个字段是 int，第二个是 String"。

### 问答 2-5：文件不知道数据是什么

#### 问题

这句话点出了核心问题——**文件里只存了数据，没存"数据是什么"**。要解决它，思路有两条：让文件自己说明结构，或者让读写双方都遵守一套统一规矩。你觉得下一篇会走哪一条？代价分别是什么？

#### 答案

**下一篇两条都用了，但主角是第一条。**

| 思路 | 具体做法 | 代价 |
|---|---|---|
| 让文件自己说明结构 | 把类名、字段名、字段类型也写进文件 | 文件变大——这正是第 3 篇的 `Serializable`，20 字节变 127 字节 |
| 双方遵守统一规矩 | 不写结构，但双方都实现同一个接口，按接口约定的方法读写 | 写不了"通用"的解析器，只有认识这个接口的框架才能读——这是第 4 篇的 `Writable` |

## 2.11 下一篇：能不能全自动

既然"把每个字段拆出来写"这件事既繁琐又容易错，自然会想：

> 能不能只写一句"把这个对象存起来"，剩下的让 Java 自己搞定？

答案是能。只要给 `Student` 加一个接口 —— `java.io.Serializable`。

下一篇就做这件事。请注意，**到目前为止 `Student` 还没有实现任何接口**，它就是一个普通的 POJO。
所以下一篇的第一件事，是回去改 `Student`。

---

上一篇：[第 1 篇 从一个 Student 类开始](01-Student.md) ｜ 下一篇：[第 3 篇 第二次尝试：加上 Serializable](03-object-自动序列化.md)
