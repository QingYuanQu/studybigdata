---
title: HBase_Shell 练习
date: 2022-03-23 15:55:26
categories:
- HBase
tags:
- HBase Shell
- 限定符
- 过滤器
---

# HBase 练习

##### 查看HBase版本

```shell
hbase(main):033:0> version
1.4.13, r38bf65a22b7e9320f07aeb27677e4533b9a77ef4, Sun Feb 23 02:06:36 PST 2020
```

##### 集群状态

```shell
hbase(main):034:0> status
1 active master, 0 backup masters, 1 servers, 0 dead, 4.0000 average load
```

##### 创建`Teacher`表，包含一个列族`Info` 

```ruby
hbase(main):041:0> create 'Teacher','Info'
0 row(s) in 2.3430 seconds
```

##### 创建`Student`表，两个列族`Info`和`Score`；列族`Info`的数据在读取时关闭缓存`BLOCKCACHE`。列族`Score`内的数据保留2个版本`VERSIONS`

```ruby
hbase(main):047:0> create 'Student',{NAME=>'Info',BLOCKCACHE=>'false'},{NAME=>'Score',VERSIONS=>2}
0 row(s) in 2.3500 seconds
```

##### 查看`Student`表结构

```ruby
hbase(main):048:0> desc 'Student'
Table Student is ENABLED                                                                                                                                                 
Student                                                                                                                                                                  
COLUMN FAMILIES DESCRIPTION                                                                                                                                              
{NAME => 'Info', BLOOMFILTER => 'ROW', VERSIONS => '1', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSION
 => 'NONE', MIN_VERSIONS => '0', BLOCKCACHE => 'false', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}                                                                  
{NAME => 'Score', BLOOMFILTER => 'ROW', VERSIONS => '2', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSIO
N => 'NONE', MIN_VERSIONS => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}                                                                  
2 row(s) in 0.0260 seconds
```

##### 查看`HBase`中已有的表

```ruby
hbase(main):049:0> list
TABLE                                                                     
Student                                                         
Teacher                                                
2 row(s) in 0.0240 seconds
=> ["Student", "Teacher"]
```

##### 禁用表`Teacher`

```ruby
hbase(main):050:0> disable 'Teacher'
```

##### 判断表`Teacher`是否被禁用

```shell
hbase(main):051:0> is_disabled 'Teacher'
true                         
```

##### 删除表`Teacher`

```ruby
hbase(main):052:0> drop 'Teacher'
```

##### 判断表`Teacher`是否还存在

```ruby
hbase(main):053:0> exists 'Teacher'
Table Teacher does not exist
```

##### 修改`Student`表，列族` Score` 内的数据保留`3`个版本

查看表结构，验证是否修改成功。

```ruby
hbase(main):054:0> alter 'Student',{NAME=>'Score',VERSIONS=>3}
Updating all regions with the new schema...
1/1 regions updated.
Done.
```

##### 修改`Student`表，增加一个列族`hobby`

查看表结构，验证是否修改成功。

```ruby
hbase(main):055:0> alter 'Student','hoby'
Updating all regions with the new schema...
0/1 regions updated.
1/1 regions updated.
```

##### 修改`Student`表，删除列族`hobby`

查看表结构，验证是否修改成功。

```shell
hbase(main):057:0> alter 'Student',{NAME=>'hobby',METHOD=>'delete'}
Updating all regions with the new schema...
1/1 regions updated.
Done.
```

##### 期末考试

将以下同学的期末考试成绩存入`Student`表，然后查询全表。

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
put 'Student','002','Score:Spark','50'

put 'Student','003','Info:name','wangyuyan'
put 'Student','003','Info:age','18'
put 'Student','003','Score:Hadoop','95'
put 'Student','003','Score:Hbase','97'
put 'Student','003','Score:Spark','92'
```

```shell
hbase(main):077:0> scan 'Student'
```



##### 补考

段誉补考了一次`Spark`，老师给登记了`55`分。

```ruby
hbase(main):080:0> put 'Student','002','Score:Spark','55'
```

段誉登录学校教务系统，查询一下`个人信息和成绩`

```ruby
hbase(main):083:0> get 'Student','002'
COLUMN                                      CELL
 Info:age                                   timestamp=1648555981987, value=27
 Info:name                                  timestamp=1648555873577, value=duanyu
 Score:Hadoop                               timestamp=1648556200639, value=95 
 Score:Hbase                                timestamp=1648556226943, value=98  
 Score:Spark                                timestamp=1648556643468, value=55  
1 row(s) in 0.0170 seconds
```

后来段誉动了歪脑筋，托关系走后门，获得了一次补考机会。结果事与愿违，老师登记补考成绩`56`分。

```ruby
hbase(main):082:0> put 'Student','002','Score:Spark','56'
```

段誉又去查询了一下`个人成绩`

```ruby
hbase(main):084:0> get 'Student','002','Score'
COLUMN                                      CELL                   
 Score:Hadoop                               timestamp=1648556200639, value=95      
 Score:Hbase                                timestamp=1648556226943, value=98
 Score:Spark                                timestamp=1648556808780, value=56
1 row(s) in 0.0180 seconds
```

没错，又挂了。

##### 重修

经过两次补考，认真重修了`Spark`，最终老师批阅试卷，登记了`98`分

```ruby
hbase(main):085:0> put 'Student','002','Score:Spark','98'
```

段誉登录教务系统查询了一下自己`Spark单科成绩`。

```ruby
hbase(main):087:0> get 'Student','002','Score:Spark'
COLUMN                                      CELL                 
 Score:Spark                                timestamp=1648557259939, value=98
