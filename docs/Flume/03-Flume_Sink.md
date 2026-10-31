---
title: Flume Sink - HDFS Sink
date: 2022-03-23 15:55:26
categories:
- Flume
tags:
- Flume HDFS Sink
---

## Sink

### [HDFS Sink](https://flume.apache.org/releases/content/1.9.0/FlumeUserGuide.html#hdfs-sink)

#### 配置文件

`$FLUME_HOME/job/4-scoket-flume-hdfs.conf`

```properties
# 为agent a1 的各组件命名
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# source
# agent a1的一个source在端口9999监听数据
a1.sources.r1.type = netcat
a1.sources.r1.bind = localhost
a1.sources.r1.port = 9999
a1.sources.r1.channels = c1

# channel
# channel在内存中缓存events
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 100

# sink
#a1.sinks.k1.hdfs.fileType=DataStream
a1.sinks.k1.type = hdfs 
a1.sinks.k1.channel = c1 
a1.sinks.k1.hdfs.path = hdfs://node1:8020/flume/events/%y-%m-%d/%H%M/%S 
a1.sinks.k1.hdfs.filePrefix = events- 
a1.sinks.k1.hdfs.round = true 
a1.sinks.k1.hdfs.roundValue = 5
a1.sinks.k1.hdfs.roundUnit = minute
a1.sinks.k1.hdfs.useLocalTimeStamp = true
```

#### 启动agent

```shell
[zhangsan@node0 default]$ ./bin/flume-ng agent -c conf -f job/4-scoket-flume-hdfs.conf -n a1 -Dflume.root.logger=INFO,console
```

#### Telnet输入

```bash
[zhangsan@node1 ~]$ telnet localhost 9999
Trying ::1...
telnet: connect to address ::1: Connection refused
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
www
OK
studybigdata
OK
com
OK
```

#### 日志输出

```java
2026-03-24 19:26:26,451 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.hdfs.HDFSSequenceFile.configure(HDFSSequenceFile.java:63)] writeFormat = Writable, UseRawLocalFileSystem = false
2026-03-24 19:26:26,618 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.hdfs.BucketWriter.open(BucketWriter.java:246)] Creating hdfs://node1:8020/flume/events/26-03-24/1925/00/events-.1774351586450.tmp
2026-03-24 19:26:30,980 (Thread-9) [INFO - org.apache.hadoop.hdfs.protocol.datatransfer.sasl.SaslDataTransferClient.checkTrustAndSend(SaslDataTransferClient.java:239)] SASL encryption trust check: localHostTrusted = false, remoteHostTrusted = false
2026-03-24 19:26:42,570 (SinkRunner-PollingRunner-DefaultSinkProcessor) [WARN - org.apache.flume.sink.hdfs.BucketWriter.append(BucketWriter.java:589)] Block Under-replication detected. Rotating file.
2026-03-24 19:26:42,570 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.hdfs.BucketWriter.doClose(BucketWriter.java:438)] Closing hdfs://node1:8020/flume/events/26-03-24/1925/00/events-.1774351586450.tmp
2026-03-24 19:26:42,622 (hdfs-k1-call-runner-4) [INFO - org.apache.flume.sink.hdfs.BucketWriter$7.call(BucketWriter.java:681)] Renaming hdfs://node1:8020/flume/events/26-03-24/1925/00/events-.1774351586450.tmp to hdfs://node1:8020/flume/events/26-03-24/1925/00/events-.1774351586450


2026-03-24 19:26:42,658 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.hdfs.BucketWriter.open(BucketWriter.java:246)] Creating hdfs://node1:8020/flume/events/26-03-24/1925/00/events-.1774351586451.tmp
2026-03-24 19:26:45,695 (Thread-13) [INFO - org.apache.hadoop.hdfs.protocol.datatransfer.sasl.SaslDataTransferClient.checkTrustAndSend(SaslDataTransferClient.java:239)] SASL encryption trust check: localHostTrusted = false, remoteHostTrusted = false
2026-03-24 19:26:51,547 (SinkRunner-PollingRunner-DefaultSinkProcessor) [WARN - org.apache.flume.sink.hdfs.BucketWriter.append(BucketWriter.java:589)] Block Under-replication detected. Rotating file.
2026-03-24 19:26:51,547 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.hdfs.BucketWriter.doClose(BucketWriter.java:438)] Closing hdfs://node1:8020/flume/events/26-03-24/1925/00/events-.1774351586451.tmp
2026-03-24 19:26:51,559 (hdfs-k1-call-runner-9) [INFO - org.apache.flume.sink.hdfs.BucketWriter$7.call(BucketWriter.java:681)] Renaming hdfs://node1:8020/flume/events/26-03-24/1925/00/events-.1774351586451.tmp to hdfs://node1:8020/flume/events/26-03-24/1925/00/events-.1774351586451


2026-03-24 19:26:51,583 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.hdfs.BucketWriter.open(BucketWriter.java:246)] Creating hdfs://node1:8020/flume/events/26-03-24/1925/00/events-.1774351586452.tmp
2026-03-24 19:26:54,627 (Thread-15) [INFO - org.apache.hadoop.hdfs.protocol.datatransfer.sasl.SaslDataTransferClient.checkTrustAndSend(SaslDataTransferClient.java:239)] SASL encryption trust check: localHostTrusted = false, remoteHostTrusted = false
2026-03-24 19:27:21,615 (hdfs-k1-roll-timer-0) [INFO - org.apache.flume.sink.hdfs.HDFSEventSink$1.run(HDFSEventSink.java:393)] Writer callback called.
2026-03-24 19:27:21,616 (hdfs-k1-roll-timer-0) [INFO - org.apache.flume.sink.hdfs.BucketWriter.doClose(BucketWriter.java:438)] Closing hdfs://node1:8020/flume/events/26-03-24/1925/00/events-.1774351586452.tmp
2026-03-24 19:27:21,646 (hdfs-k1-call-runner-4) [INFO - org.apache.flume.sink.hdfs.BucketWriter$7.call(BucketWriter.java:681)] Renaming hdfs://node1:8020/flume/events/26-03-24/1925/00/events-.1774351586452.tmp to hdfs://node1:8020/flume/events/26-03-24/1925/00/events-.1774351586452
```

#### 输出到HDFS

```bash
[zhangsan@node1 default]$ hdfs dfs -ls -R hdfs://node1:8020/flume/events/26-03-24/1925/00/
-rw-r--r--   3 zhangsan supergroup        139 2026-03-24 19:26 hdfs://node1:8020/flume/events/26-03-24/1925/00/events-.1774351586450
-rw-r--r--   3 zhangsan supergroup        148 2026-03-24 19:26 hdfs://node1:8020/flume/events/26-03-24/1925/00/events-.1774351586451
-rw-r--r--   3 zhangsan supergroup        139 2026-03-24 19:27 hdfs://node1:8020/flume/events/26-03-24/1925/00/events-.1774351586452
```

### 自我实践

将 `edu-mock-data.jar` 生成的`log`数据使用`Flume`导出到`HDFS`。



