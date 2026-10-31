---
title: MySQL Remote Connection
categories:
- MySQL
Tages:
- MySQL Reomte Connection
---

### MySQL 授权 root 用户远程访问
#### 1. 切换到 mysql 系统数据库
```sql
mysql> use mysql;
Database changed
```
- 作用：`mysql` 库是 MySQL 存储用户账户、权限等核心信息的系统数据库，修改用户权限必须先切换到该库；

#### 2. 修改 root 用户的访问主机限制
```sql
mysql> update user set host='%' where user='root';
Query OK, 0 rows affected (0.01 sec)
Rows matched: 1  Changed: 0  Warnings: 0
```
- `user` 表：存储 MySQL 用户信息的核心表，
- `host` 字段控制该用户允许从哪个主机访问（默认 `localhost` 仅允许本地访问）；
- `host='%'`：`%` 是通配符，表示允许**任意 IP 地址/主机**访问；

#### 3. 刷新权限使修改生效
```sql
mysql> flush privileges;
Query OK, 0 rows affected (0.01 sec)
```
#### 4. 验证修改结果
```sql
mysql> select user,host from mysql.user where user='root';
+------+------+
| user | host |
+------+------+
| root | %    |
+------+------+
1 row in set (0.00 sec)
```
- 结果确认：输出中 `host` 列显示 `%`，说明 root 用户已允许从任意远程主机访问。

### 关键注意事项
1. **安全风险**：`host='%'` 允许所有主机访问 root 用户，**仅适合测试/开发环境**；生产环境建议指定具体可访问的 IP（如 `192.168.1.100`），降低被攻击风险；
2. **防火墙/端口放行**：即使修改了数据库权限，若服务器防火墙未放行 MySQL 默认端口（3306），远程仍无法访问，需同步配置防火墙；
3. **权限生效范围**：修改后无需重启 MySQL 服务，`flush privileges` 已确保即时生效；
4. **多 root 记录**：若 `mysql.user` 表中有多个 root 记录（如 host 分别为 `localhost`、`127.0.0.1`），需确保所有 root 记录的 host 都改为目标值，或删除多余记录。

### 总结
1. 核心操作是修改 `mysql.user` 表中 root 用户的 `host` 字段为 `%`，并刷新权限，实现 root 用户远程访问；
2. `host='%'` 是任意主机访问的通配符，测试环境可用，生产环境需限制具体 IP；
3. 权限修改后必须执行 `flush privileges` 才能生效，且需确保服务器端口/防火墙放行 3306 端口。