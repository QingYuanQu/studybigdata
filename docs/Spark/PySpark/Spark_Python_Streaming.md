---
title: PySpark Streaming
date: 2022-03-23 15:55:26
categories:
- PySpark
---
### Hello World

```python
from pyspark import SparkConf
from pyspark import SparkContext
from pyspark.streaming import StreamingContext

if __name__ == '__main__':
    conf = SparkConf().setMaster("spark://node0:7077").setAppName("HelloWorld")
    sc = SparkContext(conf=conf)
    ssc = StreamingContext(sc, 1)

    stream = ssc.socketTextStream("localhost", 9999)
    stream.pprint()
    ssc.start()
    ssc.awaitTermination()
```

### Data

```java
package com.studybigdata.java.socket;

import java.io.IOException;
import java.io.OutputStream;
import java.net.ServerSocket;
import java.net.Socket;
import java.nio.charset.StandardCharsets;

public class StreamingHelloWorld {
    public static void main(String[] args) throws IOException, InterruptedException {

        ServerSocket sc = new ServerSocket(9999);

        System.out.println("等待链接... ...");
        Socket accept = sc.accept();
        System.out.println("客户端链接成功："+accept.getLocalAddress());

        OutputStream outputStream = accept.getOutputStream();

        while (true) {

            String [] items = new String[]{"a", "b", "c", "d", "e", "f"};

            for (String item : items) {

                item = item + "\n"; // 输出数据最后一定要有换行符！！！，不然spark收不到数据。
                System.out.println("输出字符： "+ item);

                outputStream.write(item.getBytes(StandardCharsets.UTF_8));
                Thread.sleep(500);
            }
        }
    }
}
```



### NetCat

##### 安装依赖

```shell
[root@node0 netcat-0.7.1]# yum install gcc
```

##### 下载

```shell
[root@node0 zhangsan]# curl -O -L http://sourceforge.net/projects/netcat/files/netcat/0.7.1/netcat-0.7.1.tar.gz
```

##### 解压

```shell
[root@node0 zhangsan]# tar -zxf netcat-0.7.1.tar.gz 
```

```shell
[root@node0 zhangsan]# cd netcat-0.7.1
```

##### 配置

```shell
[root@node0 netcat-0.7.1]# ./configure 
```

##### 编译

```shell
[root@node0 netcat-0.7.1]# make
```

##### 安装

```shell
[root@node0 netcat-0.7.1]# make install
```

##### 使用

```shell
[root@node0 netcat-0.7.1]# netcat -lp 9999
```





### Filter

```python
(python37) [zhangsan@node0 ~]$ vim Streaming.py 

from pyspark import SparkConf
from pyspark import SparkContext
from pyspark.streaming import StreamingContext

if __name__ == '__main__':
    uncivilized_words = ["愤怒","生气","辣鸡"]
    conf = SparkConf().setMaster("spark://node0:7077").setAppName("HelloWorld")
    sc = SparkContext(conf=conf)
    ssc = StreamingContext(sc, 1)

    stream = ssc.socketTextStream("localhost", 9999)
    stream.filter(lambda word:word not in uncivilized_words).pprint()
    ssc.start()
    ssc.awaitTermination()
```



### WordCount

```python
record_list = stream.flatMap(lambda line:line.split(" ")).map(lambda word: (word, 1)).reduceByKey(lambda a, b: a + b)
record_list.pprint()
```





### 滚动窗口

```
data duration: 1s
batch interval: 2s
window Duration: 2s
slide Duration: 2s
```



### 滑动窗口

```
data duration: 1s
batch interval: 1s
window Duration: 2s
slide Duration: 1s
```



### countByKey

```python
from pyspark import SparkConf
from pyspark import SparkContext
from pyspark.streaming import StreamingContext


def count_fun(new,old):
    if old is None:
        old = 0
    count = sum(new,old)
    return count

if __name__ == '__main__':
    conf = SparkConf().setMaster("local[*]").setAppName("HelloWorld")
    sc = SparkContext(conf=conf)
    ssc = StreamingContext(sc, 1)

    ssc.checkpoint("file:///home/zhangsan/checkpoint")
    stream = ssc.socketTextStream("localhost", 9999)
    stream.flatMap(lambda line:line.split(" ")).map(lambda word: (word, 1)).reduceByKey(lambda a, b: a + b).saveAsTextFiles("file:///home/zhangsan/out")
    ssc.start()
    ssc.awaitTermination()
```



