---
title: MySQL调整密码策略
description: Your password does not satisfy the current policy requirements
categories:
- MySQL
---



## 调整密码策略

### 操作说明：MySQL 密码验证规则调整
**降低密码复杂度验证规则**，方便设置更简单的数据库密码（比如纯数字、短长度密码）：

#### 1. 查看当前密码验证规则

查询 MySQL 中与密码验证相关的所有配置项

```sql
mysql> SHOW VARIABLES LIKE 'validate_password%';
+--------------------------------------+--------+
| Variable_name                        | Value  |
+--------------------------------------+--------+
| validate_password_check_user_name    | OFF    |
| validate_password_dictionary_file    |        |
| validate_password_length             | 8      |
| validate_password_mixed_case_count   | 1      |
| validate_password_number_count       | 1      |
| validate_password_policy             | MEDIUM |
| validate_password_special_char_count | 1      |
+--------------------------------------+--------+
7 rows in set (0.00 sec)
```
- `validate_password_policy=MEDIUM`：密码策略为中等（要求包含大小写字母、数字、特殊字符）；
- `validate_password_length=8`：密码最小长度为 8；
- `mixed_case_count=1`/`number_count=1`/`special_char_count=1`：分别要求至少 1 个大小写字母、1 个数字、1 个特殊字符。

#### 2. 降低密码验证策略级别
```sql
mysql> set global validate_password_policy=0;
Query OK, 0 rows affected (0.00 sec)
```
- 作用：将密码策略从 `MEDIUM`（中等）改为 `LOW`（低），0 对应 LOW 级别（仅验证密码长度，不强制字符类型）；
- 提示：`Query OK` 表示命令执行成功，无报错。

#### 3. 缩短密码最小长度
```sql
mysql> set global validate_password_length=6;
Query OK, 0 rows affected (0.00 sec)
```
- 作用：将密码最小长度从 8 位改为 6 位，允许设置更短的密码；

#### 4. 验证修改结果
```sql
mysql> SHOW VARIABLES LIKE 'validate_password%';
+--------------------------------------+-------+
| Variable_name                        | Value |
+--------------------------------------+-------+
| validate_password_check_user_name    | OFF   |
| validate_password_dictionary_file    |       |
| validate_password_length             | 6     |
| validate_password_mixed_case_count   | 1     |
| validate_password_number_count       | 1     |
| validate_password_policy             | LOW   |
| validate_password_special_char_count | 1     |
+--------------------------------------+-------+
7 rows in set (0.00 sec)
```
- `validate_password_policy` 变为 `LOW`，`validate_password_length` 变为 6；
- 注意：`mixed_case_count`/`number_count`/`special_char_count` 仍为 1，但 LOW 策略下这些规则会失效，无需强制满足。

### 关键注意事项
1. 修改后的配置**仅对当前 MySQL 实例生效**，重启数据库后会恢复默认值；若需永久生效，需修改 MySQL 配置文件（如 `my.cnf`/`my.ini`），添加：
   ```ini
   validate_password_policy=0
   validate_password_length=6
   ```
2. 低密码策略仅适合**测试/开发环境**，生产环境建议保留 MEDIUM 或 HIGH 策略，避免密码泄露风险；
3. 修改全局变量后，新建会话（重新登录 MySQL）才能看到生效后的规则。

### 总结
1. 核心操作是通过 `set global` 调整密码验证策略（`validate_password_policy`）和最小长度（`validate_password_length`），降低密码复杂度要求；
2. LOW 策略下仅验证密码长度，无需强制包含大小写、数字、特殊字符，适合测试环境快速设置简单密码；
3. 生产环境需谨慎使用低策略，且建议通过配置文件永久生效，避免重启后规则还原。

