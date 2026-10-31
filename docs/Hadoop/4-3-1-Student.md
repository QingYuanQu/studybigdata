# 第 1 篇 从一个 Student 类开始

> 通过 Java 序列化通用知识，一步步引出MapReduce的序列化。

## 1.1 先定义一个类

我们有一个学生，他有学号、姓名、身高。在 Java 里，先给它一个名字：

```java
public class Student {
}
```

一个空的类，什么也做不了。但它已经是一个"类型"了——我们可以用它来创建对象。

### 问答 1-1：空类能造出对象吗

#### 问题

一个空类，`new Student()` 能造出对象吗？造出来之后，它占多大内存？里面有东西吗？

#### 答案

**能造出来。**

一个类能不能 `new`，取决于它有没有可用的构造方法，和有没有字段无关。空类没写构造方法，Java 会自动补一个无参构造，所以 `new Student()` 完全合法。

对象占的内存不是 0。它至少要包含对象的"管理信息"，再加上字段的空间。空类没有字段，但依然要占十几个字节左右（具体多少取决于 JVM 实现，不必记精确值）。

里面"有东西"但你看不到：这个对象知道自己属于哪个类（`getClass()` 能查到），其余字段一个都没有。

## 1.2 加上字段

学生要有数据可存。三个字段，代表三条信息：

```java
public class Student {
    private int id;          // 学号
    private String name;     // 姓名
    private double height;   // 身高
}
```

字段都用 `private`。这是封装的基本做法：数据藏在类里，外面要通过方法去读写。

### 问答 1-2：为什么要用 private

#### 问题

如果改成 `public int id;`，外面直接 `student.id = 1` 也能用，代码还更短。那为什么我们不这么写？

#### 答案

因为 `public` 等于把修改权彻底交出去，而 `private` 把修改权留在类自己手里。

身高不能是负数。用 `public`，你无处下手——外面 `student.height = -5;` 照样能进去，你拦不住。

用 `private`，只要改 `setHeight` 一个方法，就可以拦住不合理的修改：

```java
public void setHeight(double height) {
    if (height < 0) {
        throw new IllegalArgumentException("身高不能为负");
    }
    this.height = height;
}
```

所有调用方自动获得这个检查，一行都不用改。

结论：`private` 不是"为了安全"这种空话，而是**为将来留一个可以插入逻辑的入口**。下一篇你会看到这个入口还有别的用处。

## 1.3 加上读写方法

除了修改，我们还要查询字段的值，于是每个字段配一对方法：

```java
public int getId() {
    return id;
}

public void setId(int id) {
    this.id = id;
}
```

`get` 是读，`set` 是写。三个字段就要三对，一共六个方法。

所以 getter/setter 的价值不在于"现在这行赋值"，而在于**它把访问路径收拢成了一个唯一入口**。将来要加日志、加校验、加通知，都是往这个入口里塞。

```java
public int getId()                          public void setId(int id)
public String getName()                     public void setName(String name)
public double getHeight()                   public void setHeight(double height)
```

这些方法本身没什么逻辑，只做一件事：把值放进去、把值取出来。这种方式通常叫 **POJO**（简单 Java 对象）——只有字段和读写方法，不掺业务逻辑。

## 1.4 加上 toString

如果不重写 `toString()`，`System.out.println(student)` 打印出来是这样的：

```
com.studybigdata.hadoop.java.entity.Student@1b6d3586
```

一串"类名@地址"，看不出任何内容。后面那一串十六进制，其实是对象的哈希值，不是它的内存地址，但同样看不出里面存了什么。

### 问答 1-3：为什么默认不打印字段

#### 问题

既然默认的 `toString()` 这么难用，为什么 Java 不干脆默认就打印字段？如果默认打印全部字段，会有什么麻烦？

#### 答案

因为"打印哪些字段"是**业务决定**，不是语言能替你做主的。

