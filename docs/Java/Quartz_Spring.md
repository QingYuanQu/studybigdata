---
title: Spring整合Quartz
date: 2022-03-23 15:55:26
categories:
- Quartz
tags:
- Quartz
---

# Spring整合Quartz

### 1\. 引入相关依赖

引入Spring和Quartz相关依赖

```xml
<properties>
    <springframework.version>5.1.6.RELEASE</springframework.version>
    <quartz.version>2.2.3</quartz.version>
</properties>

<dependencies>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-context-support</artifactId>
        <version>${springframework.version}</version>
    </dependency>

    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-tx</artifactId>
        <version>${springframework.version}</version>
    </dependency>

    <dependency>
        <groupId>org.quartz-scheduler</groupId>
        <artifactId>quartz</artifactId>
        <version>${quartz.version}</version>
    </dependency>
</dependencies>
```

### 2\. 定义Job

定义一个Job类，该Job在控制台打印一个包含日期的字符串。

```java
public class MyJob implements Job {
    // 执行
    @Override
    public void execute(JobExecutionContext context) throws JobExecutionException {
        System.out.println("job exec " + new Date());
    }
}
```

### 3\. 配置

Spring整合Quartz进行配置遵循下面的步骤：

1.  定义工作任务的JobDetail
2.  定义触发器Trigger，并将触发器与工作任务绑定
3.  定义调度器，并将Trigger注册到Scheduler

在resource目录中创建配置文件，命名为 applicationContext.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">
    <!-- 1：定义任务的bean ，这里使用JobDetailFactoryBean,也可以使用MethodInvokingJobDetailFactoryBean ，配置类似-->
    <bean name="lxJob" class="org.springframework.scheduling.quartz.JobDetailFactoryBean">
        <!-- 指定job的名称 -->
        <property name="name" value="job1"/>
        <!-- 指定job的分组 -->
        <property name="group" value="job_group1"/>
        <!-- 指定具体的job类 -->
        <property name="jobClass" value="MyJob"/>
    </bean>

    <!-- 2：定义触发器的bean，定义一个Cron的Trigger，一个触发器只能和一个任务进行绑定 -->
    <bean id="cronTrigger" class="org.springframework.scheduling.quartz.CronTriggerFactoryBean">
        <!-- 指定Trigger的名称 -->
        <property name="name" value="trigger1"/>
        <!-- 指定Trigger的名称 -->
        <property name="group" value="trigger_group1"/>
        <!-- 指定Tirgger绑定的JobDetail -->
        <property name="jobDetail" ref="lxJob"/>
        <!-- 指定Cron 的表达式 ，当前是每隔5s运行一次 -->
        <property name="cronExpression" value="* * * * * ?" />
    </bean>

    <!-- 3.定义调度器，并将Trigger注册到调度器中 -->
    <bean id="scheduler" class="org.springframework.scheduling.quartz.SchedulerFactoryBean">
        <property name="triggers">
            <list>
                <ref bean="cronTrigger"/>
            </list>
        </property>
        <!-- 添加 quartz 配置，如下两种方式均可 -->
        <!--<property name="configLocation" value="classpath:quartz.properties"></property>-->
        <property name="quartzProperties">
            <value>
                # 指定调度器名称，实际类型为：QuartzScheduler
                org.quartz.scheduler.instanceName = MyScheduler
                # 指定线程池
                org.quartz.threadPool.class = org.quartz.simpl.SimpleThreadPool
                # 线程池线程数量
                org.quartz.threadPool.threadCount = 11
                # 优先级
                org.quartz.threadPool.threadPriority = 5
                # 不持久化job
                org.quartz.jobStore.class = org.quartz.simpl.RAMJobStore
            </value>
        </property>
    </bean>
</beans>
```

### 4\. 操作

创建类 QuartzTest，在此类中书写相关操作代码。

#### 4.1 启动任务

ClassPathXmlApplicationContext读取xml文件，完成Bean信息的装载，调度器启动，任务调度开始。

```java
public static void main(String[] args) throws InterruptedException, SchedulerException {
        ApplicationContext context = new ClassPathXmlApplicationContext("applicationContext.xml");
}
```

#### 4.2 任务操作

##### 4.2.1 删除任务

调度器根据group和JobKey name，删除Job。

```java
public static void main(String[] args) throws InterruptedException, SchedulerException {
    ApplicationContext context = new ClassPathXmlApplicationContext("applicationContext.xml");
    System.out.println("==============");
    
    StdScheduler stdScheduler = (StdScheduler) context.getBean("scheduler");
    Thread.sleep(3000);
    // 任务删除
    stdScheduler.deleteJob(JobKey.jobKey("job1", "job_group1"));
}
```

##### 4.2.2 暂停、恢复

调度器根据group和JobKey name，暂停、恢复Job。

```java
public static void main(String[] args) throws InterruptedException, SchedulerException {
    ApplicationContext context = new ClassPathXmlApplicationContext("applicationContext.xml");
    System.out.println("==============");
    StdScheduler stdScheduler = (StdScheduler) context.getBean("scheduler");

    // Job暂停
    stdScheduler.pauseJob(JobKey.jobKey("job1", "job_group1"));
    Thread.sleep(3000);
    // Job恢复
    stdScheduler.resumeJob(JobKey.jobKey("job1", "job_group1"));
}
```

##### 4.2.3 批量操作

调度器根据group，查询group中的所有Job，批量操作Job，如：暂停、恢复Job。

```java
public static void main(String[] args) throws InterruptedException, SchedulerException {
    ApplicationContext context = new ClassPathXmlApplicationContext("applicationContext.xml");
    System.out.println("==============");
    StdScheduler stdScheduler = (StdScheduler) context.getBean("scheduler");
    System.out.println(stdScheduler.getClass());

    GroupMatcher<JobKey> group1 = GroupMatcher.groupEquals("job_group1");
    // 批量操作
    stdScheduler.pauseJobs(group1); // 暂停组中所有Job
    Thread.sleep(3000);
    stdScheduler.resumeJobs(group1); // 恢复组中所有Job
}
```

> 整理自千峰学习站
