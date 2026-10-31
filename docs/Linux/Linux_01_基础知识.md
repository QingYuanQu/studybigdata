---
title: Linux基础知识
date: 2023-01-14 15:55:26
categories:
- Linux
tags:
- Linux基础知识
marp: true
---

![content_1](./img/Linux_01_%E5%9F%BA%E7%A1%80%E7%9F%A5%E8%AF%86/content_1.png)

## Linux基础知识

#### CentOS各种安装版本

```python
1、CentOS-7-DVD版本：DVD是标准安装盘，一般下载这个就可以了；
2、CentOS-7-NetInstall版本：网络安装镜像；
3、CentOS-7-Everything版本：对完整版安装盘的软件进行补充，集成所有软件；
4、CentOS-7-LiveGnome版本：GNOME桌面版；
5、CentOS-7-KdeLive版本：KDE桌面版；
6、CentOS-7-livecd版本：光盘上运行的系统，类拟于winpe。
```

>   https://cloud.tencent.com/developer/article/2139042?areaSource=102001.9&traceId=6MeeCaKLlmQUzKBU557lZ

#### 桌面环境

xxxxxxxxxx yum install wget -ybash

```text
                          1996年>欧洲>C++语言>QT商业开源>KDE>X-clients
1986年>北美>XWindow>Xlib {
                          1997年>北美>C语言>GTK（GPL）>GNOME>X-clients
```

>   [开心小小喵](https://www.zhihu.com/people/deletedeletedelete)https://www2.zhihu.com/question/20096783/answer/647227236



##### GNOME

![img](./img/Linux_01_%E5%9F%BA%E7%A1%80%E7%9F%A5%E8%AF%86/undefined536b98b960274878b9dadbc911700d19.png)

##### KDE

![img](./img/Linux_01_%E5%9F%BA%E7%A1%80%E7%9F%A5%E8%AF%86/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3lpMTkzMjI5ODMz,size_16,color_FFFFFF,t_70.jpeg)

![img](./img/Linux_01_%E5%9F%BA%E7%A1%80%E7%9F%A5%E8%AF%86/2428209-20210924222115597-326838274.jpg)

#### 字符操作

![image-20240305121951490](./img/Linux_01_%E5%9F%BA%E7%A1%80%E7%9F%A5%E8%AF%86/image-20240305121951490.png)

在字符操作方式下可以高效地完成所有的任务，尤其是系统管理任务。

系统管理任务通常在远程进行，而远程登录后进入的是字符工作方式。

由于使用字符界面不用启动图形工作环境，大大地节省了系统资源开销。

#### SSH

![SSH client and SSH server with a lock between them.](./img/Linux_01_%E5%9F%BA%E7%A1%80%E7%9F%A5%E8%AF%86/What-is-SSH-820x460.jpg)

在`Linux`环境下使用`ssh`登录远程`Linux`系统。`ssh`是英文`Secure Shell`的缩写。用户在通过`ssh`连接到远程系统时在网络上传输的口令和数据都是经过加密的。比传统的`telnet`远程登录更加安全。

`SSH`的使用方法：

```bash
$ ssh 192.168.1.100
$ ssh zhangsan@192.168.1.100
```

##### 常见SSH远程登录工具

-   PuTTY

-   MobaXterm

-   Xshell

-   SecureCRT
-   Windows PowerShell

#### 虚拟控制台（Virtual Console）

系统默认提供了6个虚拟控制台。每个虚拟控制台可以独立的使用，互不影响。

使用  `Ctrl+Alt+ F1～F6`进行多个虚拟控制台之间的切换 。

#### 控制台符号

```shell
$ : 普通用户
# : root用户
```

#### Linux 命令格式

```[sun@localhost ~]$ command [-options] [param1 param2 ……]```

​                  命令    选项     参数1  参数2 

说明：

1.   一行命令中，第一个输入的一定是`命令(command)`或`可执行文件`;
2.   中括号`[]`并不存在于实际的命令中，而加入选项设置时，通常选项前会带`-`号；
3.   `param1 param2…`为依附在`option`后面的参数，或者是`command`的参数；
4.   `命令`，`-options`，`参数`等之间以`空格`区分，不论空几格shell都视为一格；
5.   按下`回车键`，命令立即执行；

#### 清空屏幕

```
clear
```

#### 历史命令

- 键盘 `↑` 箭头

- history