具体有三个麻烦：

1. **性能**：一个大对象可能有上百个字段，甚至嵌套着别的对象。默认全打印，一句日志就可能拖慢程序。
2. **安全**：对象里如果有密码、身份证号，默认打印就等于把它们写进了日志文件。
3. **递归**：如果 A 里有 B，B 里又有 A，互相打印就无限循环了。

所以 Java 把这件事留给你自己做——你只打印你想打印的。默认那个 `类名@哈希值` 是一个"最保守"的选择：什么信息都不泄露，也绝不会死循环。

```java
@Override
public String toString() {
    return "Student{" +
            "id=" + id +
            ", name='" + name + '\'' +
            ", height=" + height +
            '}';
}
```

打印出来就变成了：

```
Student{id=1, name='张三', height=180.0}
```

后面每一篇验证结果，都靠这个方法。它相当于给对象配了一个"显示器"。

## 1.5 完整代码

到这里，`Student` 已经完整了。

```java
package com.studybigdata.hadoop.java.entity;

public class Student {

    private int id;
    private String name;
    private double height;

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

    @Override
    public String toString() {
        return "Student{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", height=" + height +
                '}';
    }
}
```

放在 `entity` 包里，因为它是"实体"——描述一个具体的东西，不是工具，也不是流程。

## 1.6 怎么用它

写一个 `main` 方法，创建一个学生，给字段赋值，再打印出来：

```java
public static void main(String[] args) {
    Student student = new Student();
    student.setId(1);
    student.setName("张三");
    student.setHeight(180.0);

    System.out.println(student);
}
```

运行结果：

```
Student{id=1, name='张三', height=180.0}
```

`new Student()` 在内存里造了一个对象，`setXxx` 往里填数据，`println` 把它打印出来。这就是一个 POJO 的完整生命周期。

## 1.7 这个对象活不过程序

现在请做一个实验：把上面这段 `main` 跑完，然后重新启动程序。

刚才那个 `Student` 对象**不存在了**。

`new` 出来的对象只活在程序运行期间，存在内存里。程序一退出，内存被回收，对象就没了。下次启动，你得从头 `new` 一个、重新赋值。

### 问答 1-4：能不能自己拼成一行文本

#### 问题

既然对象留不住，那能不能自己写个方法，把三个字段拼成一个字符串存进 `.txt` 文件？比如存成 `1,张三,180.0`。下次读进来，用 `split(",")` 拆开再填回去。这样行不行？会遇到什么问题？

#### 答案

**行，这就是 CSV，实际上很常用。但有几个坑：**

1. **分隔符冲突**：如果名字本身带逗号，比如 `张,三`，`split(",")` 就会多切出一段，后面全部错位。
2. **还得转字符串**：`height` 是 `double`，写成文本后要 `Double.parseDouble` 转回来，来回一次可能丢精度。
3. **没有类型信息**：读文件的人看到 `1,张三,180.0`，得先知道"第一列是 int、第三列是 double"才能解析。这个规则还是靠约定。
4. **效率低**：文本格式占空间更大，转换也更慢。

所以这条路不是不行，而是**只适合"给人看、量小"的场景**。

下一篇走另一条路：不拼成文本，而是把字段直接变成**二进制字节**。这样没有分隔符问题，也不用担心精度。

如果这个学生信息要**留下来**——下次启动还能读到，或者要**发到另一台机器**上——就必须把它变成程序之外能保存的东西。

内存里的对象，存不进硬盘，也发不过网线。硬盘和网络能处理的只有一种东西：**字节**。

## 1.8 下一篇要解决的问题

于是问题变成了：

> 怎么把一个 `Student` 对象，变成一串字节？

下一篇先不借助任何特殊接口，就用最直接的办法：把三个字段一个一个拆出来，写进文件。

---

下一篇：[第 2 篇 第一次尝试：手工把字段写进文件](02-data-手工写入.md)
