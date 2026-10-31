---
title: Scala数据结构
date: 2022-10-26 15:55:26
categories:
- Scala
---



# Scala 数据结构

## 数组Array

```scala
final class Array[T](_length: Int) extends java.io.Serializable with java.lang.Cloneable 
```

数组是可变的可索引集合，数组内容可变。

### 构造

#### 指定长度的空数组

```scala
scala> val arr = new Array[String](4)
arr: Array[String] = Array(null, null, null, null)
```

#### 显示指定类型

```scala
scala> val nums = Array[Int](1,2,3)
nums: Array[Int] = Array(1, 2, 3)
```

#### 隐式推断类型

```scala
scala> val subjects = Array("Hadoop","HBase","Spark")
subjects: Array[String] = Array(Hadoop, HBase, Spark)
//注意字符串不要使用单引号
```

#### 多维数组

```scala
scala> var twoDimArray = Array.ofDim[Int](2,3)
twoDimArray: Array[Array[Int]] = Array(Array(0, 0, 0), Array(0, 0, 0))
```

### 元素访问与修改

```scala
// 元素访问
scala> nums(1)
res4: Int = 2

// 元素修改
scala> subjects(2)="PySpark"
scala> subjects(2)
res2: String = PySpark

// 二维数组元素修改
scala> twoDimArray(1)(1) = 1
scala> twoDimArray
res5: Array[Array[Int]] = Array(Array(0, 0, 0), Array(0, 1, 0))
```



## 元组TupleN

`元组`是对多个不同数据类型对象的封装，`Scala`提供了`TupleN`类（`1<=N<=22`）；元组内容不可变。

### 构造

```scala
scala> val scores = Tuple3("quqingyuan", 'm', 98)
scores: (String, Char, Int) = (quqingyuan,m,98)
// 或
scala> ("quqingyuan", 'm', 98)
res6: (String, Char, Int) = (quqingyuan,m,98)
```

### 元素访问

```scala
scala> scores._1
res8: String = quqingyuan
```

注意：索引值从`1`开始，不支持元素的修改。



### 注意

数组也可存放不同数据类型的对象，`scala`选择所有初始值`最近的数据类型`作为元素的类型。

```scala
scala> val subjects = Array(1, 2.3f)
subjects: Array[Float] = Array(1.0, 2.3)
```



<iframe id="embed_dom" name="embed_dom" frameborder="0" style="display:block;width:1050px; height:490px;" src="https://www.processon.com/embed/6355f2c76376896b5f9c9b32"></iframe>

## 相关特质

### Seq/Set/Map

序列`Seq(Sequence)`，有序，使用整数从`0`进行索引；

集合`Set`，无序，无法索引；

映射`Map`，可根据`key`进行索引。



`List`,`Set`,`Map`均在`scala.collection.immutable`包下定义，值不可变。

## 序列Seq

### 列表List

#### 构造

```scala
scala> val subjects = List[String]("Hadoop","HBase","Spark")
subjects: List[String] = List(Hadoop, HBase, Spark)
```

##### 空列表

```scala
scala> Nil
res0: scala.collection.immutable.Nil.type = List()
```

#### 访问

##### 按照索引访问

```scala
scala> subjects(2)
res5: String = Spark
```

##### 访问头部

```scala
//访问第一元素
scala> subjects.head
res13: String = Hadoop
```

##### 访问尾部

`tail`返回除第一个元素外的其他元素构成的列表

```scala
scala> subjects.tail
res15: List[String] = List(HBase, Spark)
```

注意：列表采用`链表`结构，除`head`和`tail`时间复杂度为`O(1)`，其他索引访问都需要从头部开始遍历，时间复杂度为`O(n)`，如要实现操作为常数时间，可以使用向量`Vector`。

#### 拼接

##### 头部拼接1

```scala
scala> val subjectsList = "Linux"::subjects
subjectsList: List[String] = List(Linux, Hadoop, HBase, Spark)
```

`::` 操作符实际上是如下方法：

