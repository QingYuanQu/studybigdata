---
title: Linux用户管理
date: 2023-01-14 15:55:26
categories:
- Linux
tags:
- Linux用户管理
marp: true
---

## 用户管理

### 查看当前登录用户

```shell
# whoami
```

### 查询用户信息

```shell
# 查询用户信息
[root@localhost ~]# id zhangsan
uid=1000(zhangsan) gid=1000(zhangsan) groups=1000(zhangsan)
```

### 切换用户

```shell
# Switch user
su zhangsan : 切换为张三用户
```

```shell
# Switch user
su - zhangsan : 切换为张三用户，并进入张三的用户目录
```

### 用户添加删除 - root

**以下命令使用root账号操作**

```shell
# 增加用户lisi
[root@Honor ~]# useradd lisi # 增加用户 lisi  注意：此处‘#’号表示root权限，当前登录用户为root
[root@Honor ~]# passwd lisi  # 为新增用户lisi设置密码
Changing password for user lisi.
New password:
BAD PASSWORD: The password is shorter than 8 characters
Retype new password:
passwd: all authentication tokens updated successfully.

# 切换到lisi用户
[root@Honor ~]# su lisi  # 切换到用户lisi

[lisi@Honor root]$ cd ~  # 进入用户lisi的Home目录  注意：此处'$'号表示当前登录用户为普通用户，用户为'lisi'
[lisi@Honor ~]$ pwd   # 查看当前用户的工作目录
/home/lisi


# 删除用户lisi
[lisi@Honor ~]$ userdel -r lisi  #当前登录用户是lisi，删除用户lisi，删除失败，提示lisi正在36号进程登录。
userdel: user lisi is currently used by process 36
[lisi@Honor ~]$ exit #lisi退出登录
exit
[root@Honor ~]# userdel -r lisi  # 当前登录用户为root，删除用户lisi
```

### 修改密码 - 普通用户

```shell
# 使用passwd命令修改个人密码
[zhangsan@aliyunecs ~]$ passwd
Changing password for user zhangsan.
# 输入当前密码
Current password: 
# 让你输入新密码
New password: 
# 提示你输入的新密码和旧密码一样了
BAD PASSWORD: The password is the same as the old one
passwd: Authentication token manipulation error

# 再次修改密码
[zhangsan@aliyunecs ~]$ passwd
Changing password for user zhangsan.
Current password: 
New password:
# 提示新密码中包含用户名
BAD PASSWORD: The password contains the user name in some form
passwd: Authentication token manipulation error

# 再次修改密码
[zhangsan@aliyunecs ~]$ passwd
Changing password for user zhangsan.
Current password: 
New password: 
# 提示你密码太短，低于8个字符了
BAD PASSWORD: The password is shorter than 8 characters
passwd: Authentication token manipulation error

#如忘记个人密码，找root重置密码
```

### 授权普通用户执行root指令

在linux系统下，普通用户无法直接执行root用户权限下的命令，如果想让普通用户执行只有root用户才能执行的操作命令，就需要用到sudo，需要修改/etc/sudoers文件。

**sudo 以其他用户身份执行命令**

1. 切换为`root`用户

```shell
[lisi@localhost ~]$ su root
Password: 
```

2. 查看相关文件详细信息  `/etc/sudoers`

```shell
[root@localhost ~]# ls -al /etc/sudoers
-r--r-----. 1 root root 4328 Oct 25 19:45 /etc/sudoers
#可以看到 即使是root用户，仍然没有修改权限
```

3. 为`/etc/sudoers`增加修改权限

```shell
[root@localhost ~]# chmod u+w /etc/sudoers
[root@localhost ~]# ll -al /etc/sudoers
-rw-r-----. 1 root root 4328 Oct 25 19:45 /etc/sudoers #此时文件所有者root用户有了w权限
```

4. 此时可以修改`/etc/sudoers`文件了，找到文件大约第100行的位置；

