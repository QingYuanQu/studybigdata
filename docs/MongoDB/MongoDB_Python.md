---
title: MongoDB Python API
date: 2022-03-23 15:55:26
categories:
- MongoDB
tags:
- MongoDB Python
---

# MongoDB Python API

##### 安装

```shell
pip install pymongo
```

##### 导入

```python
from pymongo import MongoClient
```

##### 连接`MongoDB Server`

```python
client = MongoClient('localhost', 27017)
```

##### 列出所有数据库

```python
client.list_database_names()
```

##### 创建/选择数据库

如果`post_db`不存在，则自动新建此数据库。

```python
post_db = client.get_database('post_db')
```

##### 列出库内所有的集合

```python
post_db.list_collection_names()
```

##### 新建/选择集合

如果`post_collection`不存在，则新建此集合。

```python
post_collection = post_db.get_collection('post_collection')
```

##### 插入一条文档

```python
import datetime
post = {"author": 'zhangsan', 'text': '我的第一篇博客', "tags": ['mongodb', 'python', 'pymongo'],
        "date": datetime.datetime.utcnow()}
post_collection.insert_one(post)
```

##### 查询单条文档

```python
post_collection.find_one()
```

##### 插入多条文档

```python
list = [{'author': 'lisi', "text": 'lisi text'}, {'author': 'wangwu', 'text': 'wangwu text'}]
post_collection.insert_many(list)
```

##### 遍历集合内的文档

```python
for i in post_collection.find():
    print(i)
```