1 row(s) in 0.0070 seconds
```

后来他回顾了一下`Spark历史成绩`

```ruby
hbase(main):086:0> get 'Student','002',{COLUMN=>'Score:Spark',VERSIONS=>3}
COLUMN                                      CELL    
 Score:Spark                                timestamp=1648557259939, value=98   
 Score:Spark                                timestamp=1648556808780, value=56    
 Score:Spark                                timestamp=1648556643468, value=55
1 row(s) in 0.0100 seconds
```



##### 教务老师

查询所有同学的个人信息(Info)

```ruby
hbase(main):004:0> scan 'Student',{COLUMN=>'Info'}
ROW                 COLUMN+CELL                        
 001                column=Info:age, timestamp=1648555932178, value=30
 001                column=Info:name, timestamp=1648555865078, value=qiaofeng
 002                column=Info:age, timestamp=1648555981987, value=27 
 002                column=Info:name, timestamp=1648555873577, value=duanyu 
 003                column=Info:age, timestamp=1648555988871, value=18
 003                column=Info:name, timestamp=1648555884874, value=wangyuyan   
3 row(s) in 0.0910 seconds
```

查看所有同学的Hadoop成绩(Scoe:Hadoop)

```ruby
hbase(main):005:0> scan 'Student',{COLUMN=>'Score:Hadoop'}
ROW                  COLUMN+CELL
 001                 column=Score:Hadoop, timestamp=1648556188482, value=93
 002                 column=Score:Hadoop, timestamp=1648556200639, value=95
 003                 column=Score:Hadoop, timestamp=1648556207324, value=95
3 row(s) in 0.0190 seconds
```

查询所有同学的姓名(Info:name)和各科成绩(Score)

```ruby
hbase(main):006:0> scan 'Student',{COLUMNS=>['Info:name','Score']}
ROW                COLUMN+CELL                                          
 001               column=Info:name, timestamp=1648555865078, value=qiaofeng
 001               column=Score:Hadoop, timestamp=1648556188482, value=93
 001               column=Score:Hbase, timestamp=1648556219092, value=85
 001               column=Score:Spark, timestamp=1648556262488, value=70
 002               column=Info:name, timestamp=1648555873577, value=duanyu
 002               column=Score:Hadoop, timestamp=1648556200639, value=95
 002               column=Score:Hbase, timestamp=1648556226943, value=98
 002               column=Score:Spark, timestamp=1648557259939, value=98
 003               column=Info:name, timestamp=1648555884874, value=wangyuyan
 003               column=Score:Hadoop, timestamp=1648556207324, value=95
 003               column=Score:Hbase, timestamp=1648556249759, value=97
 003               column=Score:Spark, timestamp=1648556278852, value=92
3 row(s) in 0.0750 seconds
```

查询前两名同学的姓名(Info:name)和各科成绩(Score)

```ruby
hbase> scan 'Student',{COLUMNS=>['Info:name','Score'],STARTROW=>'001',ENDROW=>'003'}
ROW                   COLUMN+CELL                                    
 001                  column=Info:name, timestamp=1648555865078, value=qiaofeng
 001                  column=Score:Hadoop, timestamp=1648556188482, value=93
 001                  column=Score:Hbase, timestamp=1648556219092, value=85
 001                  column=Score:Spark, timestamp=1648556262488, value=70
 002                  column=Info:name, timestamp=1648555873577, value=duanyu
 002                  column=Score:Hadoop, timestamp=1648556200639, value=95
 002                  column=Score:Hbase, timestamp=1648556226943, value=98 
 002                  column=Score:Spark, timestamp=1648557259939, value=98
2 row(s) in 0.0670 seconds
```

##### 删除

删除乔峰的Hadoop成绩，查询一下是否删除成功。

```ruby
hbase(main):009:0> delete 'Student','001','Score:Hadoop'
0 row(s) in 0.1620 seconds

hbase(main):010:0> get 'Student','001','Score'
COLUMN                                      CELL   
 Score:Hbase                                timestamp=1648556219092, value=85 
 Score:Spark                                timestamp=1648556262488, value=70
1 row(s) in 0.1310 seconds
```



查询段誉三次Spark成绩，删除段誉第一次补考成绩，再次查询段誉的三次成绩。

```ruby
# 查询三次历史成绩
hbase(main):011:0> get 'Student','002',{COLUMN=>'Score:Spark',VERSIONS=>3}
COLUMN                                      CELL         
 Score:Spark                                timestamp=1648557259939, value=98
 Score:Spark                                timestamp=1648556808780, value=56
 Score:Spark                                timestamp=1648556643468, value=55
1 row(s) in 0.0240 seconds

# 删除第一次补考成绩
hbase(main):012:0> delete 'Student','002','Score:Spark',1648556643468
0 row(s) in 0.0310 seconds

# 再次查询三次历史成绩
hbase(main):013:0> get 'Student','002',{COLUMN=>'Score:Spark',VERSIONS=>3}
COLUMN                                      CELL                              
 Score:Spark                                timestamp=1648557259939, value=98
 Score:Spark                                timestamp=1648556808780, value=56 
 Score:Spark                                timestamp=1648556271299, value=50 
1 row(s) in 0.0150 seconds
```



##### 删除王语嫣整条记录

```ruby
hbase(main):014:0> deleteall 'Student','003'
```

##### 退出 - exit

```ruby
hbase(main):014:0> exit
```