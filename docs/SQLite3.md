---
title: SQLite Python API
date: 2022-03-23 15:55:26
categories:
- SQLite
---



##### 导入sqlite3

```python
import sqlite3
```

##### 创建数据库链接

```python
conn = sqlite3.connect("test.db")
```

##### 获取游标

```python
cursor = conn.cursor()
```

##### 创建表

```python
cursor.execute("create table user(id int primary key, name varchar(20) )")
```

##### 插入数据

- 插入一条数据

```python
cursor.execute('insert into user(id, name) values (1, \'aaa\')')
print(cursor.rowcount)
```

- 插入多条数据

`executemany(sqlstatement, values)`

```python
cursor.executemany('insert into user(id,name) values (?,?)', [(2, 'AAA'), (3, 'BBB')])
print(cursor.rowcount)
```

##### 查询数据

- 条件查询

```python
cursor.execute('select * from user')
```

- 遍历查询结果集

```python
# 移动游标输出结果集中的第一个元组          ( 也可通过next(cursor) )
cursor.__next__()
Out[30]: (1, 'aaa')
    
# 输出结果集中的剩下的元组
cursor.fetchall()
Out[31]: [(2, 'AAA'), (3, 'BBB')]
```

##### 收尾

```python
# 关闭游标
cursor.close()
# 提交事务
conn.commit()
```