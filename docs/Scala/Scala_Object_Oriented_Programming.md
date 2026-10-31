---
title: Scala面向对象编程
date: 2022-11-06 06:31:26
categories:
- Scala
---

# Scala面向对象编程

## 类

### 类定义

定义一个计数器类，可以对计数器增加某值，也可以获取计数器当前值。

##### 常规方式

**Counter.scala**

```scala
package com.studybigdata.scala

//1. 类定义
class Counter {
  
  //2. 字段定义，默认公有
  var value = 0

  //3. 方法定义
  def increment(num: Int): Unit = {
    value = value + num
  }

  def current(): Int = {
    return value
  }

}

object Counter {
  def main(args: Array[String]): Unit = {
    //4. 对象创建
    val counter = new Counter()

    //5. 字段set，get
    counter.value = 5
    println(counter.value)

    //6. 方法调用
    counter.increment(1)
    println(counter.current())
  }
}
```

### 成员可见性

- 类内所有`成员`的`可见性`默认为`公有`；

- `scala`提供了`private`和`protected`;
  - `private`对`本类`和`嵌套类`可见；
  - `protected`对`本类`和`继承类`可见；

**Counter.scala**

```scala
package com.studybigdata.scala
package oop.access

//1. 类定义
class Counter {

  //2. 字段定义，默认公有
  private var count = 0

  //2.1 getter
  def value: Int ={
    count
  }
  //2.2 setter
  def value_=(v:Int): Unit ={
    if (v>0) count = v
  }

  //3. 方法定义
  def increment(num: Int): Unit = {
    count = count + num
  }

  def current(): Int = {
    return count
  }

}

object Main {
  def main(args: Array[String]): Unit = {
    //4. 对象创建
    val counter = new Counter()

    //5. 当使用第二步所示的方式时， setter方法 counter.value_=(1) 可简写成如下格式：
    counter.value = -1
    println(counter.value)

    //6. 方法调用
    counter.increment(1)
    println(counter.current())
  }
}
```

### 方法定义

`def 方法名(参数列表):返回结果类型={方法体}`

- 方法参数
  - 不可变类型，不要加修饰符`val`或`var`；
- 方法小括号
  - 无参方法可以不加括号，调用时也不要带括号；
  - 无参方法带括号，调用时`最好`也带上括号；

- 方法体大括号
  - 当方法体只有一条语句时，可以省略大括号。
- 方法调用
  - 方法只有一个参数时，可以使用`中缀操作符`方式调用方法
- 返回值
  - 可以省略`return`关键字，方法体中`最后一个语句的值`作为返回值
  - 建议添加返回值类型。
  - 不需要返回值时，可以省略 `=`，但是不要省略大括号

### 构造器





## 对象



## 继承



## 特质



## 模式匹配



## 包



## 面向对象小例子

```scala
package com.studybigdata.scala
package oop.absclass


/**
 * 抽象类：Animal(id,name,age)
 * 抽象字段
 * 具体字段
 * 具体方法 speak
 * 抽象方法 action
 *
 * 特质：Flyable
 * 抽象字段 maxFlyHeight:Int
 * 抽象方法 fly
 *
 * HasLegs
 * 具体字段 legs = 4
 * 具体方法 run
 *
 * 继承类： Dog
 * 增加字段 weight
 * 构造器一 Dog(name,age)
 * 构造器二 Dog(name,age,weight)
 * 继承类：Bird(height)，
 *
 *
 *
 */
trait Flyable {
  var maxFlyHeight: Int

  def fly(): Unit
}

trait HasLegs {
  var legs: Int = 4

  def run(): String = {
    if (legs == 2) {
      s"I have $legs legs, I run slower"
    } else if (legs == 4) {
      s"I have $legs legs, I run faster"
    } else {
      s"I have $legs legs"
    }
  }
}

abstract class Animal {

  var id: Int = Animal.increaseId
  val name: String
  var age: Int = _

  def action()

  def speak(): Unit = {
    println(s" name: $name ; age: $age ！")
  }
}

object Animal{
  var id = 0

  def increaseId: Int = {
    id += 1
    id
  }
}

class Dog(override val name: String, age: Int) extends Animal with HasLegs with Flyable {

  private var weight: Int = _

  def this(name: String, age: Int, weight: Int) {
    this(name, age)
    println(age)
    this.weight = weight
  }

  override def action(): Unit = {
    println("看家护院")
  }

  override def speak(): Unit = {
    println(s"id: $id;  name: $name ; age: $age ; weight:$weight！")
  }

  override def run(): String = {
    s"I am  $name, I have $legs legs, I run very fast"
  }

  override var maxFlyHeight: Int = 0

  override def fly(): Unit = {
    println("I can not Fly")
  }
}

object Dog {

  def apply(name: String, age: Int): Dog = new Dog(name, age)

  def apply(name: String, age: Int, weight: Int): Dog = new Dog(name, age, weight)

  def unapply(dog: Dog): Option[(Int, String, Int, Int)] = Some(dog.id, dog.name, dog.age, dog.weight)
}

class Bird(override val name: String, age: Int) extends Animal with Flyable {
  override def action(): Unit = {
    println("消灭害虫")
  }

  override def speak(): Unit = {
    println(s"id: $id;  name: $name ; age: $age ; maxFlyHeight:$maxFlyHeight！")
  }

  override var maxFlyHeight: Int = 1000

  override def fly(): Unit = {
    println(s" I am %s , I can fly %d m", name, maxFlyHeight)
  }
}

object Test {
  def main(args: Array[String]): Unit = {
    val bird1 = new Bird("bird1",5)
    bird1.speak()

    val dog1 = Dog("dog1", 10)
    dog1.age = 11
    dog1.speak()
    println(dog1.run())

    val Dog(id, name, age, weight): Dog = dog1
    println(id)
    println(name)
    println(age)
    println(weight)
  }
}
```



