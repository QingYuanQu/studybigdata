---
title: Flink Kafka
date: 2026-03-14 21:36:26
categories:
- Flink 
tags:
- Flink
- Kafka
---

### pom

```xml
<dependency>
    <groupId>org.apache.flink</groupId>
    <artifactId>flink-connector-kafka</artifactId>
    <version>${flink.version}</version>
</dependency>
```



### Kafka命令行

#### 创建Topic

```bash
(base) [zhangsan@node1 ~]$ kafka-topics.sh  --create  --topic flink-kafka --partitions 3 --replication-factor 2 --bootstrap-server node1:9092
Created topic flink-kafka.
```

#### 生产者

```bash
(base) [zhangsan@node1 ~]$ kafka-console-producer.sh  --topic flink-kafka --bootstrap-server node1:9092
>a
>b b
>c c c
>
```



### Flink消费者

```java
KafkaSource<String> source = KafkaSource.<String>builder()
        .setBootstrapServers("node1:9092") // Kafka 服务器地址
        .setTopics("flink-kafka") // 订阅的 topic
        .setGroupId("consumer-group") // 消费者组
        .setStartingOffsets(OffsetsInitializer.latest()) // 从最新偏移量开始
        .setValueOnlyDeserializer(new SimpleStringSchema()) // 消息反序列化器
        .build();
```



### Flink生产者

```java
KafkaSink<String> sink = KafkaSink.<String>builder()
        .setBootstrapServers("node1:9092") // Kafka 服务器地址
        .setRecordSerializer(KafkaRecordSerializationSchema.builder()
                .setTopic("flink-kafka") // 目标 topic
                .setValueSerializationSchema(new SimpleStringSchema()) // 消息序列化器
                .build())
        .setDeliveryGuarantee(DeliveryGuarantee.AT_LEAST_ONCE) // 投递保证
        .build();
```

### 完整示例

#### DataStream API 示例

```java
import org.apache.flink.api.common.eventtime.WatermarkStrategy;
import org.apache.flink.api.common.serialization.SimpleStringSchema;
import org.apache.flink.connector.kafka.sink.KafkaRecordSerializationSchema;
import org.apache.flink.connector.kafka.sink.KafkaSink;
import org.apache.flink.connector.kafka.source.KafkaSource;
import org.apache.flink.connector.kafka.source.enumerator.initializer.OffsetsInitializer;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;

public class FlinkKafkaExample {
    public static void main(String[] args) throws Exception {
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

        // Kafka 消费者配置
        KafkaSource<String> source = KafkaSource.<String>builder()
                .setBootstrapServers("node1:9092")
                .setTopics("flink-kafka")
                .setGroupId("flink-consumer-group")
                .setStartingOffsets(OffsetsInitializer.latest())
                .setValueOnlyDeserializer(new SimpleStringSchema())
                .build();

        // Kafka 生产者配置
        KafkaSink<String> sink = KafkaSink.<String>builder()
                .setBootstrapServers("node1:9092")
                .setRecordSerializer(KafkaRecordSerializationSchema.builder()
                        .setTopic("flink-kafka-output")
                        .setValueSerializationSchema(new SimpleStringSchema())
                        .build())
                .setDeliveryGuarantee(DeliveryGuarantee.AT_LEAST_ONCE)
                .build();

        // 数据处理流程
        DataStream<String> stream = env.fromSource(
                source, 
                WatermarkStrategy.noWatermarks(), 
                "Kafka Source"
        );

        // 简单的数据处理：将消息转换为大写
        DataStream<String> processedStream = stream
                .map(String::toUpperCase)
                .name("ToUpperCase");

        // 输出到 Kafka
        processedStream.sinkTo(sink);

        env.execute("Flink Kafka Processing Job");
    }
}
```



