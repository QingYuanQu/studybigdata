---
title: Scala安装与基本使用
date: 2022-10-02 15:55:26
categories:
- Scala
---





# Scala简介

- Scala运行于Java虚拟机（JVM）之上，并且兼容现有的Java程序

- Scala是一门纯粹的面向对象的语言

- Scala也是一门函数式编程语言



# Scala安装

Scala依赖于Java虚拟机，首先需要安装与系统匹配的JDK，此处省略了JDK的安装。

## Scala下载

我使用的Linux发行版是CentOS7，下载的是`rpm	`包；

Windows下载的是`msi`包。

如果下载的是`scala`压缩包，需要把`SCALA_HOME/bin`追加到`PATH`环境变量中。

```http
https://www.scala-lang.org/download/2.12.16.html
```

## Linux安装

```shell
[root@node0 ~]# chmod +x scala-2.12.16.rpm 
[root@node0 ~]# rpm -i scala-2.12.16.rpm 
```

## Windows安装

直接双击`msi`安装即可。

# Scala基本使用

## 解释器

```scala
[root@node0 ~]# scala
Welcome to Scala 2.12.16 (Java HotSpot(TM) 64-Bit Server VM, Java 1.8.0_202).
Type in expressions for evaluation. Or try :help.

scala> var a = 1
a: Int = 1

scala> var b = 2
b: Int = 2

scala> a+b
res0: Int = 3

scala> :quit
[root@node0 ~]#
```



## 解释器中运行脚本

##### wordcount.scala

```scala
println("hello world")
```

##### 执行脚本

```scala
[root@node0 ~]# scala
Welcome to Scala 2.12.16 (Java HotSpot(TM) 64-Bit Server VM, Java 1.8.0_202).
Type in expressions for evaluation. Or try :help.

scala> :load /root/helloworld.scala
Loading /root/helloworld.scala...
hello world

scala> 
```

## 编译运行

##### 编译上述脚本

```scala
[root@node0 ~]# scalac helloworld.scala 
helloworld.scala:1: error: expected class or object definition
println("hello world")
^
one error found
```

##### 重写书写脚本内容

```scala
object HelloWorld{
        def main(args:Array[String]){
                println("hello world")
        }
}
```

##### 编译脚本

```scala
[root@node0 ~]# scalac helloworld.scala 
[root@node0 ~]# ll
-rw-r--r--. 1 root root       645 Oct 30 17:48 HelloWorld.class
-rw-r--r--. 1 root root       669 Oct 30 17:48 HelloWorld$.class
-rw-r--r--. 1 root root        80 Oct 30 17:48 helloworld.scala
```

##### 使用scala执行脚本

```shell
[root@node0 ~]# scala helloworld
No such file or class on classpath: helloworld
[root@node0 ~]# scala HelloWorld
hello world
```

##### 使用Java执行脚本

```shell
[root@node0 ~]# java -classpath .:/usr/share/scala/lib/scala-library.jar HelloWorld
hello world
You have new mail in /var/spool/mail/root
```

注意：`-classpath .:/usr/share/scala/lib/scala-library.jar HelloWorld`是指在当前目录`.`和指定目录`/usr/share/scala/lib/scala-library.jar`作为`classpath`。