```scala
scala> val subjectList2 = subjectsList.::("Java")
subjectList2: List[String] = List(Java, Linux, Hadoop, HBase, Spark)
```

##### 头部拼接2

```scala
scala> val subjectsList3 = "Java"::"Hadoop"::"HBase"::Nil
subjectsList3: List[String] = List(Java, Hadoop, HBase)
```

注意`Nil`空列表不可省略。

##### 头部拼接3

```scala
scala> "Java"+:subjects
res8: List[String] = List(Java, Hadoop, HBase, Spark)
```

`+:`操作符实际上是如下方法：

```scala
scala> subjects.+:("Java")
res11: List[String] = List(Java, Hadoop, HBase, Spark)
```

##### 尾部拼接

```scala
scala> subjects:+"Flink"
res9: List[String] = List(Hadoop, HBase, Spark, Flink)
```

注意：`::`,`+:`,`:+`操作符都会返回新对象。

##### 两个列表拼接

```scala
scala> val subjects1 = List[String]("Hadoop","HBase","Spark")
subjects1: List[String] = List(Hadoop, HBase, Spark)

scala> val subjects2 = List("Storm","Flink")
subjects2: List[String] = List(Storm, Flink)

scala> subjects1++subjects2
res31: List[String] = List(Hadoop, HBase, Spark, Storm, Flink)
```

### 向量Vector

```scala
scala> val subjects = Vector("quqingyuan",'m',90)
subjects: scala.collection.immutable.Vector[Any] = Vector(quqingyuan, m, 90)
```

#### 拼接

```scala
scala> val subject1 = 0+:subjects
subject1: scala.collection.immutable.Vector[Any] = Vector(0, quqingyuan, m, 90)

scala> val subject1 = subjects:+"shandong"
subject1: scala.collection.immutable.Vector[Any] = Vector(quqingyuan, m, 90, shandong)
```

注意`Vector`不支持`::`操作符，`::`是`List`中的成员方法。



`List`和`Vector`都是不可变的，元素不能被增加、删除、修改。`List`和`Vector`的可变版本为`ListBuffer`和`ArrayBuffer`。均在`scala.collection.mutable`包下定义，值可变。使用前需要先导入

```scala
scala> import scala.collection.mutable.ListBuffer
import scala.collection.mutable.ListBuffer
```

### ListBuffer

#### 构造

```scala
scala> val subjects = ListBuffer("Hadoop","HBase","Spark")
subjects: scala.collection.mutable.ListBuffer[String] = ListBuffer(Hadoop, HBase, Spark)
```

#### 修改

##### 追加

```scala
scala> "Java"+:subjects
res19: scala.collection.mutable.ListBuffer[String] = ListBuffer(Java, Hadoop, HBase, Spark)

scala> subjects:+"Storm"
res20: scala.collection.mutable.ListBuffer[String] = ListBuffer(Hadoop, HBase, Spark, Storm)

scala> subjects+="Flink"
res21: subjects.type = ListBuffer(Hadoop, HBase, Spark, Flink)
```

##### 删除

```scala
scala> subjects-="HBase"
res22: subjects.type = ListBuffer(Hadoop, Spark, Flink)
```

可以发现

与`List`相同，`+:`和`:+`操作符都没有对原对象进行修改，只是返回了一个新的对象。

直接修改原对象，可以使用`+=`或`-=`操作符。

与`List`相同，`++`会拼接两个`ListBuffer`，但不会修改两个`ListBuffer`，会返回拼接后的结果。

直接在原`ListBuffer`上拼接另一个`ListBuffer`，可以使用`++=`操作符。

```scala
scala> val subjects1 = ListBuffer("Hadoop","HBase","Spark")
subjects1: scala.collection.mutable.ListBuffer[String] = ListBuffer(Hadoop, HBase, Spark)

scala> val subjects2 = ListBuffer("Storm","Flink")
subjects2: scala.collection.mutable.ListBuffer[String] = ListBuffer(Storm, Flink)

scala>

scala> subjects1++subjects2
res34: scala.collection.mutable.ListBuffer[String] = ListBuffer(Hadoop, HBase, Spark, Storm, Flink)

scala> subjects1++=subjects2
res35: subjects1.type = ListBuffer(Hadoop, HBase, Spark, Storm, Flink)
```

