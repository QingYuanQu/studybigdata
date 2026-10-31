---
marp: true
headingDivider: 6
theme: python-mini-pptx
book: 大数据技术原理与应用
title: Java排序
subtitle: Java CompareTo
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

## 一、学习目标

- 理解 `Comparable` 接口与 `compareTo` 方法的作用
- 掌握 `compareTo` 的返回值含义与排序约定
- 能正确实现自定义类的 `compareTo` 方法
- 避免常见实现陷阱（溢出、一致性、null 处理）
- http://www.baidu.com

## 二、`compareTo` 是什么

`compareTo` 是 `java.lang.Comparable<T>` 接口中唯一的方法：

```java
public interface Comparable<T> {
    int compareTo(T o);
}
```

**核心作用**：定义对象的"自然顺序"（natural ordering），使对象可以被排序（`Collections.sort`、`Arrays.sort`、`TreeSet`、`TreeMap`、`PriorityQueue` 等都依赖它）。

**返回值约定（三值语义）**：

| 返回值          | 含义                       |
| --------------- | -------------------------- |
| 负数（通常 -1） | 当前对象 **小于** 参数对象 |
| 0               | 当前对象 **等于** 参数对象 |
| 正数（通常 1）  | 当前对象 **大于** 参数对象 |

> ⚠️ 注意：只需关心**符号**，不要依赖具体数值大小。`return a - b;` 虽然常见，但有整数溢出风险（见第六节）。

## 三、`compareTo` 的契约（非常重要）

实现 `compareTo` 必须满足以下数学性质，否则 `TreeSet`、`TreeMap` 等有序集合会行为异常：

1. **反对称性**：`x.compareTo(y) == -y.compareTo(x)`
2. **传递性**：若 `x.compareTo(y) > 0` 且 `y.compareTo(z) > 0`，则 `x.compareTo(z) > 0`
3. **一致性**：`x.compareTo(y) == 0` 应与 `x.equals(y) == true` **保持一致**（强烈建议）
4. **null 处理**：`x.compareTo(null)` 应抛出 `NullPointerException`（通常自动满足）

> 💡 为什么"一致性"重要？`TreeSet` 使用 `compareTo` 判断相等，`HashSet` 使用 `equals`。若两者不一致，同一个对象可能同时"存在"和"不存在"于不同集合，导致诡异 bug。

## 四、标准库示例

##### 整型比较

```java
Integer a = 5, b = 3;
System.out.println(a.compareTo(b)); // 1  (5 > 3)
System.out.println(b.compareTo(a)); // -1 (3 < 5)
System.out.println(a.compareTo(5)); // 0
```

##### 字符串比较

```java
String s1 = "apple", s2 = "banana";
System.out.println(s1.compareTo(s2)); // 负数，按字典序比较
```

##### 排序使用

```java
List<Integer> list = new ArrayList<>(List.of(5, 1, 3, 2, 4));
Collections.sort(list);          // 依赖 Integer.compareTo
System.out.println(list);        // [1, 2, 3, 4, 5]
```

## 五、自定义类实现 `compareTo`

### 示例 1：按单个字段排序

```java
public class Student implements Comparable<Student> {
    private String name;
    private int age;

    public Student(String name, int age) {
        this.name = name;
        this.age = age;
    }

    @Override
    public int compareTo(Student other) {
        return Integer.compare(this.age, other.age); // ✅ 推荐写法
    }

    // getter、toString 略
}
```

使用：

```java
List<Student> list = new ArrayList<>(List.of(
        new Student("Alice", 22),
        new Student("Bob", 20),
        new Student("Carol", 21)
));
Collections.sort(list); // 按年龄升序
```

### 示例 2：多字段排序（先年龄，再姓名）

```java
@Override
public int compareTo(Student other) {
    int cmp = Integer.compare(this.age, other.age);
    if (cmp != 0) return cmp;
    return this.name.compareTo(other.name);
}
```

### 示例 3：降序排序

```java
@Override
public int compareTo(Student other) {
    return Integer.compare(other.age, this.age); // 交换参数顺序
}
```

## 六、常见陷阱

### 陷阱 1：整数减法溢出

