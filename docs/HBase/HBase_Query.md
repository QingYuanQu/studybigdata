---
title: HBase 数据查询
date: 2022-03-23 15:55:26
categories:
- HBase
tags:
- HBase Shell
- 限定符
- 过滤器
---

# HBase数据查询

## 数据准备

### 创建表

创建`Student`表，两个列族`Info`和`Score`；

```ruby
hbase(main):047:0> create 'Student','Info','Score'
0 row(s) in 2.3500 seconds
```

### 插入数据

批量插入

<table>
   <tr>
      <td rowspan="2">No</td>
      <td colspan="2">Info</td>
      <td colspan="3">Score</td>
   </tr>
   <tr>
      <td>name</td>
      <td>age</td>
      <td>Hadoop</td>
      <td>HBase</td>
      <td>Spark</td>
   </tr>
   <tr>
      <td>001</td>
      <td>qiaofeng</td>
      <td>30</td>
      <td>93</td>
      <td>85</td>
      <td>70</td>
   </tr>
   <tr>
      <td>002</td>
      <td>duanyu</td>
      <td>27</td>
      <td>95</td>
      <td>98</td>
      <td>50</td>
   </tr>
   <tr>
      <td>003</td>
      <td>wangyuyan</td>
      <td>18</td>
      <td>95</td>
      <td>97</td>
      <td>92</td>
   </tr
</table>

##### vim data.sh

```shell
put 'Student','001','Info:name','qiaofeng'
put 'Student','001','Info:age','30'
put 'Student','001','Score:Hadoop','93'
put 'Student','001','Score:Hbase','85'
put 'Student','001','Score:Spark','70'

put 'Student','002','Info:name','duanyu'
put 'Student','002','Info:age','27'
put 'Student','002','Score:Hadoop','95'
put 'Student','002','Score:Hbase','98'
put 'Student','002','Score:Spark','59'

put 'Student','003','Info:name','wangyuyan'
put 'Student','003','Info:age','18'
put 'Student','003','Score:Hadoop','95'
put 'Student','003','Score:Hbase','97'
put 'Student','003','Score:Spark','92'

put 'Student','10','Info:name','xuzhu'
```

```shell
[zhangsan@node1 ~]$ hbase shell data.sh 
```

## 简单查询

### 行

```RUBY
hbase(main):006:0> scan 'Student',STARTROW=>'001',ENDROW=>'003'
ROW                        COLUMN+CELL                                                   
 001                       column=Info:age, timestamp=1668417929087, value=30             
 001                       column=Info:name, timestamp=1668417819932, value=qiaofeng     
 001                       column=Score:Hadoop, timestamp=1668417929366, value=93         
 001                       column=Score:Hbase, timestamp=1668417929388, value=85         
 001                       column=Score:Spark, timestamp=1668417929400, value=70         
 002                       column=Info:age, timestamp=1668417929434, value=27             
 002                       column=Info:name, timestamp=1668417929414, value=duanyu       
 002                       column=Score:Hadoop, timestamp=1668417929448, value=95         
 002                       column=Score:Hbase, timestamp=1668417929463, value=98         
 002                       column=Score:Spark, timestamp=1668417929481, value=50         
2 row(s) in 0.0290 seconds
```

### 列

##### 粒度：列族

```ruby
hbase(main):003:0> get 'Student','001',COLUMN=>'Info'
COLUMN                     CELL                                                           
 Info:age                  timestamp=1668417929087, value=30                             
 Info:name                 timestamp=1668417819932, value=qiaofeng                       
1 row(s) in 0.1410 seconds
```

##### 粒度：列

```ruby
hbase(main):004:0> get 'Student','001',COLUMN=>'Info:name'
COLUMN                     CELL                                                          
 Info:name                 timestamp=1668417819932, value=qiaofeng                      
1 row(s) in 0.0110 seconds
```

### 行列组合

```ruby
hbase(main):007:0> scan 'Student',COLUMN=>'Info',STARTROW=>'001',ENDROW=>'003'
ROW                        COLUMN+CELL                                                   
 001                       column=Info:age, timestamp=1668417929087, value=30             
 001                       column=Info:name, timestamp=1668417819932, value=qiaofeng     
 002                       column=Info:age, timestamp=1668417929434, value=27             
 002                       column=Info:name, timestamp=1668417929414, value=duanyu       
2 row(s) in 0.0180 seconds
```



## 过滤器查询

`get`和`scan`都可以使用过滤器(`Filter`)来设置查询条件。

### 基础知识

#### KV

##### key

##### value



##### family

##### column

##### Qualifier

##### Single

##### Inclusive

### 过滤器语法

`scan/get '表名'，{FILTER=> "过滤器 ( 比较运算符，'比较器')"}`

##### 过滤器

```ruby
hbase(main):078:0> show_filters

RowFilter
PrefixFilter
InclusiveStopFilter


FamilyFilter

QualifierFilter

ColumnPrefixFilter
ColumnRangeFilter
ColumnCountGetFilter

DependentColumnFilter

SingleColumnValueFilter

SingleColumnValueExcludeFilter
FirstKeyOnlyFilter

ValueFilter
TimestampsFilter


MultipleColumnPrefixFilter

PageFilter
KeyOnlyFilter #只返回每个KV的Key的过滤器（value将被重写为空)
ColumnPaginationFilter
```