```shell
 99 ## Allow root to run any commands anywhere 
100 root    ALL=(ALL)       ALL
101 
```

5. 仿照第100行，增加李四用户，如下图，保存退出。

```shell
 99 ## Allow root to run any commands anywhere 
100 root    ALL=(ALL)       ALL
101 lisi        ALL=(ALL)       ALL
```

6. 此时`lisi`用户便有了管理员权限。

```shell
# 李四用户使用sudo，便可修改/etc/sudoers文件了，即使该文件的所有者所属组都是root
[lisi@localhost ~]$ sudo vim /etc/sudoers # 如果前面没有使用sudo，lisi无法修改该文件
[lsii@localhost ~]$ sudo vim /etc/sudoers

We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for lisi: 
```

7. 安全起见，此时可以把`/etc/sudoers`的权限修改回去 `u-w`



##### 发工资案例

-   工资账本`salary.csv`由`root`创建，存放在` /opt/`目录中；
-   提升 `zhangsan` 用户为会计，负责工资的发放，让其能够修改` /opt/salary` 账本文件；

```python
###### root ######
[root@localhost opt]# pwd
/opt
[root@localhost opt]# touch salary.csv
[root@localhost opt]# ll
total 0
drwxr-xr-x. 2 root root 6 Oct 30  2018 rh
-rw-r--r--. 1 root root 0 Apr 10 18:30 salary.csv
[root@localhost opt]# 
[root@localhost opt]# vim salary.csv  
# 如增加 2024-04-11,user1,5000

####### 张三 ######
[zhangsan@localhost ~]$ cd /opt/
# 可以看到，salary.csv的所有者是root
[zhangsan@localhost opt]$ ll
total 4
drwxr-xr-x. 2 root root  6 Oct 30  2018 rh
-rw-r--r--. 1 root root 19 Apr 10 18:30 salary.csv

# 张三无法修改此文件
[zhangsan@localhost opt]$ vim /opt/salary.csv

###### root ######
# 切换到root，将zhangsan加入sudoers名单
[root@localhost ~]# vim /etc/sudoers
# 新增一行
zhangsan        ALL=(ALL)       ALL

####### 张三 ######
# 此时张三便可以使用sudo来修改salary.csv文件了
[zhangsan@localhost opt]$ sudo vim /opt/salary.csv

We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for zhangsan: 
 

```



### 用户组管理

#### 增加用户组

```shell
[root@localhost ~]# groupadd group_1
[root@localhost ~]# tail -2 /etc/group
zhangsan:x:1002:
# 新增的用户组
group_1:x:1004:
```

#### 用户加入用户组

    usermod ：modify a user account
    -a, --append
           Add the user to the supplementary(额外的) group(s). Use only with the -G option.

```shell
# 第一种方法，将zhangsan加入到group_1中
[root@localhost ~]# usermod -a -G group_1 zhangsan
# 第二种方法，将lisi加入到group_1中
[root@localhost ~]# gpasswd -a lisi group_1
Adding user lisi to group group_1


# 查看组group_1内有两个用户 zhangsan, lisi
[root@localhost ~]# tail -2 /etc/group
zhangsan:x:1002:
group_1:x:1004:zhangsan,lisi
```

#### 用户组内移除用户

```shell
# 使用sudo提升权限，移除成功
[root@localhost ~]$ gpasswd -d lisi group_1
Removing user lisi from group group_1

# 查看组内成员，发现group_1组内仅剩zhangsan
[root@localhost ~]$ sudo tail -n 2 /etc/group
lisi:x:1002:
group_1:x:1012:zhangsan
```

#### 删除用户组

```shell
[zhangsan@localhost ~]$ sudo groupdel group_1
[zhangsan@localhost ~]$ sudo tail -n 5 /etc/group
devgroup:x:1003:
depart1:x:1004:
depart2:x:1010:
depart3:x:1011:
lisi:x:1002:
```

