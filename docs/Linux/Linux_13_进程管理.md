---
title: Linux进程管理
date: 2023-01-14 15:55:26
categories:
- Linux
tags:
- Linux进程管理
marp: true
---

## 进程管理

### 静态监控 - ps

**ps - report a snapshot of the current processes.**

报告当前进程的快照。

##### -e

​	Select all processes.  Identical(完全相同的) to -A.

##### -f 

​	Do full-format listing. 

---



```shell
[zhangsan@localhost ~]$ ps -ef
UID         PID   PPID  C STIME TTY          TIME CMD
root          1      0  0 01:36 ?        00:00:05 /usr/lib/systemd/systemd --switched-root --sy
root          2      0  0 01:36 ?        00:00:00 [kthreadd]
root          4      2  0 01:36 ?        00:00:00 [kworker/0:0H]
root          6      2  0 01:36 ?        00:00:00 [ksoftirqd/0]
root          7      2  0 01:36 ?        00:00:00 [migration/0]
root          8      2  0 01:36 ?        00:00:00 [rcu_bh]
root          9      2  0 01:36 ?        00:00:01 [rcu_sched]
root         10      2  0 01:36 ?        00:00:00 [lru-add-drain]
root         11      2  0 01:36 ?        00:00:00 [watchdog/0]
...
```

---



### 动态监控 - top


​      display Linux processes

```shell
[zhangsan@localhost test]$ top

top - 15:56:13 up  1:08,  1 user,  load average: 0.06, 0.02, 0.00
Tasks: 257 total,   2 running, 255 sleeping,   0 stopped,   0 zombie
%Cpu(s):  1.2 us,  0.3 sy,  0.0 ni, 98.2 id,  0.2 wa,  0.2 hi,  0.0 si,  0.0 st
MiB Mem :   3710.0 total,   1366.1 free,   1125.2 used,   1218.6 buff/cache
MiB Swap:   2048.0 total,   2048.0 free,      0.0 used.   2328.8 avail Mem 

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND   
   2347 zhangsan  20   0 4132320 357460 118856 S   4.3   9.4   1:09.40 gnome-shell 
   2906 zhangsan  20   0  537584  49324  35264 S   1.0   1.3   0:08.82 gnome-terminal-  
      1 root      20   0  252684  15052   9592 S   0.3   0.4   0:02.74 systemd        
   2397 zhangsan  20   0 1152752  51468  38224 S   0.3   1.4   0:00.49 Xwayland  
   2662 zhangsan  20   0  536416  42968  35364 S   0.3   1.1   0:22.03 vmtoolsd 
      2 root      20   0       0      0      0 S   0.0   0.0   0:00.02 kthreadd                         
      3 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 rc
```

---



### 向进程发送信号 - kill

#### 支持信号列表

```shell
[zhangsan@localhost ~]$ kill -l
 1) SIGHUP  2) SIGINT  3) SIGQUIT  4) SIGILL  5) SIGTRAP
 6) SIGABRT  7) SIGBUS  8) SIGFPE  9) SIGKILL 10) SIGUSR1
11) SIGSEGV 12) SIGUSR2 13) SIGPIPE 14) SIGALRM 15) SIGTERM
16) SIGSTKFLT 17) SIGCHLD 18) SIGCONT 19) SIGSTOP 20) SIGTSTP
21) SIGTTIN 22) SIGTTOU 23) SIGURG 24) SIGXCPU 25) SIGXFSZ
26) SIGVTALRM 27) SIGPROF 28) SIGWINCH 29) SIGIO 30) SIGPWR
31) SIGSYS 34) SIGRTMIN 35) SIGRTMIN+1 36) SIGRTMIN+2 37) SIGRTMIN+3
38) SIGRTMIN+4 39) SIGRTMIN+5 40) SIGRTMIN+6 41) SIGRTMIN+7 42) SIGRTMIN+8
43) SIGRTMIN+9 44) SIGRTMIN+10 45) SIGRTMIN+11 46) SIGRTMIN+12 47) SIGRTMIN+13
48) SIGRTMIN+14 49) SIGRTMIN+15 50) SIGRTMAX-14 51) SIGRTMAX-13 52) SIGRTMAX-12
53) SIGRTMAX-11 54) SIGRTMAX-10 55) SIGRTMAX-9 56) SIGRTMAX-8 57) SIGRTMAX-7
58) SIGRTMAX-6 59) SIGRTMAX-5 60) SIGRTMAX-4 61) SIGRTMAX-3 62) SIGRTMAX-2
63) SIGRTMAX-1 64) SIGRTMAX 
```

主要理解`TERM`信号和`KILL`信号

---



#### 终止进程 - SIGTERM

TERM：该信号可由进程捕获，使用该信号让进程有机会在退出之前做好清理工作，从而体面地终止。

