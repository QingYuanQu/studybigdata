---
title: kettle - 数据清理之字段清理
date: 2022-10-20 09:55:26
categories:
- Kettle
---

# kettle - 数据清理之字段清理

## 拆分字段成多行

### 实验数据

![image-20221020201442539](img/Kettle_Clean_Field/image-20221020201442539.png)

![image-20221020200813510](img/Kettle_Clean_Field/image-20221020200813510.png)

### 预览结果

![image-20221020200934300](img/Kettle_Clean_Field/image-20221020200934300.png)

## 拆分字段

### 实验数据

与拆分字段成多行使用同一份实验数据

![image-20221020201442539](img/Kettle_Clean_Field/image-20221020201442539.png)

### 步骤配置

![image-20221020201534960](img/Kettle_Clean_Field/image-20221020201534960.png)

### 实验结果

![image-20221020201809064](img/Kettle_Clean_Field/image-20221020201809064.png)

## 合并字段

### 实验要求

合并 `城市A`,  `城市B`,  `城市C`,  `城市D`为一列，列名命名为`城市列表`。

### 实验数据

上一个步骤的输出数据

![image-20221020201809064](img/Kettle_Clean_Field/image-20221020201809064.png)

### 步骤配置

![image-20221020202207295](img/Kettle_Clean_Field/image-20221020202207295.png)

### 实验结果

![image-20221020202236517](img/Kettle_Clean_Field/image-20221020202236517.png)

## 字段选择

### 实验要求

1. `Sex`列重命名为`性别`，并移动到`Name`后
2. 删除`Age`列
3. `Birth`列的日期格式调整为`yyyy-MM-DD`
4. `Salary`列保留两位小数

### 实验数据

![image-20221020203709168](img/Kettle_Clean_Field/image-20221020203709168.png)

![image-20221020203728111](img/Kettle_Clean_Field/image-20221020203728111.png)

### 步骤配置

##### `Sex`列重命名为`性别`，并移动到`Name`后

![image-20221020203828987](img/Kettle_Clean_Field/image-20221020203828987.png)

##### 删除`Age`列

![image-20221020203845244](img/Kettle_Clean_Field/image-20221020203845244.png)

##### `Birth`列的日期格式调整为`yyyy-MM-DD` 且 `Salary`列保留两位小数

![image-20221020203917894](img/Kettle_Clean_Field/image-20221020203917894.png)

### 实验结果

![image-20221020203645044](img/Kettle_Clean_Field/image-20221020203645044.png)