### 用户历史操作

 history会列出所有使用过的命令并加以编号。这些信息被存储在用户主目录的`~/.bash_history`文件中，这个文件默认情况下可以存储1000条命令记录。

##### 查看最近10条命令

```shell
[zhangsan@localhost ~]$ history 10
  396  sudo groupdel group_1
  397  sudo tail -n 5 /etc/group
  398  sudo tail -n 10 /etc/group
  399  ll
  400  more /etc/sudoers
  401  sudo more /etc/sudoers
  402  sudo less /etc/sudoers
  403  sudo more /etc/sudoers
  404  history
  405  history 10
```

##### 执行第399条命令

```shell
[zhangsan@localhost ~]$ !399
ll
total 24
-rw-r--r--. 1 root     root     25 Oct 18 06:58 3days.txt
-rw-rw-r--. 1 zhangsan zhangsan 25 Oct 18 18:04 3.txt
-r---w----. 1 zhangsan zhangsan 57 Oct 18 06:54 days
-r--------. 1 root     root     57 Oct 18 20:09 days_copy
drwxr-xr-x. 2 zhangsan zhangsan  6 Oct 11 18:07 Desktop
drwxr-xr-x. 2 root     root      6 Oct 18 20:06 dir1
drwxr-xr-x. 2 zhangsan zhangsan  6 Oct 11 18:07 Documents
drwxr-xr-x. 2 zhangsan zhangsan  6 Oct 11 18:07 Downloads
-rwx------. 1 zhangsan zhangsan 33 Oct 18 18:27 hello.sh
-rw-rw-r--. 1 zhangsan zhangsan  5 Oct 18 17:55 ls_out
drwxr-xr-x. 2 zhangsan zhangsan  6 Oct 11 18:07 Music
drwxr-xr-x. 2 zhangsan zhangsan  6 Oct 11 18:07 Pictures
drwxr-xr-x. 2 zhangsan zhangsan  6 Oct 11 18:07 Public
drwxr-xr-x. 2 zhangsan zhangsan  6 Oct 11 18:07 Templates
drwxrwxr-x. 3 zhangsan zhangsan 19 Oct 18 20:10 test
drwxr-xr-x. 2 zhangsan zhangsan  6 Oct 11 18:07 Videos
drwxrwxr-x. 2 zhangsan zhangsan 53 Oct 11 18:25 zsdir
```

##### 清空历史操作

```shell
[zhangsan@localhost ~]$ history -c
[zhangsan@localhost ~]$ history
    1  history
```





---





### 密码影子shadow

| 字段 | 说明                                                         |
| ---- | ------------------------------------------------------------ |
| 1    | 用户账号名称，如root                                         |
| 2    | 用户加密后的口令。如果该字段的值为“!!”和“*”，则表示该用户当前没有密码，也不能登录系统，这些用户通常是标准账号。  其他的用户密码都是经过MD5加密后的内容。另外，用户任何时候都不能通过直接修改该字段的方法，来更变用户口令 |
| 3    | 由1970年1月1号算起，到最后一次修改密码的时间间隔（以日为单位） |
| 4    | 密码自上次修改后，要间隔多少天数后才能再次被修改，如果为0则无限制 |
| 5    | 密码自上次修改后，最多间隔多少天数后密码必须被修改           |
| 6    | 如果密码有时间限制，那么在过期前多少天向用户发出警告，默认为7天 |
| 7    | 如果密码设置为必须修改，到期后仍未修改，系统自动关闭账号的天数 |
| 8    | 从1970年1月1号算起，到账号过期的天数                         |
| 9    | 系统保留，尚未使用                                           |

```shell
# 现在距离1970.1.1日共19829天，wangwu的密码设置为至少3天一更新
# 王五的密码是5天前更新的。
1      ：                 2                 ：  3    ：4 ：5    : 6: 7 : 8 : 9
wangwu : $1$cd1m5G0O$FqMmi0icYyPa6hoI6HCUE/ : 19824 : 0 : 3    : 7:  :    :
user2  : $1$AjOvyxXg$JYVXD8rvQtVW6ONtc8gES. : 19829 : 1 : 99999: 7:  :    :
```

