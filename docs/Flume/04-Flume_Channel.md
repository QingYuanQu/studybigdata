---
title: Flume Channel
date: 2022-03-23 15:55:26
categories:
- Flume
tags:
- Flume Channel
- Flume Kafka Channel
---



## Flume Channel

### Channel的类型

```mermaid
graph TD

        subgraph C[📦 Channel 数据缓冲区]
            C1[💾 Memory Channel<br>内存通道<br>速度快, 易丢失]
            C2[📁 File Channel<br>文件通道<br>速度慢, 可靠]
            C3[📨 Kafka Channel<br>Kafka通道<br>高吞吐, 持久化]
            C4[🗄️ JDBC Channel<br>数据库通道<br>持久化存储]
        end

    style C fill:#bbf,stroke:#333
```

- Memory
- File
- Kafka
- JDBC

### Kafka Channel

```mermaid
flowchart LR
    %% 样式定义：按组件类型区分配色和样式，视觉分层
    classDef source fill:#E8F4FD,stroke:#2E86AB,stroke-width:2px,rx:8,ry:8
    classDef flume fill:#F0F8FF,stroke:#1E90FF,stroke-width:2px,rx:8,ry:8
    classDef kafka fill:#FFF8E6,stroke:#F5A623,stroke-width:3px,rx:8,ry:8
    classDef sink fill:#F9F3E6,stroke:#DAA520,stroke-width:2px,rx:8,ry:8
    classDef external fill:#F0FFF4,stroke:#2ECC71,stroke-width:2px,rx:8,ry:8

    %% 节点定义 + 绑定样式
    A[业务数据源<br/>日志/文件/接口/监控指标]:::source
    B[<b>Flume Source</b><br/>如：netcat]:::flume
    C[<b>Flume Channel</b><br/>Kafka Topic:<br/> flume-channel-topic]:::kafka
    D[<b>Flume Sink</b><br/>如：Logger]:::sink
    E[外部Kafka消费者<br/>如：kafka-console-consumer]:::external

    %% 流向箭头（加平滑曲线，更美观）
    A -- 采集 --> B
    B -- 写入 --> C
    C -. 消费 .-> D
    C -. 并行消费 .-> E
```

Flume 的 `Kafka Channel` 本质是**把 Kafka 主题当作「数据中转通道」**

✅ **其他程序必须使用【不同的消费者组】**（比如 `my-app-consumer`）

❌ 如果和 Flume 用同一个组：会发生**消费争抢**，Flume 或你的程序会丢失数据。



#### 前置条件

- 启动ZooKeeper集群
- 启动Kafka集群

#### 配置文件

`6-socket-kafka-console.conf`

```properties
# Kafka Channel 类型（固定写法）
a1.channels.c1.type = org.apache.flume.channel.kafka.KafkaChannel

# Kafka 集群地址（必填）
a1.channels.c1.kafka.bootstrap.servers = node1:9092,node2:9092,node3:9092

# Kafka 主题名称（自动创建，可自定义）
a1.channels.c1.kafka.topic = flume-channel-topic

# 消费者组 ID
a1.channels.c1.kafka.consumer.group.id = flume-consumer-group
a1.channels.c1.parseAsFlumeEvent = false
# 生产/消费超时（可选优化）
a1.channels.c1.kafka.producer.acks = 1
a1.channels.c1.kafka.consumer.auto.offset.reset = earliest
```

##### parseAsFlumeEvent

- 开启后：Flume 会把**事件头 (headers) + 事件体 (body)** 一起序列化成 **Flume 自定义的二进制格式** 写入 Kafka。

- 关闭后（默认 `false`）：Flume **只把消息体 (body，也就是你的业务明文)** 写入 Kafka。

#### 自我实现

根据流程图，自行实现下述配置。

- NetCat Source
- Logger Sink



#### 测试

##### Telnet输入

```bash
(base) [zhangsan@node1 ~]$ telnet localhost 9999
Trying ::1...
telnet: connect to address ::1: Connection refused
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
hello
OK
world
OK
```

##### Logger消费Topic

```java
2026-04-01 21:05:02,730 (kafka-producer-network-thread | producer-1) [INFO - org.apache.kafka.clients.Metadata.update(Metadata.java:285)] Cluster ID: Kc9Z6KZDT3iYwf8RaS6h1Q
2026-04-01 21:05:07,098 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{} body: 68 65 6C 6C 6F 0D                               hello. }
2026-04-01 21:05:07,107 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{} body: 77 6F 72 6C 64 0D                               world. }
```

##### Kafka-console-consumer.sh消费Topic

通过`kafka-console-consumer.sh`消费`Topic`，需要自行补全命令参数。

```bash
(base) [zhangsan@node1 default]$ bin/kafka-console-consumer.sh 

hello

world
```



#### 直接发送到Kafka

也可以去掉Sink，直接将消息发送到Kafka，供下游消费。



### 总结
1. **其他消费**：Kafka Channel 的 Topic 是标准 Kafka 主题，无独占性；
3. **核心规则**：外部程序用**独立消费者组**，避免和 Flume 争抢数据。