##### 比较器

| **比较器**             | **描述**         |
| ---------------------- | ---------------- |
| BinaryComparator       | 匹配完整字节数组 |
| BinaryPrefixComparator | 匹配字节数组前缀 |
| BitComparator          | 匹配比特位       |
| NullComparator         | 匹配空值         |
| RegexStringComparator  | 匹配正则表达式   |
| SubstringComparator    | 匹配子字符串     |

##### 比较运算符

| **比较运算符** | **描述** |
| -------------- | -------- |
| =              | 等于     |
| >              | 大于     |
| >=             | 大于等于 |
| <              | 小于     |
| <=             | 小于等于 |
| !=             | 不等于   |



### 过滤器分类

- 行键过滤器

- 列族与列过滤器

- 值过滤器

- 其他过滤器

#### 行键过滤器

##### RowFilter

```ruby
scan 'Student',{FILTER=>"RowFilter(=,'substring:0')"} #行键包含字符0
scan 'Student',{FILTER=>"RowFilter(>,'binary:002')"} # 行键顺序大于002
```

##### PrefixFilter

```ruby
scan 'Student',{FILTER=>"PrefixFilter('002')"} # 行键前缀为002
```

##### KeyOnlyFilter

```ruby
scan 'Student',{FILTER=>"KeyOnlyFilter()"} # 显示所有Key，不显示Value
```

##### FirstKeyOnlyFilter

```ruby
scan 'Student',{FILTER=>"FirstKeyOnlyFilter()"} # 无参.仅返回每行第一KV的滤波器。 此过滤器可用于更有效地执行row计数操作。
# 类似于
count 'Student'
```

##### InclusiveStopFilter

替代`ENDROW`返回终止条件行；显示[001,003)

```ruby
scan 'Student',{STARTROW=>'001',FILTER=>"InclusiveStopFilter('002')"} #包含指定的终止行
#类似于
scan 'Student',{STARTROW=>'001',ENDROW=>'003'}
```



#### 列族过滤器

列族包含字符`Inf`的列；

```ruby
scan 'Student',{FILTER=>"FamilyFilter(=,'substring:Inf')"}
```

筛选`Info`列：

```ruby
scan 'Student',{FILTER=>"FamilyFilter(=,'binary:Score')"}
```

#### 列过滤器

##### 列过滤器

```shell
scan 'Student',{FILTER=>"QualifierFilter(=,'binary:name')"} #等值
scan 'Student',{FILTER=>"QualifierFilter(=,'substring:nam')"} #包含
```

##### 列前缀过滤器

```ruby
scan 'Student',{FILTER=>"ColumnPrefixFilter('H')"}
```

##### 多列前缀过滤器

```ruby
scan 'Student',{FILTER=>"MultipleColumnPrefixFilter('nam','age')"}
```

##### 列区间过滤器

各列的字典序如下：

```ruby
 sorted(['name','age','Hadoop','Spark','HBase'])
 ['HBase', 'Hadoop', 'Spark', 'age', 'name']
```

```ruby
scan 'Student',{FILTER=>"ColumnRangeFilter('S',true,'n',false)"}
ROW                        COLUMN+CELL                                                   
 001                       column=Info:age, timestamp=1668417929087, value=30             
 001                       column=Score:Spark, timestamp=1668417929400, value=70         
 002                       column=Info:age, timestamp=1668417929434, value=27             
 002                       column=Score:Spark, timestamp=1668417929481, value=50         
 003                       column=Info:age, timestamp=1668419546101, value=18             
 003                       column=Score:Spark, timestamp=1668419564352, value=92         
3 row(s) in 0.0120 seconds
```

##### ColumnCountGetFilter 

限制每个逻辑行返回的单元格数

```ruby
scan 'Student',FILTER=>"ColumnCountGetFilter(2)"
```

#### 值过滤器

##### ValueFilter

```ruby
scan 'Student',{FILTER=>"ValueFilter(=,'binary:98')"}
```

```ruby
scan 'Student',{FILTER=>"ValueFilter(=,'substring:9')"}
```

##### SingleColumnValueFilter

注意：没有`Hbase`这列的逻辑行也会被匹配到。

```ruby
scan 'Student',{FILTER=>"SingleColumnValueFilter('Score','Hbase',=,'binary:85')"}
```

```ruby
scan 'Student',{FILTER=>"SingleColumnValueFilter('Score','Hbase',=,'binary:85',True,True)"}
```

#### 时间戳过滤器

##### TimestampsFilter

只查询时间戳为`1649129478746`和`1649129465737`的键值对；

```ruby
scan 'Student',{FILTER=>"TimestampsFilter(1649129478746,1649129465737)"}
```

#### 其他过滤器

##### **PageFilter** 

基于行的分页过滤器，设置返回行数。

```ruby
scan 'Student',FILTER=>"PageFilter(2)"
```
