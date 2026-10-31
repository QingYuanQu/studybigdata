---
title: kettle - 数据清理之字符串清理
date: 2022-10-20 09:55:26
categories:
- Kettle
---

# Kettle - 数据清理之字符串清理

## 实验数据

**城市区号表**

![image-20221020192332164](img/Kettle_Clean_String/image-20221020192332164.png)

### 数据存在的问题

1. `ID`字段前后存在空白字符
2. `CODE`为区号，有的记录没有以`0`开始，有的记录中存在`非零字符`
3. `CITY`字段大小写未统一，全部修改为大写字母，去掉前面的缩写。

## 转换设计

![image-20221020193059238](img/Kettle_Clean_String/image-20221020193059238.png)

## 自定义常量步骤

元数据如下，具体数据见实验数据。

![image-20221020193026424](img/Kettle_Clean_String/image-20221020193026424.png)

### 字符串操作步骤

![image-20221020193451281](img/Kettle_Clean_String/image-20221020193451281.png)

1. ID列去掉前后空白字符
2. CODE列只保留数字
3. CITY列转为大写

### 字符串替换步骤

![image-20221020193636187](img/Kettle_Clean_String/image-20221020193636187.png)

### 剪切字符串步骤

![image-20221020193746206](img/Kettle_Clean_String/image-20221020193746206.png)

## 清理结果

![image-20221020193827056](img/Kettle_Clean_String/image-20221020193827056.png)