```shell
kill -SIGTERM 939 或 kill -TERM 939 或 kill -15 939 或 kill 939  
```

#### 杀死进程 - SIGKILL

KILL：该信号不能被进程捕捉和忽略，它向系统管理员提供了一种可靠地杀死任何进程的方法。

```shell
kill -SIGKILL 939 或 kill -KILL 939 或 kiil -9 939 
```

---



### 后台运行 - nohup

#### 后台运行(接收TERM)

nohup ： `no hang up` 不挂起，用于在系统后台不挂断地运行命令，退出终端不会影响程序的运行。

默认会在当前目录输出一个`nohup.out`文件，如果当前目录不可写，输出重定向到`$HOME/nohup.out`文件中。

---

#### 实验脚本内容

```shell
[zhangsan@localhost ~]$ cat write.sh 
#!/bin/bash
while true
do
        echo $(date +%F%n%T)  " hello ">> hello.txt
        sleep 5s

done  
```

---

#### 后台运行

使用nohup command & 使其后台运行

```shell
[zhangsan@localhost ~]$ nohup ./write.sh &
[1] 5996
nohup: ignoring input and appending output to 'nohup.out'
```

---

#### 查询脚本运行状态

```bash
# ps aux输出的进程信息，通过管道符'|'交给grep命令，grep过滤包含'write.sh'的行
[zhangsan@localhost ~]$ ps aux|grep write.sh 
zhangsan    5996  0.0  0.0  12724  2924 pts/0    S    03:44   0:00 /bin/bash ./write.sh
zhangsan    6026  0.0  0.0  12136  1068 pts/0    S+   03:44   0:00 grep --color=auto write.sh
```

---

#### 查看脚本结果

```shell
# 查看写入的文件内容
[zhangsan@localhost ~]$ tail -n 10 hello.txt 
2021-11-15 03:28:29  hello 
2021-11-15 03:28:34  hello 
2021-11-15 03:28:39  hello 
2021-11-15 03:28:44  hello 
2021-11-15 03:28:49  hello 
2021-11-15 03:28:54  hello 
2021-11-15 03:28:59  hello 
2021-11-15 03:29:04  hello 
2021-11-15 03:29:09  hello 
2021-11-15 03:29:14  hello 
```

---

#### 终止进程

```shell
# 向后台运行的脚本发送终止信号，让其体面的退出
[zhangsan@localhost ~]$ kill 5996
[1]+  Terminated              nohup ./write.sh
```

可以通过`ps`命令查询到该进程已被终止。

---

#### 后台运行(忽略TERM)

```shell
#!/bin/bash
# 加入下面一行，忽略TERM信号
trap " " TERM
while true
do
        echo $(date +%F%n%T)  " hello ">> hello.txt
        sleep 5s

done
```

---

#### 后台运行

```bash
# 让其后台运行
[zhangsan@localhost ~]$ nohup ./write.sh &
[1] 6339
nohup: ignoring input and appending output to 'nohup.out'
```

---



#### 查询脚本运行状态

```bash
# 查询带有write.sh关键字的进程
[zhangsan@localhost ~]$ ps aux|grep write.sh 
zhangsan    6339  0.0  0.0  12724  3064 pts/0    S    04:02   0:00 /bin/bash ./write.sh
zhangsan    6371  0.0  0.0  12136  1172 pts/0    S+   04:02   0:00 grep --color=auto write.sh
```

---



#### 终止进程

```bash
# 发送TERM信号，让其自行体面的退出。
[zhangsan@localhost ~]$ kill 6339
```

---



#### 查询脚本运行状态

```bash
[zhangsan@localhost ~]$ ps aux|grep write.sh 
zhangsan    6339  0.0  0.0  12724  3092 pts/0    S    04:02   0:00 /bin/bash ./write.sh
zhangsan    6400  0.0  0.0  12136  1044 pts/0    S+   04:02   0:00 grep --color=auto write.sh
```

发现该进程没有体面的退出，仍在后台运行。



---

#### 强制杀死进程

发送杀死信号，它不体面，你帮他体面体面。

```bash
[zhangsan@localhost ~]$ kill -KILL 6339
[1]+  Killed                  nohup ./write.sh
```

---



#### 再次查询脚本运行状态

```shell
[zhangsan@localhost ~]$ ps aux|grep write.sh 
zhangsan    6611  0.0  0.0  12136  1172 pts/0    R+   04:05   0:00 grep --color=auto write.sh
```

再次查询，发现该进程被强制体面了。

---

### 查看打开的文件 - lsof

lsof - list open files



- lsof filename    显示打开指定文件的所有进程
- -c string     显示COMMAND列中包含指定字符的进程所有打开的文件

- -u zhangsan    显示所属user进程打开的文件

