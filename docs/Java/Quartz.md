---
title: Quartz
date: 2022-03-23 15:55:26
categories:
- Quartz
tags:
- Quartz
---

# Quartz

### 1、Quartz使用

#### 1.1 核心类说明

**Scheduler**: 调度器。所有的调度都是由它控制，是Quartz的大脑，所有任务都是由它来管理

**Job**: 任务，想定时执行的事情(定义业务逻辑)

**JobDetail**: 基于Job，进一步包装。其中关联一个Job，并为Job指定更详细的属性，比如标识等

**Trigger**: 触发器。可以指定给某个任务，指定任务的触发机制。

#### 1.2 创建项目

创建Maven项目

配置GroupId和ArtifactId

#### 1.3导入依赖

在pom.xml中引入如下依赖：

```xml
<!--Quartz任务调度-->
<!-- https://mvnrepository.com/artifact/org.quartz-scheduler/quartz -->
<dependency>
    <groupId>org.quartz-scheduler</groupId>
    <artifactId>quartz</artifactId>
    <version>2.2.3</version>
</dependency>
```

#### 1.4 定义Job

在src目录创建一个类，命名为 HelloQuartz，实现Job接口。

```java
public class HelloQuartz implements Job{

    // 执行
    @Override
    public void execute(JobExecutionContext context) throws JobExecutionException {
        // 创建工作详情
        JobDetail jobDetail = context.getJobDetail();

        JobKey key = jobDetail.getKey();
        System.out.println(key.getName());// 任务名
        System.out.println(key.getGroup()); // 任务group
        System.out.println("hello job exec " + new Date());
    }
}
```

#### 1.5 API测试

在HelloQuartz中书写main方法，在main方法中首先创建一个Scheduler对象，然后创建Trigger和JobDetail对象，并将Trigger对象和JobDetail对象增加到调度器中；最后启动调度器。

```java
public static void main(String[] args) {
    TimeZone.setDefault(TimeZone.getTimeZone("GMT+8"));
    try {
        // quartz API
        // 1. 调度器Scheduler
        Scheduler scheduler = StdSchedulerFactory.getDefaultScheduler();

        // 2. 触发器：
        Trigger trigger = TriggerBuilder.newTrigger()
            .withIdentity("trigger1", "group1")
            .startNow()
            .withSchedule(SimpleScheduleBuilder.simpleSchedule()
                          .withIntervalInSeconds(1)//每隔1s执行一次
                          .repeatForever())// 一直执行，直到结束时间
            .endAt(new GregorianCalendar(2023, 0, 6, 14, 0, 0).getTime())
            .build();

        // 3. JobDetail
        // 定义Job类为HelloQuartz类，这是真正的执行逻辑所在
        JobDetail jobDetail = JobBuilder.newJob(HelloQuartz.class)
            .withIdentity("job1", "group1")
            .build();

        // 4. 将 JobDetail 和触发器 增加到调度器中
        scheduler.scheduleJob(jobDetail, trigger);

        // 5. 启动，调度器开始工作
        scheduler.start();
    } catch (SchedulerException e) {
        throw new RuntimeException(e);
    }
}
```

#### 1.6 配置

在resource文件夹内创建配置文件quartz.properties，放置在classpath下，如果没有此配置则按默认配置启动。

```properties
# 指定调度器名称，非实现类
org.quartz.scheduler.instanceName = DefaultQuartzScheduler
# 指定线程池实现类
org.quartz.threadPool.class = org.quartz.simpl.SimpleThreadPool
# 线程池线程数量
org.quartz.threadPool.threadCount = 10 
# 优先级，默认5
org.quartz.threadPool.threadPriority = 5
# 非持久化job
org.quartz.jobStore.class = org.quartz.simpl.RAMJobStore
```

配置完成后，启动程序。

### 2、Trigger

#### 2.1 SimpleTrigger

以一定的时间间隔(单位是毫秒) 执行的任务。

##### 指定起始和截止时间(时间段)

如：让Job每隔1s执行一次， 一直执行，直到结束时间。修改触发器配置如下

```java
Trigger trigger = TriggerBuilder.newTrigger()
    .withIdentity("trigger1", "group1")
    .startNow()
    .withSchedule(SimpleScheduleBuilder.simpleSchedule()
                  .withIntervalInSeconds(1)//每隔1s执行一次
                  .repeatForever())// 一直执行，直到结束时间
    .endAt(new GregorianCalendar(2023, 0, 6, 14, 0, 0).getTime())
    .build();
```

##### 指定时间间隔、执行次数

如：让Job每隔3s执行一次，执行次数不超过3次。修改触发器配置如下

```java
Trigger trigger = TriggerBuilder.newTrigger()
.withIdentity("trigger1", "group1")
.startNow()
.withSchedule(SimpleScheduleBuilder.simpleSchedule()
.withIntervalInMinutes(3)//每隔3s执行一次
.withRepeatCount(3))// 执行次数不超过3次
.endAt(new GregorianCalendar(2023, 0, 6, 14, 0, 0).getTime())
.build();
```

#### 2.2 CronTrigger\[ 重点 \]

适合于更复杂的任务，它支持类型于Linux Cron的语法 (并且更强大)

*   指定Cron表达式即可

如：设置触发器 每天10:00-12:00, 每隔2分钟执行一次，修改触发器配置如下

```java
CronTrigger trigger = TriggerBuilder.newTrigger()
.withIdentity("trigger1", "group1")
.withSchedule(CronScheduleBuilder.cronSchedule("0 0/2 10-12 * * ?"))
.build();
```



> 整理自千峰学习站
