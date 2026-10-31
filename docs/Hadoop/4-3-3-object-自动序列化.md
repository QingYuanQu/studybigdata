# 第 3 篇 第二次尝试：加上 Serializable

> 上一篇的结论是：手工写法能用，但改一个字段要改两个类，顺序还得自己盯着。
>
> 这一篇试试"全自动"：只写一句 `writeObject`，让 Java 自己把对象拆成字节。

## 3.1 第一步：回去改 Student

自动序列化有个前提：**这个类必须被声明为"可序列化"的**。
否则 `ObjectOutputStream` 不知道能不能动它，会直接拒绝。

所以要回到 `Student`，加一个接口：

```java
public class Student implements Serializable {
```

`Serializable` 来自 `java.io` 包，需要 import：

```java
import java.io.Serializable;
```

这个接口很特别——**它里面一个方法都没有**：

```java
public interface Serializable {
}
```

空的。它的作用只是打一个标记，相当于告诉 Java："这个类的对象允许被序列化"。
真正干活的不是它，是后面用到的 `ObjectOutputStream`。

### 问答 3-1：空接口能起什么作用

#### 问题

一个方法都没有的接口，能起什么作用？它既不能提供实现，也不能强制你做任何事。可是 `ObjectOutputStream` 怎么就知道"这个类可以动"？

#### 答案

它靠的是**有没有实现**这个判断本身。

`ObjectOutputStream` 内部大致会这样检查：

```java
if (!(obj instanceof Serializable)) {
    throw new NotSerializableException(obj.getClass().getName());
}
```

如果没实现，直接抛异常。所以这个空接口的全部作用就是当一块**牌子**：挂上了就放行，没挂就拒绝。

这种设计叫"标记接口"（marker interface）。

> 这个接口是为了 `object` 这套写法才加的。上一篇用 `data` 那套时，`Student` 还没有它。

## 3.2 顺手加一个 serialVersionUID

接口旁边还要加一行：

```java
private static final long serialVersionUID = 1L;
```

完整的类头变成这样：

```java
public class Student implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private String name;
    private double height;
    // getter / setter / toString 不变
}
```

这一行是"版本号"。序列化时它会跟着对象一起写进文件；读回来的时候，Java 会拿文件里的版本号和当前类的版本号比对，不一致就报错。

现在只需要知道：**写上它，并且给它一个固定值（比如 `1L`）**。
不写的话 Java 会自己算一个，类的字段一改动，这个算出来的值就跟着变，老文件就读不出来了。

### 问答 3-2：为什么不写 UID 也行，却要求写

#### 问题

既然"不写也行，Java 会自己算"，那为什么还要求我们手动写一个固定的 `1L`？想象一下：你把 `stu_object.bin` 存到硬盘上，第二天给 `Student` 加了个 `email` 字段，再去读那个旧文件，会发生什么？

#### 答案

**会读不出来，抛 `InvalidClassException`。**

道理是这样：

```
昨天写文件时  Studnet 有 3 个字段 → Java 算出 UID = -4415720384508049624
                                   ↓ 这个数被写进了 stu_object.bin
今天加了 email，变成 4 个字段   → Java 算出 UID = 4568971181002362559（完全不同的数）
                                   ↓ 读旧文件时比对
                                    两个数不一致 → 抛异常
```

关键在于：**不写 UID 时，Java 是按类的结构去算的**。加字段、删字段、改方法签名，算出来的值都会变。

而写死 `1L` 之后，不管你怎么改类，UID 永远是 `1`。读旧文件时版本号对得上，Java 就会尽量兼容地读——多出来的字段给默认值，缺的字段忽略。

**一句话：写死 UID = 你亲手控制"这次改动算不算破坏性升级"，而不是让编译器替你做决定。**

所以规范要求：凡是 `implements Serializable` 的类，都要显式写上 `serialVersionUID`。

字段、getter、setter、`toString` 全部不动。改动只有两行：接口 + 版本号。

## 3.3 第二步：打开文件，包一层 ObjectOutputStream