##### 按索引插入

```scala
scala> subjects.insert(1,"HBase","Hive")

scala> subjects
res24: scala.collection.mutable.ListBuffer[String] = ListBuffer(Hadoop, HBase, Hive, Spark, Flink)
```

##### 按索引删除元素

会返回删除元素

```scala
scala> subjects.remove(2)
res26: String = Hive
```

### ArrayBuffer

略。

### 等差数列

#### until

```scala
scala> val nums = 1 until 7 by 2
nums: scala.collection.immutable.Range = Range 1 until 7 by 2

scala> nums(2)
res45: Int = 5

scala> nums.length
res46: Int = 3
```

#### Range

```scala
scala> Range(1,7,2)
res47: scala.collection.immutable.Range = Range 1 until 7 by 2
```

#### to

```scala
scala> val nums = 1 to 7 by 2
nums: scala.collection.immutable.Range = Range 1 to 7 by 2

scala> nums.length
res49: Int = 4
```

注意：`until`和`to`还可以应用于`浮点`，`字符`数据类型；`Range`作用于字符时，会根据`ASCII表`转为对应的数字。

```scala
scala> val chars = 'a' to 'z'
chars: scala.collection.immutable.NumericRange.Inclusive[Char] = NumericRange a to z

scala> chars.length
res52: Int = 26

scala> chars(2)
res55: Char = c

scala> Range('a','z')
res56: scala.collection.immutable.Range = Range 97 until 122
```



## 集合Set

默认情况下，创建的是不可变`Set`。

### Immutable

```scala
scala> var subjects = Set("Hadoop","HBase","Spark")
subjects: scala.collection.immutable.Set[String] = Set(Hadoop, HBase, Spark)
// 当声明为val，则不能追加元素
scala> subjects+="Flink"

scala> subjects
res28: scala.collection.immutable.Set[String] = Set(Hadoop, HBase, Spark, Flink)
```

### Mutable

```scala
scala> import scala.collection.mutable.Set
import scala.collection.mutable.Set

scala> val subjects = Set("Hadoop","HBase","Spark")
subjects: scala.collection.mutable.Set[String] = Set(Hadoop, HBase, Spark)

scala> subjects+="Flink"
res29: subjects.type = Set(Flink, Hadoop, HBase, Spark)

scala> subjects
res30: scala.collection.mutable.Set[String] = Set(Flink, Hadoop, HBase, Spark)
```

## 映射Map

与`List`和`Map`一样，`scala`默认使用的是不可变`Map`。

### immutable

```scala
//构造
var hadoopScore = Map("zhangsan"->80, "lisi"->90, "quqingyuan"->100)
//查询
val score = if (hadoopScore.contains("quqingyuan")){
  hadoopScore("quqingyuan")
}else{
  80
}
println(score)
//追加元素，如果hadoopScore声明为val则不能追加
hadoopScore+=("wangwu"->75)
println(hadoopScore)

//修改元素，则会报错
hadoopScore("quqingyuan") = 100
```

### mutable

```scala
//构造
val hadoopScore = Map("zhangsan" -> 80, "lisi" -> 90, "quqingyuan" -> 100)
//查询
val score = if (hadoopScore.contains("quqingyuan")){
  hadoopScore("quqingyuan")
}else{
  80
}
println(score)
//增加元素
hadoopScore+=("wangwu"->75)
println(hadoopScore)

//可修改元素值
hadoopScore("quqingyuan") = 99
```

## 迭代器Iterator

```scala
val hadoopScore = Map("zhangsan" -> 80, "lisi" -> 90, "quqingyuan" -> 100)

val iter = Iterator(hadoopScore.keys)
while (iter.hasNext){
  println(iter.next())
}
```