```java
// ❌ 错误：当 x = Integer.MIN_VALUE 且 y = 1 时溢出
public int compareTo(MyInt o) {
    return this.value - o.value;
}

// ✅ 正确：使用包装类的 compare 静态方法
public int compareTo(MyInt o) {
    return Integer.compare(this.value, o.value);
}
```

### 陷阱 2：与 `equals` 不一致

```java
// ❌ 只按 id 比较，但 equals 按全部字段比较
public int compareTo(User o) { return this.id - o.id; }

// TreeSet 认为 id 相同即"相等"，即使其他字段不同
// 若 equals 返回 false，语义矛盾
```
**解决**：让 `compareTo` 与 `equals` 使用相同的比较字段，或至少保证"`compareTo==0` ⟺ `equals==true`"。

### 陷阱 3：浮点数的特殊值

```java
// ⚠️ NaN 的比较不符合全序，慎用
Double.compare(d1, d2) // 推荐
d1.compareTo(d2)       // 等价，但也要注意 NaN 的排序位置
```

### 陷阱 4：null 参数

```java
@Override
public int compareTo(Student o) {
    Objects.requireNonNull(o, "参数不能为 null");
    // ...
}
```

## 七、`compareTo` vs `Comparator`

| 特性     | `Comparable` / `compareTo` | `Comparator` / `compare`   |
| -------- | -------------------------- | -------------------------- |
| 位置     | 类内部实现                 | 独立类或 lambda            |
| 数量     | 一个类只能有一种自然顺序   | 可定义任意多种排序规则     |
| 修改原类 | 需要                       | 不需要（可用在第三方类上） |
| 典型方法 | `Collections.sort(list)`   | `list.sort(cmp)`           |
| 适用场景 | 类的默认/唯一顺序          | 临时/多规则排序            |

```java
// Comparator 用法（无需修改 Student 类）
list.sort(Comparator.comparingInt(Student::getAge).reversed());
list.sort(Comparator.comparing(Student::getName));
```

> **建议**：只有当类有明确且唯一的"自然顺序"（如 `Integer`、`String`、`LocalDate`）时才实现 `Comparable`，否则优先用 `Comparator`。

## 八、有序集合中的行为演示

```java
TreeSet<Integer> set = new TreeSet<>();
set.add(3);
set.add(1);
set.add(2);
System.out.println(set); // [1, 2, 3]  自动按 compareTo 排序

TreeMap<Student, String> map = new TreeMap<>();
map.put(new Student("Alice", 22), "A");
map.put(new Student("Bob", 20), "B");
// 遍历时按 compareTo 定义的顺序输出
```



## 九、实践清单（Checklist）

实现 `compareTo` 时自检：

- [ ] 使用包装类 `Integer.compare`、`Long.compare`、`Double.compare` 避免溢出
- [ ] 多字段比较是否逻辑清晰（短路返回）
- [ ] 是否与 `equals` 保持一致性
- [ ] 是否处理了 `null`（抛 NPE 或显式校验）
- [ ] 是否符合反对称性、传递性
- [ ] 类是否声明 `implements Comparable<T>`（泛型写具体类型，别写裸类型 `Comparable`）

## 十、课后练习

1. **基础**：为 `Book` 类（字段 `title`、`price`、`publishYear`）实现 `compareTo`，先按价格升序，价格相同按年份降序。
2. **进阶**：不修改 `Book` 类，用 `Comparator` 实现相同规则，并比较两种方式在 `TreeSet` 中的效果。
3. **陷阱题**：解释为什么下面代码在 `list = [MIN_VALUE, 0, 1]` 时会出错，并修复：
   ```java
   @Override
   public int compareTo(MyInt o) { return value - o.value; }
   ```
4. **设计题**：一个 `Person` 类实现 `compareTo` 只按 `id` 比较，`equals` 按 `id + name` 比较，会导致什么 bug？给出两种修复方案。



## 十一、小结

- `compareTo` 定义对象的**自然顺序**，返回负 / 零 / 正表示小于 / 等于 / 大于
- 必须满足**反对称、传递、与 `equals` 一致**
- 实现时用 `Integer.compare` 等工具方法**避免溢出**
- 多字段排序可链式编写
- 非唯一顺序或多规则场景，优选 `Comparator`

掌握 `compareTo` 是使用 Java 集合框架排序、以及理解 `TreeSet`/`TreeMap` 内部机制的基础，务必踏实验证其契约。