写文件的开头还是一样的套路，先开一个 `FileOutputStream`：

```java
FileOutputStream os = new FileOutputStream("stu_object.bin");
```

然后包一层 `ObjectOutputStream`：

```java
ObjectOutputStream oos = new ObjectOutputStream(os);
```

它和上一篇的 `DataOutputStream` 是同一类东西——都是"包在文件流外面的一层"，负责把 Java 的东西翻译成字节。
区别在于：

| | 能写什么 |
|---|---|
| `DataOutputStream` | 只能写基本类型：`int`、`double`、`String`…… |
| `ObjectOutputStream` | 能写**整个对象** |

## 3.4 第三步：一句话写进去

上一篇要三行：

```java
dos.writeInt(student.getId());
dos.writeUTF(student.getName());
dos.writeDouble(student.getHeight());
```

这一篇只要一行：

```java
oos.writeObject(stu);
```

就这一行。

不用告诉它先写 `id` 还是先写 `name`，不用管每个字段占几个字节，也不用管字符串的长度。**它自己去读 `Student` 的所有字段，自己决定怎么排。**

### 问答 3-3：它怎么知道里面有三个字段

#### 问题

`writeObject` 拿到的参数是一个 `Object`，它怎么知道里面有三个字段？第 2 篇是你亲手把字段一个一个取出来写的，这里你一行都没写——它是通过什么手段拿到 `id`、`name`、`height` 的？既然它能自己读字段，那需不需要先问你要权限？

#### 答案

靠的是**反射（Reflection）**。

反射是 Java 提供的一套能力：**在运行时检查一个类的结构**——有哪些字段、叫什么名字、什么类型、能不能访问。`writeObject` 就是先用反射把 `Student` 的字段列表拿到手，再逐个读出值。

这也解释了 3.2 节那个现象：不写 `serialVersionUID` 时 Java 能自己算一个——因为它本来就在检查类的全部结构。

**关于"要不要问权限"：答案是"不用问，`private` 也拦不住它"。**

反射默认受访问控制限制，但 `ObjectOutputStream` 在 JDK 内部里会主动打开这个开关（通过 `setAccessible(true)` 之类的手段）。所以即使你把字段写成 `private`，序列化照样能读到——这也是为什么第 1 篇说"`private` 是为了留入口"，而不是为了"防外部读取"。

需要注意：**反射是有代价的**。它比直接调用方法慢，而且会做大量类型检查。这是 `Serializable` 序列化速度不如手写的另一个原因（第一个原因是文件大）。

这就是上一篇那两个毛病的解法：

| 上一篇的毛病 | 这一篇 |
|---|---|
| 加字段要改两个类 | 不用改，`writeObject` 自动读到新字段 |
| 顺序靠人记 | 不用记，Java 自己定的顺序 |

## 3.5 第四步：关掉流

```java
oos.close();
os.close();
```

先关外层，再关内层。关 `oos` 的时候，它会先把缓冲区里没写完的数据刷出去，再把文件关掉。

到这里写就完成了。

## 3.6 ObjectOut 完整代码

```java
package com.studybigdata.hadoop.java.object;

import com.studybigdata.hadoop.java.entity.Student;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectOutputStream;

public class ObjectOut {
    public static void main(String[] args) throws IOException {

        FileOutputStream os = new FileOutputStream("stu_object.bin");
        ObjectOutputStream oos = new ObjectOutputStream(os);

        Student stu = new Student();
        stu.setId(1);
        stu.setName("张三");
        stu.setHeight(180.00);
        oos.writeObject(stu);

        oos.close();
        os.close();
    }
}
```

跑一下，控制台依然没有输出。去看文件：

```
stu_object.bin    127 字节
```

同样一个学生，上一篇是 20 字节，这一篇变成了 **127 字节**。

先别急着问为什么，先把读回来做完，最后一起看。

## 3.7 第五步：读回来

打开输入流，包一层 `ObjectInputStream`：

```java
FileInputStream fis = new FileInputStream("stu_object.bin");
ObjectInputStream ois = new ObjectInputStream(fis);
```

