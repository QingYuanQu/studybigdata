---
title: Spark Python QA
date: 2022-03-23 15:55:26
categories:
- PySpark
---

# Spark Python QA

## Q: PySpark: java.lang.OutofMemoryError: Java heap space

```java
PySpark: java.lang.OutofMemoryError: Java heap space
```

##### A

```python
    spark_conf.setAppName("recommend").setMaster("local[*]").set('spark.executor.memory', '12g').set('spark.driver.memory', '14g')
```



---



## Q:  Please install psutil to have better support with spilling

```
UserWarning: Please install psutil to have better support with spilling
```

##### A

```shell
pip install psutil
```



---



## Q: {0}.{1} does not exist in the JVM

```shell
"{0}.{1} does not exist in the JVM".format(self._fqn, name))
```

##### A

```shell
pyspark 与spark版本不对
```



---



## Q: Python worker failed to connect back

```java
22/06/16 12:20:00 WARN TaskSetManager: Lost task 1.0 in stage 0.0 (TID 1) (192.168.3.96 executor 0): org.apache.spark.SparkException: Python worker failed to connect back.
	at org.apache.spark.api.python.PythonWorkerFactory.createSimpleWorker(PythonWorkerFactory.scala:188)
	at org.apache.spark.api.python.PythonWorkerFactory.create(PythonWorkerFactory.scala:108)
	at org.apache.spark.SparkEnv.createPythonWorker(SparkEnv.scala:121)
	at org.apache.spark.api.python.BasePythonRunner.compute(PythonRunner.scala:162)
	at org.apache.spark.api.python.PythonRDD.compute(PythonRDD.scala:65)
	at org.apache.spark.rdd.RDD.computeOrReadCheckpoint(RDD.scala:373)
	at org.apache.spark.rdd.RDD.iterator(RDD.scala:337)
	at org.apache.spark.scheduler.ResultTask.runTask(ResultTask.scala:90)
	at org.apache.spark.scheduler.Task.run(Task.scala:131)
	at org.apache.spark.executor.Executor$TaskRunner.$anonfun$run$3(Executor.scala:506)
	at org.apache.spark.util.Utils$.tryWithSafeFinally(Utils.scala:1462)
```

##### A

```shell
PYSPARK_PYTHON=D:\ProgramData\Anaconda3\python.exe
PYSPARK_DRIVER_PYTHON=D:\ProgramData\Anaconda3\python.exe
```