- -p 393     根据PID列出打开文件

- -i :22     查看22端口现在运行的情况
- -g gid     显示归属gid的进程情况

---

#### 使用示例

##### 文件

显示打开write.sh的所有进程

```bash
[zhangsan@localhost ~]$ lsof write.sh 
COMMAND   PID     USER   FD   TYPE DEVICE SIZE/OFF     NODE NAME
write.sh 9565 zhangsan  255r   REG    8,3      101 17424983 write.sh
```

---

##### COMMAND列中包含某字符的行

COMMAND列中包含write的行

```bash
[zhangsan@localhost ~]$ lsof -c write
COMMAND    PID     USER   FD      TYPE DEVICE SIZE/OFF     NODE NAME
writeback   45     root  cwd   unknown                          /proc/45/cwd (readlink: Permission denied)
writeback   45     root  rtd   unknown                          /proc/45/root (readlink: Permission denied)
writeback   45     root  txt   unknown                          /proc/45/exe (readlink: Permission denied)
writeback   45     root NOFD                                    /proc/45/fd (opendir: Permission denied)
write.sh  9565 zhangsan  cwd       DIR    8,3     4096 17425438 /home/zhangsan
write.sh  9565 zhangsan  rtd       DIR    8,3      233      128 /
write.sh  9565 zhangsan  txt       REG    8,3  1150736 50725009 /usr/bin/bash
write.sh  9565 zhangsan  mem       REG    8,3  2586930 33857713 /usr/lib/locale/en_US.utf8/LC_COLLATE
write.sh  9565 zhangsan  mem       REG    8,3  3167976   431987 /usr/lib64/libc-2.28.so
write.sh  9565 zhangsan  mem       REG    8,3    28816   431989 /usr/lib64/libdl-2.28.so
write.sh  9565 zhangsan  mem       REG    8,3   208616   431889 /usr/lib64/libtinfo.so.6.1
```

---

##### 所属主

显示所属主为zhangsan的进程所打开的文件

```bash
[zhangsan@localhost ~]$ lsof -u zhangsan |head -n 5
COMMAND    PID     USER   FD      TYPE             DEVICE SIZE/OFF       NODE NAME
systemd   2275 zhangsan  cwd       DIR                8,3      233        128 /
systemd   2275 zhangsan  rtd       DIR                8,3      233        128 /
systemd   2275 zhangsan  txt       REG                8,3  1588952    1067907 /usr/lib/systemd/systemd
systemd   2275 zhangsan  mem       REG                8,3   147064     506448 /usr/lib64/libnl-3.so.200.26.0
```

---

##### 进程号

显示9565号进程所打开的文件

```bash
[zhangsan@localhost ~]$ lsof -p 9565
COMMAND   PID     USER   FD   TYPE DEVICE SIZE/OFF     NODE NAME
write.sh 9565 zhangsan  cwd    DIR    8,3     4096 17425438 /home/zhangsan
write.sh 9565 zhangsan  rtd    DIR    8,3      233      128 /
write.sh 9565 zhangsan  txt    REG    8,3  1150736 50725009 /usr/bin/bash
write.sh 9565 zhangsan  mem    REG    8,3  3167976   431987 /usr/lib64/libc-2.28.so
write.sh 9565 zhangsan  mem    REG    8,3   278504   431980 /usr/lib64/ld-2.28.so
write.sh 9565 zhangsan  mem    REG    8,3      286 50605560 /usr/lib/locale/en_US.utf8/LC_MONETARY
write.sh 9565 zhangsan    0w   CHR    1,3      0t0     2051 /dev/null
write.sh 9565 zhangsan    1w   REG    8,3       28 17425007 /home/zhangsan/nohup.out
write.sh 9565 zhangsan    2w   REG    8,3       28 17425007 /home/zhangsan/nohup.out
write.sh 9565 zhangsan  255r   REG    8,3      101 17424983 /home/zhangsan/write.sh
```

---

##### 端口

查看22端口现在运行的情况

```shell
ls[root@localhost ~]# lsof -i :22
COMMAND  PID     USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
sshd    1102     root    3u  IPv4  28299      0t0  TCP *:ssh (LISTEN)
sshd    1102     root    4u  IPv6  28301      0t0  TCP *:ssh (LISTEN)
sshd    9079     root    3u  IPv4  65146      0t0  TCP localhost.localdomain:ssh->192.168.174.1:50576 (ESTABLISHED)
sshd    9087 zhangsan    3u  IPv4  65146      0t0  TCP localhost.localdomain:ssh->192.168.174.1:50576 (ESTABLISHED)
[root@localhost ~]# lsof -i :3306
COMMAND  PID  USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
mysqld  1743 mysql   21u  IPv6  30634      0t0  TCP *:mysql (LISTEN)
```

