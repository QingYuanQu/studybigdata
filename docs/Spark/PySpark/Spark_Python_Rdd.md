---
title: PySpark RDD
date: 2022-03-23 15:55:26
categories:
- PySpark
---

# RDD

> A Resilient Distributed Dataset (`RDD`), the `basic abstraction` in Spark. Represents an `immutable`(不可变的), `partitioned collection(集合) of elements` that can be `operated o in parallel`. This `class` contains the basic operations available on all RDDs, such as `map`, `filter`, and `persist`. 
>
> In addition,
>
> `PairRDDFunctions(类)` contains operations `available only` on `RDDs of key-value pairs`, such as `groupByKey` and `join`; 
>
> `DoubleRDDFunctions` contains operations available only on `RDDs of Doubles`; 
>
> `SequenceFileRDDFunctions` contains operations available on RDDs that can be saved as `SequenceFiles`. 
>
> All operations are automatically available on any RDD of the right type (e.g. RDD[(Int, Int)]) through implicit(隐式).
> Internally, each RDD is characterized by `five main properties`:
>
> - A list of partitions
>
> - A function for computing each split
>
> - A list of dependencies on other RDDs
> - Optionally, a Partitioner for key-value RDDs (e.g. to say that the RDD is hash-partitioned)
>
> - Optionally, `a list of preferred locations` to compute each `split` on (e.g. block locations for an HDFS file)
>
> All of the scheduling and execution in Spark is done based on these methods, allowing each RDD to implement its own way of computing itself. Indeed（实际上）, users can implement custom RDDs (e.g. for reading data from a new storage system) by `overriding` these functions. Please refer to(查阅) the [Spark paper](http://people.csail.mit.edu/matei/papers/2012/nsdi_spark.pdf)  for more details on RDD internals.

## RDD创建

### 从已有集合创建

```python
sc.parallelize([1,2,3])
```

### 从外部数据集创建

```shell
# 本地文件系统
sc.textFile('file:///home/zhangsan/bigdata.txt').collect()
['www', 'www studybigdata ', 'www studybigdata cn']

# HDFS
sc.textFile('hdfs://node0:9000/user/zhangsan/bigdata.txt').collect()
['www', 'www studybigdata ', 'www studybigdata cn']

# 其他数据源 SequenceFiles, HBase ... ...
```

## RDD

### 转换算子

##### map (映射)

item => item_new

```python
>>> def addOne(item):
...     return item+1
...
>>> num_add_one_rdd = num_rdd.map(addOne)
>>> num_add_one_rdd.glom().collect()
[[2, 3], [4, 5], [6, 7], [8, 9, 10, 11], [12, 13], [14, 15], [16, 17], [18, 19, 20]]
```

##### flatMap

首先将函数应用于此RDD的所有元素，然后将结果展平，返回一个新的RDD。

`Return a new RDD by first applying a function to all elements of this RDD, and then flattening the results.`

- 示例一

```python
>>> data = [(1,2,3),(1,2),(3,)]
>>> rdd = sc.parallelize(data)
>>> rdd.flatMap(lambda x: x).collect()
[1, 2, 3, 1, 2, 3]
```

0. 此rdd中有三个元素  [(1,2,3),    (1,2),    (3,)]

1. 先应用函数`(lambda x : x)`对每个元素进行处理

   (1,2,3) ---> (1,2,3)
   (1,2) ---> (1,2)
   (3,) ---> (3,)

2. 最后将结果拍扁展平，二维数组压扁成一维列表
   [(1,2,3),(1,2),(3,)]  ===> [1, 2, 3, 1, 2, 3]

- 示例二

```python
>>> data = ['study big data cn','study big data','big data', 'study']
>>> rdd = sc.parallelize(data)
>>> flat_map_rdd = rdd.flatMap(lambda item : item.split(' '))
>>> flat_map_rdd.collect()
['study', 'big', 'data', 'cn', 'study', 'big', 'data', 'big', 'data', 'study']
```

首先使用匿名函数，将字符串`"study big data cn"`拆分成字符串列表`['study', 'big', 'data', 'cn']`；

然后`flatMap`压扁。



先看一下去重、条件查询、排序，使用的RDD为：

```python
>>> rdd = sc.parallelize([3,1,3,2])
```

##### distinct (去重)

```python
>>> distinct_rdd = rdd.distinct()
>>> distinct_rdd.collect()
[1, 2, 3]
```

##### sortBy (排序)

- 升序

```python
>>> sort_rdd = rdd.sortBy(lambda x:x)
>>> sort_rdd.collect()
[1, 2, 3, 3]
```

- 降序

```python
>>> sort_rdd = rdd.sortBy(lambda x:-x)
>>> sort_rdd.collect()
[3, 3, 2, 1]
```

- 根据元素长度排序

```python
>>> data = [(3,2,3),(2,),(1,1)]
>>> rdd = sc.parallelize(data)
>>> sort_by_len_rdd = rdd.sortBy(lambda x: len(x))
>>> sort_by_len_rdd.collect()
[(2,), (1, 1), (3, 2, 3)]
```

- 根据指定的维度排序

```python
# 使用上一步骤中的RDD
>>> sort_by_index = rdd.sortBy(lambda x:x[0])
>>> sort_by_index.collect()
[(1, 1), (2,), (3, 2, 3)]
```



#### 集合运算

接下来演示一下RDD的交、并、差、笛卡尔积运算，使用的RDD为：

```python
>>> rdd_1 = sc.parallelize([1,2,3])
>>> rdd_2 = sc.parallelize([2,3,4])
```

##### intersection (交集)

```python
>>> intersection_rdd = rdd_1.intersection(rdd_2)
>>> intersection_rdd.collect()
```

##### union (并集)

```python
>>> union_rdd = rdd_1.union(rdd_2)
>>> union_rdd.collect()
[1, 2, 3, 2, 3, 4]
```

##### subtract (差集)

```python
>>> substract_rdd = rdd_1.subtract(rdd_2)
>>> substract_rdd.collect()
[1]
```

##### cartesian (笛卡尔积)

```python
>>> cartesian_rdd = rdd_1.cartesian(rdd_2)
>>> cartesian_rdd.collect()
[(1, 2), (1, 3), (1, 4), (2, 2), (2, 3), (2, 4), (3, 2), (3, 3), (3, 4)]
```





#### 关系运算

##### filter  (选择/条件查询/过滤)

```python
>>> filter_rdd = rdd.filter(lambda x:x!=3)
>>> filter_rdd.collect()
[1, 2]
```





#### 分区操作

下面是与分区相关的算子，使用的RDD为：

```python
>>> nums = list(range(1,20))
>>> num_rdd = sc.parallelize(nums)
>>> num_rdd.collect()
[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
```

##### [glom](#glom)

联合所有分区元素构造一个列表。 

Return `an RDD` created by `coalescing`  `all elements within each partition` into a `list`.

coalesce： `[ˌkoʊəˈles]` 合并，联合

```python
# 默认2个分区，实验时使用的yarn模式，启动了两个Container，每个Container分配1个核。
>>> num_rdd.glom().collect()
[[1, 2, 3, 4, 5, 6, 7, 8, 9], [10, 11, 12, 13, 14, 15, 16, 17, 18, 19]]
```

##### [repartition](#repartition)

返回一个重新分区后的RDD

```python
>>> new_num_rdd = num_rdd.repartition(3)
>>> new_num_rdd.glom().collect()
[[], [1, 2, 3, 4, 5, 6, 7, 8, 9], [10, 11, 12, 13, 14, 15, 16, 17, 18, 19]]
```

[查看分区数](#getNumPartitions)

##### mapPartitions

**返回值** ：迭代器类型

```python
>>> def fun(part_data):
...     yield sum(part_data)
... 


>>> new_num_rdd.mapPartitions(fun).collect()
[0, 45, 145]
```



##### mapPartitionsWithIndex

此算子传入一个函数对象；

**形参**  : 函数接收两个参数 （分区编号，指向分区元素的迭代器）

**返回值** :  迭代器类型



如： 使用`mapPartitionsWithIndex`为每个分区的数据加上分区号。

```python
def fun(index, part_iter):
	yield index, sum(part_iter)
    
>>> new_num_rdd.mapPartitionsWithIndex(fun).glom().collect()
[[(0, 0)], [(1, 45)], [(2, 145)]]
```





### 动作算子

##### isEmpty

```python
>>> rdd = sc.parallelize([1,2,3])
>>> rdd.isEmpty()
False
```

##### collect

返回一个包含此RDD中所有元素的`list`列表。

**注意**：由于所有数据都会加载到`Driver`的内存中，因此仅当生成的`列表`预计很小时才应使用此方法，数据过大的话，Driver内存放不下。

`Return a list that contains all of the elements in this RDD.
note: This method should only be used if the resulting array is expected to be small, as all the data is loaded into the driver's memory.
`

##### reduce

使用指定的交换和结合二元操作符`reduce`此RDD的元素。`reduces partitions locally.`。

比如加减乘除等二元操作符。

`Reduces the elements of this RDD using the specified commutative and associative binary operator. Currently reduces partitions locally.`

```python
>>> rdd = sc.parallelize([1,2,3])
>>> rdd.reduce(lambda x,y:x+y)
6
```

##### count

返回此RDD中的元素个数。

`Return the number of elements in this RDD.`

```python
>>> rdd = sc.parallelize([2,1,3])
>>> rdd.count()
3
```



##### foreach

将函数应用到此RDD的所有元素。

`Applies a function to all elements of this RDD.`

```python
# 每个元素的值+1 （执行完控制台无任何输出）
sc.parallelize([2,1,3]).foreach(lambda x: x+1)

# 可借助print()打印处理后的结果
# 第一次输出
>>> sc.parallelize([2,1,3]).foreach(lambda x: print(x+1))
4
2
3
# 第二次输出（可以看到元素的遍历顺序是无序的）
>>> sc.parallelize([2,1,3]).foreach(lambda x: print(x+1))
2
3
4
```



#### 取值操作

##### take

获取RDD的前`n`个元素。

`Take the first num elements of the RDD.`

```python
>>> rdd = sc.parallelize([2,1,3])
>>> rdd.take(2)
[2, 1]
```

##### takeOrdered

从RDD中按升序或可选键函数指定的顺序获取N个元素。

`Get the N elements from an RDD ordered in ascending order or as specified by the optional key function.`

```python
# rdd中的元素本来是[2,1,3]
# 升序排列，输出前两个元素
>>> rdd.takeOrdered(2)
[1, 2]
```

##### first

返回此RDD中的第一个元素。

`Return the first element in this RDD.`

```python
# rdd = [2,1,3]
>>> rdd.first()
2
```

##### top

从RDD中获取前N个元素。

`Get the top N elements from an RDD.`

```python
# rdd = [2,1,3]
>>> rdd.top(2)
[3, 2]
```

#### 分区操作

##### [getNumPartitions](#getNumPartitions)

`Returns the number of partitions in RDD`

返回RDD的分区数。

实验采用`3`台`2`核心虚拟机，通过`Standalone`模式启动，可以看到数据`分区数`默认为`机器数`*`机器逻辑CPU的个数`。

```python
# 生成19个数
>>> nums = list(range(1,20)) 
# 构造RDD
>>> num_rdd = sc.parallelize(nums)

# 查看数据分区数
>>> num_rdd.getNumPartitions()
6
```

##### foreachPartition

将函数应用到此RDD的所有分区。

`Applies a function to each partition of this RDD.`

```python
# 使用上一步的数据
# 统计一下每个分区内的元素个数

# 查看数据分布情况
>>> num_rdd.glom().collect()
[[1, 2], [3, 4], [5, 6], [7, 8, 9, 10], [11, 12], [13, 14], [15, 16], [17, 18, 19]]

# 统计一下每个分区内的元素个数
>>> each_part_size = num_rdd.foreachPartition(lambda part: print(len(list(part))))
2
2
4
2
2
2
3
2
```

#### 持久化

##### saveAsTextFile

```python
# 使用上一步数据
>>> num_rdd.saveAsTextFile("file:///home/quqingyuan/num")

# 去本地文件系统查看一下保存结果，每个分区的数据保存为一个文件
(python37) [quqingyuan@honor num]$ ll
total 32K
-rw-r--r-- 1 quqingyuan quqingyuan 4 Jul  8 12:46 part-00000
-rw-r--r-- 1 quqingyuan quqingyuan 4 Jul  8 12:46 part-00001
-rw-r--r-- 1 quqingyuan quqingyuan 4 Jul  8 12:46 part-00002
-rw-r--r-- 1 quqingyuan quqingyuan 9 Jul  8 12:46 part-00003
-rw-r--r-- 1 quqingyuan quqingyuan 6 Jul  8 12:46 part-00004
-rw-r--r-- 1 quqingyuan quqingyuan 6 Jul  8 12:46 part-00005
-rw-r--r-- 1 quqingyuan quqingyuan 6 Jul  8 12:46 part-00006
-rw-r--r-- 1 quqingyuan quqingyuan 9 Jul  8 12:46 part-00007
-rw-r--r-- 1 quqingyuan quqingyuan 0 Jul  8 12:46 _SUCCESS
```

如果一个RDD里面只有三个元素，会保存为几个文件？

```python
>>> three_rdd = sc.parallelize([1,2,3])
>>> three_rdd.saveAsTextFile("file:///home/quqingyuan/three")

# 查看保存结果
(python37) [quqingyuan@honor three]$ cat part-00000
(python37) [quqingyuan@honor three]$ cat part-00001
(python37) [quqingyuan@honor three]$ cat part-00002
1
(python37) [quqingyuan@honor three]$ cat part-00003
(python37) [quqingyuan@honor three]$ cat part-00004
(python37) [quqingyuan@honor three]$ cat part-00005
2
(python37) [quqingyuan@honor three]$ cat part-00006
(python37) [quqingyuan@honor three]$ cat part-00007
3
```



## 键值对RDD

### 转换算子

#### keys

```python
>>> rdd = sc.parallelize([(1,"zhangsan"),(2,"lisi"),(1,"wangwu"),(1,"zhaoliu")])
>>> rdd.keys().collect()

[1, 2, 1, 1]
```

#### values

```python
>>> rdd = sc.parallelize([(1,"zhangsan"),(2,"lisi"),(1,"wangwu"),(1,"zhaoliu")])
>>> rdd.values().collect()

['zhangsan', 'lisi', 'wangwu', 'zhaoliu']
```





```PYTHON
data = [
    ('a', 2),
    ('a', 3), 
    ('a', 4), 
    ('b', 1), 
    ('b', 2), 
    ('b', 3), 
    ('c', 4), 
    ('c', 6), 
    ('c', 8)
]
```



#### groupByKey

```python

```

#### sortByKey

```python
>>> rdd = sc.parallelize([(1,"zhangsan"),(2,"lisi"),(1,"wangwu"),(1,"zhaoliu")])
>>> rdd.sortByKey().collect()
[(1, 'wangwu'), (1, 'zhaoliu'), (1, 'zhangsan'), (2, 'lisi')]  
```

#### mapValues

```python
>>> rdd = sc.parallelize([(1,"zhangsan"),(2,"lisi"),(1,"wangwu"),(1,"zhaoliu")])
>>> rdd.mapValues(lambda x:"name-"+x).collect()

[(1, 'name-zhangsan'), (2, 'name-lisi'), (1, 'name-wangwu'), (1, 'name-zhaoliu')]
```



#### reduceByKey

```

```





#### flatMapValues

```python
>>> rdd = sc.parallelize([("b",[1,2,3]), ("a",[2,3,4]),("c",[4,6,8])])
>>> rdd.flatMapValues(lambda value:value).collect()
[('a', 1), ('a', 2), ('a', 3), ('b', 2), ('b', 3), ('b', 4)]
```





#### subtractByKey

```python
rdd1 = sc.parallelize((['a', 3], ['b', 2], ['c', 5], ['b', 3]))
rdd2 = sc.parallelize((['a', 1], ['c', 2]))
rdd3 = rdd1.groupByKey().subtractByKey(rdd2).mapValues(list)
print(rdd3.collect())

# result
[('b', [2, 3])]
```


#### combineByKey

```
```

#### join

```
```

#### leftOuterJoin

```

```

#### rightOuterJoin

```

```

#### partitionBy

```
```



### 动作算子

#### CollectAsMap





#### countByKey



#### countByValue



## DoubleRDDFunctions

#### max



#### min





#### sum

```python
>>> sc.parallelize([1.0,2.0,3.0]).sum()
6.0
```

#### stats



#### mean

## SequenceFileRDDFunctions

#### saveAsSequenceFile





## 练习

#### 分区练习

初始化列表 `list_p = [1,2,3,4,5]`

使用`list_p`创建分区数为`2`的`RDD` ，命名为`rdd_p`



查看`rdd_p`的分区数

查看`rdd_p`各分区内的元素



使用`rdd_p`创建一个分区数为`3`的`RDD`，命名为`rdd_rp`

查看`rdd_rp`各分区内的元素

```python
>>> list_p=[1,2,3,4,5]
>>> rdd_p=sc.parallelize(list_p,2)
>>> rdd_p.getNumPartitions()
2
>>> rdd_p.glom().collect()
[[1, 2], [3, 4, 5]]
>>> 
>>> rdd_rp=rdd_p.repartition(3)
>>> rdd_rp.glom().collect()
[[], [1, 2], [3, 4, 5]]
```





```python
www www www www www study study study study big big big data data cn
www www www www study study study big big data
www www www study study big
www www study
www
```



```python
>>> rdd = sc.textFile("hdfs:///input/data.txt")
>>> rdd.collect()
['www www www www www study study study study big big big data data cn', 'www www www www study study study big big data ', 'www www www study study big ', 'www www study ', 'www ']

# flatMap
>>> rdd.flatMap(lambda x:x.split(" ")).collect()
['www', 'www', 'www', 'www', 'www', 'study', 'study', 'study', 'study', 'big', 'big', 'big', 'data', 'data', 'cn', 'www', 'www', 'www', 'www', 'study', 'study', 'study', 'big', 'big', 'data', '', 'www', 'www', 'www', 'study', 'study', 'big', '', 'www', 'www', 'study', '', 'www', '']


# map
>>> rdd.flatMap(lambda x:x.split(" ")).map(lambda word:(word,1)).collect()
[('www', 1), ('www', 1), ('www', 1), ('www', 1), ('www', 1), ('study', 1), ('study', 1), ('study', 1), ('study', 1), ('big', 1), ('big', 1), ('big', 1), ('data', 1), ('data', 1), ('cn', 1), ('www', 1), ('www', 1), ('www', 1), ('www', 1), ('study', 1), ('study', 1), ('study', 1), ('big', 1), ('big', 1), ('data', 1), ('', 1), ('www', 1), ('www', 1), ('www', 1), ('study', 1), ('study', 1), ('big', 1), ('', 1), ('www', 1), ('www', 1), ('study', 1), ('', 1), ('www', 1), ('', 1)]



# reduceByKey
>>> rdd.flatMap(lambda x:x.split(" ")).map(lambda word:(word,1)).reduceByKey(lambda x,y:x+y).collect()
[('www', 15), ('', 4), ('study', 10), ('big', 6), ('data', 3), ('cn', 1)]


#############################################################################

# 词频统计
def wordcount(word_list):
    word_freq = {}
    for word in word_list:
        if word in word_freq.keys():
            word_freq[word] = word_freq[word]+1
        else:
            word_freq[word] = 1
    return word_freq



>>> rdd.map(lambda line:line.split(" "))
[['www', 'www', 'www', 'www', 'www', 'study', 'study', 'study', 'study', 'big', 'big', 'big', 'data', 'data', 'cn'], ['www', 'www', 'www', 'www', 'study', 'study', 'study', 'big', 'big', 'data', ''], ['www', 'www', 'www', 'study', 'study', 'big', ''], ['www', 'www', 'study', ''], ['www', '']]


>>> rdd.map(lambda line:line.split(" ")).map(wordcount).collect()
[{'www': 5, 'study': 4, 'big': 3, 'data': 2, 'cn': 1}, {'www': 4, 'study': 3, 'big': 2, 'data': 1, '': 1}, {'www': 3, 'study': 2, 'big': 1, '': 1}, {'www': 2, 'study': 1, '': 1}, {'www': 1, '': 1}]


# flatMap
>>> rdd.map(lambda line:line.split(" ")).map(wordcount).flatMap(lambda d:list(d.items())).collect()
[('www', 5), ('study', 4), ('big', 3), ('data', 2), ('cn', 1), ('www', 4), ('study', 3), ('big', 2), ('data', 1), ('', 1), ('www', 3), ('study', 2), ('big', 1), ('', 1), ('www', 2), ('study', 1), ('', 1), ('www', 1), ('', 1)]


# groupByKey
>>> rdd.map(lambda line:line.split(" ")).map(wordcount).flatMap(lambda d:list(d.items())).groupByKey().collect()
[('www', <pyspark.resultiterable.ResultIterable object at 0x7fb9abc2fad0>), ('', <pyspark.resultiterable.ResultIterable object at 0x7fb9abc2fb10>), ('study', <pyspark.resultiterable.ResultIterable object at 0x7fb9aaf79850>), ('big', <pyspark.resultiterable.ResultIterable object at 0x7fb9aaf6add0>), ('data', <pyspark.resultiterable.ResultIterable object at 0x7fb9aaf6afd0>), ('cn', <pyspark.resultiterable.ResultIterable object at 0x7fb9aaf6a6d0>)]


# sortByKey
>>> rdd.map(lambda line:line.split(" ")).map(wordcount).flatMap(lambda d:list(d.items())).groupByKey().sortByKey().collect()
[('', <pyspark.resultiterable.ResultIterable object at 0x7fb9aaf7d590>), ('big', <pyspark.resultiterable.ResultIterable object at 0x7fb9aaf7dc10>), ('cn', <pyspark.resultiterable.ResultIterable object at 0x7fb9aaf7d950>), ('data', <pyspark.resultiterable.ResultIterable object at 0x7fb9aaf7d790>), ('study', <pyspark.resultiterable.ResultIterable object at 0x7fb9aaf7da10>), ('www', <pyspark.resultiterable.ResultIterable object at 0x7fb9aaf7da90>)]


# mapValues
>>> rdd.map(lambda line:line.split(" ")).map(wordcount).flatMap(lambda d:list(d.items())).groupByKey().sortByKey().mapValues(lambda x: list(x)).collect()
[('', [1, 1, 1, 1]), ('big', [3, 2, 1]), ('cn', [1]), ('data', [2, 1]), ('study', [4, 3, 2, 1]), ('www', [3, 2, 1, 5, 4])]


# flatMapValues
>>> rdd.map(lambda line:line.split(" ")).map(wordcount).flatMap(lambda d:list(d.items())).groupByKey().sortByKey().mapValues(lambda x: list(x)).flatMapValues(lambda x:x).collect()
[('', 1), ('', 1), ('', 1), ('', 1), ('big', 1), ('big', 3), ('big', 2), ('cn', 1), ('data', 2), ('data', 1), ('study', 2), ('study', 1), ('study', 4), ('study', 3), ('www', 5), ('www', 4), ('www', 3), ('www', 2), ('www', 1)] 





```