![1713242419787](./img/Linux_08_%E7%94%A8%E6%88%B7%E7%AE%A1%E7%90%86/1713242419787.png)



### setuid

##### shadow文件

<pre>[root@localhost zhangsan]# ls -al /etc/shadow
----------. 1 root root 1291 Apr 15 21:37 <span style="background-color:#FF0000"><font color="#EEEEEC">/etc/shadow</font></span>
</pre>


shadow文件的权限是000，普通用户别说写了，连看都看不到这个文件，**但是普通用户可以更改自己的密码，把密码写入了/etc/shadow这个文件，** 普通用户明明对他没有权限，怎么可能写入这个文件的呢？



##### passwd命令

<pre>[root@localhost zhangsan]# ls -al /usr/bin/passwd
-rwsr-xr-x. 1 root root 27856 Mar 31  2020 <span style="background-color:#FF0000"><font color="#EEEEEC">/usr/bin/passwd</font></span>
</pre>


因为这个`passwd`这条命令作用的，当普通用户执行`passwd`这条命令的时候，**因为passwd有SetUID权限。 任何普通用户在执行这条命令的时候，都暂时性地获得这个文件的所有者权限。**

普通用户在执行`passwd`命令的时候，系统没有把他当作普通用户来对待，而是当作`超级用户`来对待，超级用户对shadow文件拥有任何权限，虽然shadow文件的权限是000，这个权限对超级用户是没有意义的，超级用户对这个文件依然有rwx权限。

>   https://blog.csdn.net/weixin_44657888/article/details/128785535

### 用户管理

#### useradd

```bash
# 新增用户
[root@localhost zhangsan]# useradd user3 -d /opt/user3 -s /bin/bash -c "user3's account" -g 1002

# 用户的主目录
[root@localhost zhangsan]# ls /opt/
rh  salary.csv  user3

# 用户的个人信息
[root@localhost zhangsan]# tail -n 1 /etc/passwd
user3:x:1003:1002:user3's account:/opt/user3:/bin/bash

# 用户的所属组
[root@localhost zhangsan]# id user3
uid=1003(user3) gid=1002(bigdata) groups=1002(bigdata)
```



#### passwd

`-l` ：锁定密码，不许用户登录系统。

```shell
# 查看zhangsan的密码
[root@localhost ~]# cat /etc/shadow |grep zhangsan
zhangsan:$1$VL4C6Fg0$EXd.i7dNZr8I8FvMCsXLd1:19829:0:99999:7:::

# root用户锁定zhangsan的密码
[root@localhost ~]# passwd -l zhangsan
Locking password for user zhangsan.
passwd: Success

#######################
#  张三用户无法登录系统  #
#######################

# 再次查看zhangsan的密码
[root@localhost ~]# cat /etc/shadow |grep zhangsan
zhangsan:!!$1$VL4C6Fg0$EXd.i7dNZr8I8FvMCsXLd1:19829:0:99999:7:::
# 可以发现密码前多了两个!


# 使用root用户解锁zhangsan的密码
[root@localhost ~]# passwd -u zhangsan
Unlocking password for user zhangsan.
passwd: Success

#######################
#  张三用户可以登录系统  #
#######################

# 再次查看zhangsan的密码
[root@localhost ~]# cat /etc/shadow |grep zhangsan
zhangsan:$1$VL4C6Fg0$EXd.i7dNZr8I8FvMCsXLd1:19829:0:99999:7:::
```



##### 设置密码时，显示密码内容

```python
[root@localhost zhangsan]# passwd --stdin zhangsan
Changing password for user zhangsan.
12345677
passwd: all authentication tokens updated successfully.

```



#### chfn

##### 修改用户信息

