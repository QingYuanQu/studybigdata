---
title: Web Framework
date: 2023-06-24 19:14:00
categories:
- Python
tags:
- Web Framework
---

# Django

## 官网案例

https://docs.djangoproject.com/zh-hans/4.2/intro/



## 投票程序

自定义一个投票问题：

- 自定义一个问题`Question`，如：为他/投一票（仅供娱乐）

- 将学生信息表.xlsx导入作为`Choice`

```python
import sqlite3
import pandas as pd


# 链接数据库
conn = sqlite3.connect("db.sqlite3")
cursor = conn.cursor()

# 查询数据
cursor.execute('select * from polls_choice')

students = pd.read_excel("20-3.xlsx") # 读取学生信息表

students_list = []
for stu in students["姓名"]: #对姓名列操作，组合成三元组 (姓名,投票数,所属问题ID)
    record = (stu, 0, 2)
    students_list.append(record) # 将所有三元组放入列表

 
# 插入数据库（多条）
cursor.executemany('insert into polls_choice(choice_text,votes,question_id) values (?,?,?)', students_list)

# 关闭游标
cursor.close()
# 提交事务
conn.commit()
```