读的时候只有一个方法：

```java
Object o = ois.readObject();
```

但注意它的返回值类型是 **`Object`** —— 它不知道自己读出来的是个什么类。
`ObjectOutputStream` 写的时候知道，`ObjectInputStream` 读的时候不知道，所以只能先给你一个 `Object`。

要拿到 `Student`，得强转：

```java
Student student = (Student) o;
System.out.println(student);
```

## 3.8 ObjectIn 完整代码

```java
package com.studybigdata.hadoop.java.object;

import com.studybigdata.hadoop.java.entity.Student;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.ObjectInputStream;

public class ObjectIn {
    public static void main(String[] args) throws IOException, ClassNotFoundException {

        FileInputStream fis = new FileInputStream("stu_object.bin");
        ObjectInputStream ois = new ObjectInputStream(fis);
        Object o = ois.readObject();
        Student student = (Student) o;
        System.out.println(student);

        ois.close();
        fis.close();

    }
}
```

运行结果：

```
Student{id=1, name='张三', height=180.0}
```

数据完好。注意 `main` 方法上多了两个异常：除了 `IOException`，还有 `ClassNotFoundException`。
因为 `readObject` 要根据文件里的类名去加载 `Student` 这个类，万一找不到（比如类被删了、改名了），就得报这个错。

还有一点值得留意：**整个读回来的过程，没有调用 `Student` 的构造方法。**

上一篇的 `DataIn` 里，我们明明白白写了一句 `Student student = new Student();`。
这一篇没有——`readObject()` 直接把对象"造"出来了，字段值直接从字节里填进去。

## 3.9 为什么从 20 字节变成了 127

现在回答那个问题。两个文件装的是同一个学生的同三个值，大小差了 107 字节。

原因很简单：**这个文件不光存了数据，还存了"说明书"。**

```
stu_data.bin    只有数据和长度标记
                4 字节 id + 2 字节长度 + 6 字节名字 + 8 字节身高 = 20

stu_object.bin  数据和说明书
                20 字节的数据  +  107 字节的"这个类长什么样"
```

"说明书"里装了什么？大致是这些：

- 这个对象的类叫什么 —— `com.studybigdata.hadoop.java.entity.Student`，光这个名字就 43 个字符
- 这个类的版本号是多少 —— 也就是 `serialVersionUID` 那个 `1`
- 这个类有几个字段 —— 3 个
- 每个字段叫什么名字、是什么类型 —— `height` 是 `double`、`id` 是 `int`、`name` 是 `String`

有了这些，读的一方才能"不认识这个类也能把字节解开"。
所以文件大了一截，换来的是"全自动、不用你操心顺序"。

## 3.10 这个方案的问题

全自动是做到了，但带来了新的问题。

**一、文件变胖。**

同一份数据，20 字节变成 127 字节，是之前的 6 倍（127 ÷ 20 ≈ 6.35）。

如果只存一条记录，107 字节的说明书不算什么。但如果要存一百万条记录，每条都带一份说明书，浪费就很可观了。而且**类名越长，浪费越大**。

**二、说明书是 Java 专有的。**

那个 `com.studybigdata.hadoop.java.entity.Student` 是 Java 的类名，`serialVersionUID` 是 Java 的机制，`L...;` 这种字段签名也是 Java 的写法。换个语言来读这个文件，它不认识这些东西。

## 3.11 那么 Hadoop 怎么办

Hadoop 要处理的场景，正好和这个方案的弱点撞上了：

- 数据量大，传得多 —— **文件大小敏感**
- 集群里不只有 Java —— **要能被别的语言读**

所以 Hadoop 没有用 `Serializable`，而是自己定了一套规矩：`Writable` 接口。

它的思路很有意思——**回到上一篇的手工写法，但把它变成一套标准**。
下一篇就看它怎么写。

---

上一篇：[第 2 篇 第一次尝试：手工把字段写进文件](02-data-手工写入.md) ｜ 下一篇：[第 4 篇 第三次尝试：Hadoop 的 Writable](04-writable.md)