```bash
[root@localhost zhangsan]# chfn
Changing finger information for root.
Name [root]: 
Office []: uzz
Office Phone []: 12345
Home Phone []: 123456

Finger information changed.

```

##### 查看用户信息

```bash
[root@localhost zhangsan]# cat /etc/passwd |grep root
root:x:0:0:root,uzz,12345,123456:/root:/bin/bash
```



#### who

查看当前登录的用户

```shell
[root@localhost ~]# who
zhangsan :0           2024-04-16 00:37 (:0)
zhangsan pts/0        2024-04-16 00:37 (:0)
zhangsan pts/1        2024-04-22 21:46 (192.168.174.1)
```



#### finger

查看用户信息

```shell
# yum -y install finger
```

```shell
[root@localhost ~]# finger zhangsan
Login: zhangsan       			Name: zhangsan
Directory: /home/zhangsan           	Shell: /bin/bash
On since Tue Apr 16 00:37 (PDT) on :0 from :0 (messages off)
#zhangsan 从 Tue Apr 16 00:37 开始登录，并且是在本地控制台（:0）上登录的。(messages off) 表示消息通知是关闭的。

On since Tue Apr 16 00:37 (PDT) on pts/0 from :0
   1 minute 38 seconds idle

# zhangsan 从 Tue Apr 16 00:37 开始登录，并且是在本地控制台（:0）上登录的。(messages off) 表示消息通知是关闭的。
# 自从上次活动以来，用户已经空闲了 1 minute 38 seconds。

On since Mon Apr 22 21:46 (PDT) on pts/1 from 192.168.174.1
   2 seconds idle
# zhangsan 在 Mon Apr 22 21:46 从 IP 地址 192.168.174.1 在 pts/1 上登录。
# 自上次活动以来，这个会话已经空闲了 2 seconds。
No mail.
No Plan.

```



### 在登录的用户间传递消息

#### 广播

```shell
# 张三允许其他人向自己发消息
[zhangsan@localhost ~]$ mesg
is y
```



```shell
# root向外广播
[root@localhost ~]# wall
hello world

Broadcast message from root@localhost.localdomain (pts/1) (Mon Apr 15 05:02:52 2024):

hello world

```

>   `Ctrl+D`结束消息发送。



```bash
# 张三收到消息
[zhangsan@localhost ~]$ 
Broadcast message from root@localhost.localdomain (pts/1) (Mon Apr 15 05:02:52 2024):

hello world
[zhangsan@localhost ~]$
```

#### 向某用户

```shell
# root向张三发送消息
[root@localhost ~]# write zhangsan
hello
world
```



```shell
# zhangsan接收到root发过来的消息
[zhangsan@localhost ~]$ hello
[zhangsan@localhost ~]$ world
[zhangsan@localhost ~]$ 
```



### 用户管理练习

1. 切换到`root`用户;
1. 新增一个用户，用户名为`姓名全拼-new`，为其设置密码；
1. 新增一个用户组，组名为`linux-study`；
1. 将新用户加入到用户组内；
1. 将新用户从用户组内移除；
1. 修改用户的个人信息；Name为中文姓名；homePhone为你的手机号；
1. 查看passwd文件中的个人信息。

### 权限管理练习

-   使用`root`用户，在`opt`目录创建目录`salary`， 并在目录内创建文件`salary-01.csv`
-   查看`salary`的权限信息；
-   将目录`salary`的所有者和所属组变更为`姓名全拼-new`
-   切换到用户`姓名全拼-new`
-   赋予所有者`读写`权限；赋予所属组`读`权限；赋予其他人`空`权限。
-   此时，尝试进入`salary`目录， 打印提示信息。
-   根据提示信息重新调整权限，让所有者能够进入`salary`目录；
-   调整权限后，所有者进入`salary`目录，在`salary-01.csv`中插入一行文本，文本内容为`姓名全拼-new  01  10000`
-   如插入失败，思考失败原因，并进行修复；

