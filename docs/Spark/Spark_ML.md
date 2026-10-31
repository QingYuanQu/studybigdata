---
title: Spark ML
date: 2022-12-01 15:55:26
categories:
- Spark
---

# Spark ML

## 数据预处理

### 数据降维

```scala
    val data = Array(
      Vectors.sparse(5, Seq((1, 1.0), (3, 7.0))),
      Vectors.dense(2.0, 0.0, 3.0, 4.0, 5.0),
      Vectors.dense(4.0, 0.0, 0.0, 6.0, 7.0)
    )
    val df = spark.createDataFrame(data.map(Tuple1.apply)).toDF("features")
    df.show()

    val pca = new PCA()
      .setInputCol("features")
      .setOutputCol("pcaFeatures")
      .setK(3)
      .fit(df)

    val result = pca.transform(df).select("pcaFeatures")
    result.show(false)
```

### 二值化

```scala
    val data = Array((0, 0.1), (1, 0.8), (2, 0.2))
    val dataFrame = spark.createDataFrame(data).toDF("id", "feature")

    val binarizer: Binarizer = new Binarizer()
      .setInputCol("feature")
      .setOutputCol("binarized_feature")
      .setThreshold(0.5)

    val binarizedDataFrame = binarizer.transform(dataFrame)

    println(s"Binarizer output with Threshold = ${binarizer.getThreshold}")
    binarizedDataFrame.show()
```

## 机器学习算法

### 聚类

#### K-Means

```scala
    val dataset = spark.read.format("libsvm").load("data/mllib/sample_kmeans_data.txt")

    // Trains a k-means model.
    val kmeans = new KMeans().setK(2).setSeed(1L)
    val model = kmeans.fit(dataset)

    // Make predictions
    val predictions = model.transform(dataset)

    predictions.show()

    // Shows the result.
    println("Cluster Centers: ")
    model.clusterCenters.foreach(println)
```



#### 基于K-Means的出租车数据聚类

##### pom.xml

```xml
 <properties>
        <maven.compiler.source>8</maven.compiler.source>
        <maven.compiler.target>8</maven.compiler.target>
        <spark.version>2.4.8</spark.version>
        <scala.binary.version>2.11</scala.binary.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.apache.spark</groupId>
            <artifactId>spark-core_${scala.binary.version}</artifactId>
            <version>${spark.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.spark</groupId>
            <artifactId>spark-sql_${scala.binary.version}</artifactId>
            <version>${spark.version}</version>
        </dependency>

        <dependency>
            <groupId>org.apache.spark</groupId>
            <artifactId>spark-mllib_${scala.binary.version}</artifactId>
            <version>${spark.version}</version>
        </dependency>

        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-client</artifactId>
            <version>2.7.3</version>
        </dependency>
    </dependencies>


    <build>
        <!--  指定scala目录是源码存放目录 -->
        <sourceDirectory>src/main/scala</sourceDirectory>
        <plugins>
            <plugin>
                <groupId>org.scala-tools</groupId>
                <!--               maven-scala-plugin插件:  使用maven编译、运行scala代码-->
                <artifactId>maven-scala-plugin</artifactId>
                <version>2.15.2</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>compile</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>

```



##### 聚类代码

```scala
package org.example

import org.apache.spark.SparkConf
import org.apache.spark.ml.clustering.KMeans
import org.apache.spark.sql.{DataFrame, SparkSession}

object Main {
  def main(args: Array[String]): Unit = {
    val sparkConf: SparkConf = new SparkConf().setAppName("Car_Cluster").setMaster("yarn")

    val spark = SparkSession
      .builder.config(sparkConf)
      .getOrCreate()

    import spark.implicits._

    val dataset = spark.sparkContext.textFile("hdfs://node0:9000/car.csv")
    val list_rdd = dataset.map(line => line.split(","))
    val point_rdd = list_rdd.map(x => Array(x(1).toDouble, x(2).toDouble))
    val points: DataFrame = point_rdd.toDF("features")

    // Trains a k-means model.
    val kmeans = new KMeans().setK(3)
    val model = kmeans.fit(points)

    // Make predictions
    val predictions = model.transform(points)

    predictions.show()
    print(System.getProperty("user.name"))

    // Shows the result.
    println("Cluster Centers: ")
    model.clusterCenters.foreach(println)

    spark.stop()
  }

}
```

##### 聚类中心可视化

```html
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>kmeans聚类可视化</title>
<style type="text/css">
html{height:100%}
body{height:100%;margin:0px;padding:0px}
#container{height:100%}
</style>
<script type="text/javascript" src="http://api.map.baidu.com/api?v=2.0&ak=Z7q0WBomr1GbD6HVGSD6GyBIrkqeoFhi">
//v2.0版本的引用方式：src="http://api.map.baidu.com/api?v=2.0&ak=您的密钥"
</script>
</head>

<body>
<div id="container"></div>
<script type="text/javascript">
var map = new BMap.Map("container");
// 创建地图实例
map.enableScrollWheelZoom();           //允许滑轮进行放大缩小
map.addControl(new BMap.NavigationControl());// 添加平移缩放控件
map.addControl(new BMap.ScaleControl());// 添加比例尺控件

var myP1 = new BMap.Point(104.00196991099213,30.66303060965564);  //声明点对象
var myP2 = new BMap.Point(104.08361395495325,30.668530635551743);
var myP3 = new BMap.Point(104.07724026537839,30.606050194579222);
// 创建点坐标
map.centerAndZoom(myP1 , 15);
// 初始化地图，设置中心点坐标和地图级别
map.clearOverlays();    //清空地图中的对象
var marker1 = new BMap.Marker(myP1);   //定义点样式，默认为红色水滴形状
var marker2 = new BMap.Marker(myP2);
var marker3 = new BMap.Marker(myP3);
map.addOverlay(marker1);   //添加点到地图
map.addOverlay(marker2);
map.addOverlay(marker3);
</script>
</body>
</html>
```



