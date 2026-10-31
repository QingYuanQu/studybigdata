---
title: Spring Hello World
date: 2023-05-07 17:03:00
categories:
- JavaEE
tags:
- JavaEE
- Spring
---

# Spring

## 控制反转

### 类的定义

```java
package com.studybigdata.javaee.spring.ioc;

public class Computer {

    public void surf(){
        System.out.println("电脑上网");
    }
}
```

### 传统方式创建类的实例

```java
Computer thinkpad = new Computer();
thinkpad.surf();
```

### IOC方式创建类的实例

##### 配置实例

```xml
<bean id="computer" class="com.studybigdata.javaee.spring.ioc.Computer"/>
```

##### 获取实例

```java
ApplicationContext ac = new ClassPathXmlApplicationContext("spring-cfg.xml");
Computer huawei =(Computer) ac.getBean("computer");
huawei.surf();
```

这种方式有个优点，如果需要换一种上网设备，如`Mobile`，只需要让`Mobile`继承`Computer`类；在配置实例时，指定`class`为`Mobile`的全限定类名即可。编译时类为`Computer`，运行时类型为`Mobile`，多态发生。

> 声明该变量的类型为`编译时类型`；
>
> 赋值给该变量的类型为`运行时类型`。

## 依赖注入

### Setter

##### Computer

```java
public class Computer {

    public void surf(){
        System.out.println("电脑上网");
    }
}
```

##### Human

```java
public class Human {

	private Computer computer;
    
    //setter
	public void setComputer(Computer computer) {
		this.computer = computer;
	}    
    
	public void useComputer(){
		computer.surf();
	}
}
```

##### 传统方式

```java
    Computer computer = new Computer();
    Human human = new Human();
    human.setComputer(computer);
    human.useComputer();
```

##### Spring依赖注入

```xml
<bean id="computer" class="com.studybigdata.javaee.spring.ioc.Computer"/>

<bean id="human" class="com.studybigdata.javaee.spring.ioc.Human">
    <property name="computer" ref="computer"/>
</bean>
```

### 构造函数

##### Computer

```java
public class Computer {

    public void surf(){
        System.out.println("电脑上网");
    }
}
```

##### Human

```java
public class Human {

	private Computer computer;
    
	//构造函数
	public Human(Computer computer) {
		this.computer = computer;
	}

	public void useComputer(){
		computer.surf();
	}
}
```

在这里，定义了一个包含一个参数的构造函数，只能使用该构造函数实例化对象，无法使用无参构造函数实例化对象。即`new Human()`创建一个对象。

##### 传统方式

```java
    Computer computer = new Computer();
    Human human = new Human(computer); //new Human()会报错
    human.useComputer();
```

##### 依赖注入

```xml
<bean id="computer" class="com.studybigdata.javaee.spring.ioc.Computer"/>

<bean id="human" class="com.studybigdata.javaee.spring.ioc.Human">
    <constructor-arg index="0" ref="computer"/>
</bean>
```

> 注意：使用Spring依赖注入的方式，需要指定默认无参构造函数。

