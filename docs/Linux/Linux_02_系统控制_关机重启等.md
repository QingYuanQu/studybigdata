---
title: Linux系统控制
date: 2023-01-14 15:55:26
categories:
- Linux
tags:
- Linux
marp: true
---

## 系统控制

#### 系统注销

终止用户与系统的交互进程， end session。

```python
logout
exit
Ctrl + d
```

#### shutdown

##### 关机

```bash
# shutdown (系统1分钟关机，并传送一些消息给正在使用的user) 
[root@localhost ~]# shutdown
Shutdown scheduled for Sun 2024-03-03 19:50:08 CST, use 'shutdown -c' to cancel.
[root@localhost ~]# 
Broadcast message from root@localhost.localdomain (Sun 2024-03-03 19:49:08 CST):

The system is going down for power-off at Sun 2024-03-03 19:50:08 CST!


# 取消关机
shutdown -c

Broadcast message from root@localhost.localdomain (Sun 2024-03-03 19:49:19 CST):

The system shutdown has been cancelled at Sun 2024-03-03 19:50:19 CST!

[root@localhost ~]# 
```

##### 一定时间后关机

```bash
[root@localhost ~]# shutdown -h +5
Shutdown scheduled for Sun 2024-03-03 19:55:22 CST, use 'shutdown -c' to cancel.
[root@localhost ~]# 
Broadcast message from root@localhost.localdomain (Sun 2024-03-03 19:50:22 CST):

The system is going down for power-off at Sun 2024-03-03 19:55:22 CST!
```

##### 定时关机

```bash
[root@localhost ~]# shutdown -h 20:00
Shutdown scheduled for Sun 2024-03-03 20:00:00 CST, use 'shutdown -c' to cancel.
[root@localhost ~]# 
Broadcast message from root@localhost.localdomain (Sun 2024-03-03 19:51:19 CST):

The system is going down for power-off at Sun 2024-03-03 20:00:00 CST!
```

##### 立刻关机

```bash
shutdown -h now (下完这个指令，系统立刻关机) 
```

##### 立刻重启

```python
shutdown -r now (下完这个指令，系统立刻重新启动，相当于reboot) 
```

#### 系统重启

```python
reboot
```

#### 运行级别

Linux是通过运行级别来确定系统启动时到底启动哪些服务的。Linux 默认有 7 个运行级别（runlevel），具体如下：

| init | 作用                                                        |
| ---- | ----------------------------------------------------------- |
| 0    | 关机                                                        |
| 1    | 单用户模式，可以想象为 Windows 的安全模式，主要用于系统修复 |
| 2    | 不完全的命令行模式，不含 NFS 服务                           |
| 3    | 完全的命令行模式，就是标准字符界面                          |
| 4    | 系统保留                                                    |
| 5    | 图形模式                                                    |
| 6    | 重新启动                                                    |


在 Linux 系统中可以使用 `runlevel `命令来查看系统的运行级别。