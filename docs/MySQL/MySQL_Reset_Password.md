---
title: MySQL密码重置
date: 2022-03-23 15:55:26
categories:
- MySQL
---

# 1. 无密码登录配置

修改MySQL配置文件my.ini (C:\ProgramData\MySQL\MySQL Server 5.7\my.ini )

追加如下行：

```shell
skip-grant-tables = true
```

作用是使其再次启动时跳过授权表，也就是不用密码就可以登录。

# 2. 重新启动MySQL

 +  第一种方法：可通过命令重启（cmd需要使用管理员执行）

```shell
C:\WINDOWS\system32>net stop mysql57
MySQL57 服务正在停止.
MySQL57 服务已成功停止。
```

+ 第二种方法：可通过 【控制面板 - 系统安全 - 管理工具 - 计算机管理 - 服务和应用程序 - 服务 - MySQL57 - 重启服务】 ，手动重启MySQL服务。

这时，不用密码就可以登录MySQL了。

# 2. 更换密码

```sql
C:\Program Files\MySQL\MySQL Server 5.7\bin>mysql -uroot -p
Enter password:
# 让你输入密码的时候，不用理它，直接回车。

# 选择mysql库
mysql>use mysql;

# 更换密码为123456
update user set authentication_string=password('123456') where user='root' and Host='localhost';
```

# 3. 刷新权限
```shell
flush privileges;
```

# 4. 关闭无密码登录

 删除第一步在配置文件`my.ini`中添加的

```skip-grant-tables = true```

# 5. 重新启动MySQL



重启MySQL的目的是为了让配置文件修改生效。