### UpdateStateByKey

需要先设置检查点checkpoint。

```python
from pyspark import SparkConf
from pyspark import SparkContext
from pyspark.streaming import StreamingContext


def count_fun(new,old):
    if old is None:
        old = 0
    count = sum(new,old)
    return count

if __name__ == '__main__':
    conf = SparkConf().setMaster("local[*]").setAppName("HelloWorld")
    sc = SparkContext(conf=conf)
    ssc = StreamingContext(sc, 1)

    ssc.checkpoint("file:///home/zhangsan/checkpoint")
    stream = ssc.socketTextStream("localhost", 9999)
    stream.flatMap(lambda line:line.split(" ")).map(lambda word: (word, 1)).reduceByKey(lambda a, b: a + b).updateStateByKey(count_fun).pprint()
    ssc.start()
    ssc.awaitTermination()
```

### 输出与持久化

#### pprint
```python
def pprint(self, num=10):
    """
    Print the first num elements of each RDD generated in this DStream.

    @param num: the number of elements from the first will be printed.
    """
```
Print函数，打印dstream中每批数据的前十个元素，这对于开发和调试很有用。



#### foreachRDD

DStream中的foreachRDD是一个非常强大函数，它允许你把数据发送给外部系统。写数据到外部系统需要创建一个  connection object，开发者需要创建一个connection  object用于连接。

> 根据TCP协议连接到远程的服务器，我们连接外部数据库需要自己的句柄。



##### 在Driver中创建一个连接对象

```scala
dstream.foreachRDD { rdd =>
  val connection = createNewConnection()  // executed at the driver
  rdd.foreach { record =>
    connection.send(record) // executed at the worker
  }
}
```

这是不正确的，因为这需要先序列化连接对象，然后将它从driver发送到worker中。这样的连接对象在机器之间不能传送。它可能表现为序列化错误（连接对象不可序列化）或者初始化错误（连接对象应该 在worker中初始化）等等。

##### 在Worker中创建连接对象

```scala
dstream.foreachRDD { rdd =>
  rdd.foreach { record =>
    val connection = createNewConnection()
    connection.send(record)
    connection.close()
  }
}
```

这会造成另外一个常见的错误，为每一个记录创建了一个连接对象。创建一个连接对象有资源和时间的开支。因此，为每个记录创建和销毁连接对象会导致非常高的开支，明显的减少系统的整体吞吐量。

##### 为RDD的partition创建一个连接对象

```scala
dstream.foreachRDD { rdd =>
  rdd.foreachPartition { partitionOfRecords =>
    val connection = createNewConnection()
    partitionOfRecords.foreach(record => connection.send(record))
    connection.close()
  }
}
```

一个更好的解决办法是利用rdd.foreachPartition方法。 为RDD的partition创建一个连接对象。

##### 静态的连接对象池

```scala
dstream.foreachRDD { rdd =>
  rdd.foreachPartition { partitionOfRecords =>
    // ConnectionPool is a static, lazily initialized pool of connections
    val connection = ConnectionPool.getConnection()
    partitionOfRecords.foreach(record => connection.send(record))
    ConnectionPool.returnConnection(connection)  // return to the pool for future reuse
  }
}
```

最后，可以通过在多个RDD或者批数据间**重用连接对象**做更进一步的优化。开发者可以保有一个静态的连接对象池，重复使用池中的对象将多批次的RDD推送到外部系统，以进一步节省开支。



#### saveAsTextFiles

```python
from pyspark.conf import SparkConf
from pyspark.context import SparkContext
from pyspark.streaming import StreamingContext


conf = SparkConf().setAppName("helloworld").setMaster("local[*]")
sc = SparkContext(conf=conf)
ssc = StreamingContext(sc,3)

# create a DStream that reads data from a TCP socket
lines = ssc.socketTextStream("localhost", 9999)

# split the lines into words and count the occurrence of each word
words_counts = lines.flatMap(lambda line: line.split(" ")).map(lambda word: (word, 1)).reduceByKey(lambda a, b: a + b)

# save the counts of each word as text files

words_counts.saveAsTextFiles("out1")

ssc.start()
ssc.awaitTermination()

```

