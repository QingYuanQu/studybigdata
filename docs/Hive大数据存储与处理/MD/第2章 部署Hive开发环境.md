---
marp: true
headingDivider: 6
theme: python-mini-pptx
---



# 部署开发环境

### 任务背景
为实现国家现代化，在新时代、新阶段企业必须坚持高质量发展。随着大数据技术的不断演进，目前Hive已成为企业广泛使用的数据仓库，其底层实现是调用MapReduce程序，Hive调度资源时，使用的是Hadoop的YARN框架。
Hive将结构化的数据文件映射成一张虚表，并提供类SQL（HQL）查询功能。有了Hive后，程序员不用再编写复杂的MapReduce程序，通过Hive即可使用类SQL语句实现数据的快速统计，进而提高大数据处理和分析效率。
本章将介绍如何安装部署Hadoop集群、如何安装部署Hive、Hive CLI的使用方法，为后续实现广电大数据存储和处理搭建环境。

安装部署Hadoop集群
安装部署Hive

使用Hive CLI

### 任务描述
通过Hadoop分布式框架可以轻松地通过将数千台服务器联合在一起对大数据进行存储和计算，而且每一台服务器都具有存储和计算的能力。
用户可以在不了解Hadoop底层细节的情况下开发分布式程序，能够十分方便地利用集群的强大能力进行程序运算，而且能够解决高可用（分布式系统架构设计中的一个常见指标，意指通过设计减少系统不能提供服务的时间，从而保持其服务的高度可用性）问题。
本任务的内容包括虚拟机VMware Workstation（简称VMware）、Hadoop集群的部署过程，以及远程终端Xshell软件的安装和使用，为Hive的安装部署提供一个基础的集群环境。

```bash
./start-dfs.sh
./start-yarn.sh
./mr-jobhistory-daemon.sh start historyserver
```

```bash
export HADOOP_HOME=/usr/local/hadoop-3.1.4
export PATH=$HADOOP_HOME/bin:$PATH
export HDFS_NAMENODE_USER=root
export HDFS_DATANODE_USER=root
export HDFS_JOURNALNODE_USER=root
export HDFS_SECONDARYNAMENODE_USER=root
export YARN_RESOURCEMANAGER_USER=root
export YARN_NODEMANAGER_USER=root
```

```bash
scp -r /usr/local/hadoop-3.1.4 slave1:/usr/local
scp -r /usr/local/hadoop-3.1.4 slave2:/usr/local
scp -r /usr/local/hadoop-3.1.4 slave3:/usr/local
```

```bash
slave1
slave2
slave3
```

```bash
export JAVA_HOME=/usr/java/jdk1.8.0_221-amd64
```

```xml
<configuration>
  <property>
    <name>yarn.resourcemanager.hostname</name>
    <value>master</value>
  </property>    
  <property>
    <name>yarn.resourcemanager.address</name>
    <value>${yarn.resourcemanager.hostname}:8032</value>
  </property>
  <property>
    <name>yarn.resourcemanager.scheduler.address</name>
    <value>${yarn.resourcemanager.hostname}:8030</value>
  </property>
  <property>
    <name>yarn.resourcemanager.webapp.address</name>
    <value>${yarn.resourcemanager.hostname}:8088</value>
  </property>
  <property>
    <name>yarn.resourcemanager.webapp.https.address</name>
    <value>${yarn.resourcemanager.hostname}:8090</value>
  </property>
  <property>
    <name>yarn.resourcemanager.resource-tracker.address</name>
    <value>${yarn.resourcemanager.hostname}:8031</value>
  </property>
  <property>
    <name>yarn.resourcemanager.admin.address</name>
    <value>${yarn.resourcemanager.hostname}:8033</value>
  </property>
  <property>
    <name>yarn.nodemanager.local-dirs</name>
    <value>/data/hadoop/yarn/local</value>
  </property>
  <property>
    <name>yarn.log-aggregation-enable</name>
    <value>true</value>
  </property>
  <property>
    <name>yarn.nodemanager.remote-app-log-dir</name>
    <value>/data/tmp/logs</value>
  </property>
<property> 
 <name>yarn.log.server.url</name> 
 <value>http://master:19888/jobhistory/logs/</value>
 <description>URL for job history server</description>
</property>
<property>
   <name>yarn.nodemanager.vmem-check-enabled</name>
    <value>false</value>
  </property>
 <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>
  <property>
    <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
      <value>org.apache.hadoop.mapred.ShuffleHandler</value>
      </property>
<property>  
        <name>yarn.nodemanager.resource.memory-mb</name>  
        <value>2048</value>  
 </property>  
 <property>  
        <name>yarn.scheduler.minimum-allocation-mb</name>  
        <value>512</value>  
 </property>   
 <property>  
        <name>yarn.scheduler.maximum-allocation-mb</name>  
        <value>4096</value>  
 </property> 
 <property> 
    <name>mapreduce.map.memory.mb</name> 
    <value>2048</value> 
 </property> 
 <property> 
    <name>mapreduce.reduce.memory.mb</name> 
    <value>2048</value> 
 </property> 
 <property> 
    <name>yarn.nodemanager.resource.cpu-vcores</name> 
    <value>1</value> 
 </property>
 <property>
        <name>yarn.application.classpath</name>
        <value>/usr/local/hadoop-3.1.4/etc/hadoop:/usr/local/hadoop-3.1.4/share/hadoop/common/lib/*:/usr/local/hadoop-3.1.4/share/hadoop/common/*:/usr/local/hadoop-3.1.4/share/hadoop/hdfs:/usr/local/hadoop-3.1.4/share/hadoop/hdfs/lib/*:/usr/local/hadoop-3.1.4/share/hadoop/hdfs/*:/usr/local/hadoop-3.1.4/share/hadoop/mapreduce/lib/*:/usr/local/hadoop-3.1.4/share/hadoop/mapreduce/*:/usr/local/hadoop-3.1.4/share/hadoop/yarn:/usr/local/hadoop-3.1.4/share/hadoop/yarn/lib/*:/usr/local/hadoop-3.1.4/share/hadoop/yarn/*</value>
</property>
</configuration>
```

```xml
<configuration>
<property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
</property>
<!-- jobhistory properties -->
<property>
    <name>mapreduce.jobhistory.address</name>
    <value>master:10020</value>
</property>
<property>
     <name>mapreduce.jobhistory.webapp.address</name>
     <value>master:19888</value>
</property>
</configuration>
```

```xml
<configuration>
<property>
    <name>dfs.namenode.name.dir</name>
    <value>file:///data/hadoop/hdfs/name</value>
</property>
<property>
    <name>dfs.datanode.data.dir</name>
    <value>file:///data/hadoop/hdfs/data</value>
</property>
<property>
     <name>dfs.namenode.secondary.http-address</name>
     <value>master:9868</value>     ##（旧端口：50090）
</property>
<property>
     <name>dfs.replication</name>
     <value>3</value>
</property>
</configuration>
```

```bash
export JAVA_HOME=/usr/java/jdk1.8.0_221-amd64  #目录依据安装版本不同而有所不同
```

```xml
<configuration>
     <property>
             <name>fs.defaultFS</name>
             <value>hdfs://master:9820</value>       ##（旧端口：8020）
     </property>
     <property>
             <name>hadoop.tmp.dir</name>
             <value>/var/log/hadoop/tmp</value>
             <description>Abase for other temporary directories.</description>
     </property>
</configuration>
```

```bash
export  JAVA_HOME=/usr/java/jdk1.8.0_221-amd64
export  PATH=$PATH:$JAVA_HOME/bin
```

### VMware虚拟机安装和网络设置

```bash
server  master
```

```bash
restrict  192.168.128.2  mask  255.255.255.0  nomodify  notrap
server  127.127.1.0
fudge  127.127.1.0  stratum  10
```

```bash
ssh-copy-id -i  /root/.ssh/id_rsa.pub  master   //依次输入yes，123456（root用户的登录密码）
ssh-copy-id -i  /root/.ssh/id_rsa.pub  slave1
ssh-copy-id -i  /root/.ssh/id_rsa.pub  slave2
ssh-copy-id -i  /root/.ssh/id_rsa.pub  slave3
```

```bash
192.168.128.130 master master.centos.com
192.168.128.131 slave1 slave1.centos.com
192.168.128.132 slave2 slave2.centos.com
192.168.128.133 slave3 slave3.centos.com
```

```bash
192.168.128.130  master
192.168.128.131  slave1
192.168.128.132  slave2
192.168.128.133  slave3
```

```bash
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
IPADDR=192.168.128.130
NETMASK=255.255.255.0
GATEWAY=192.168.128.2
DNS1=192.168.128.2
```
Hadoop集群环境是由若干台Linux主机组成的（为了更好地体现集群的特点和优势，建议部署至少3台主机，主机的系统可采用Ubuntu或CentOS）。
本书将在Windows环境下安装虚拟机软件VMware Workstation 15.5 Pro（Windows 7环境下VMware Workstation最高支持15.x版本，如需升级16版本或更高版本，则需要在Windows 8或以上版本的环境下），以便虚拟机的创建与配置。
VMware Workstation是由VMware公司出品的一款桌面虚拟机软件，可帮助用户在单一的桌面上同时运行不同的操作系统，具有应用开发、测试、部署等诸多功能。

### 任务描述
Hive可以将结构化的数据文件映射为数据库表，并可提供简单的HQL查询功能。Hive可将HQL语句转换为MapReduce任务执行。
Hive需要将元数据保存到数据库Derby或MySQL中，并配置相应服务，因此本任务主要介绍Hive元数据存储，同时完成MySQL的安装和配置、Hive的安装和配置。

### 安装配置MySQL
为实现多用户连接，Hive需要将元数据存储在关系数据库中，故需要安装和配置MySQL。MySQL安装和配置的简要步骤如下。
查找系统适用的MySQL版本。执行 “yum search mysql”命令，搜索找到当前系统适用的版本为mysql-server.x86_64。

```bash
[c6-media]
name=CentOS-$releasever - Media
baseurl=file:///media/
gpgcheck=0
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
```

```bash
mv  CentOS-Base.repo  CentOS-Base.repo.bak
mv  CentOS-Debuginfo.repo  CentOS-Debuginfo.repo.bak
mv  CentOS-fasttrack.repo  CentOS-fasttrack.repo.bak
mv  CentOS-Vault.repo  CentOS-Vault.repo.bak 
ll
```
安装MySQL。执行“mount  /dev/dvd  /media”命令绑定镜像文件到目录，再执行“yum install mysql-server.x86_64  -y” 命令安装MySQL。
设置开机自动启动MySQL服务。执行“service mysqld start”“chkconfig mysqld on”命令，设置开机自动启动MySQL服务。
设置MySQL管理员账号及密码。首先启动MySQL远程终端，直接在终端输入“mysql”即可，然后设置MySQL管理员账号及密码并刷新配置。

```hive
USE mysql;
DELETE FROM user WHERE 1=1;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

### 安装配置Hive
Hive的安装和配置主要集中在master主机，如无特别说明，操作默认在master主机进行。安装和配置Hive的过程如下。
上传安装包并解压。将安装包apache-hive-3.1.2-bin.tar.gz通过Xftp上传到master主机的/opt/目录下，执行“tar -zxf /opt/apache-hive-3.1.2-bin.tar.gz -C /usr/local”命令，解压安装包至/usr/local目录下。
重命名文件。执行“mv /usr/local/apache-hive-3.1.2-bin /usr/local/hive-3.1.2”命令，将文件apache-hive-3.1.2-bin重命名为hive-3.1.2。
在MySQL中新建hive数据库。

```hive
[root@master conf]# mysql -uroot -p123456
mysql> CREATE DATABASE hive;
mysql> quit;
```在MySQL中新建hive数据库，然后退出MySQL。

修改配置文件hive-site.xml。执行 “vi /usr/local/hive-3.1.2/conf/hive-site.xml” 命令创建hive-site.xml文件。

```xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>javax.jdo.option.ConnectionURL</name>
    <value>jdbc:mysql://master:3306/hive?createDatabaseIfNotExist=true</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionDriverName</name>
    <value>com.mysql.jdbc.Driver</value>  //MySQL 8.0以上版本驱动为com.mysql.cj.jdbc.Driver
  </property>
  <property>
    <name>javax.jdo.PersistenceManagerFactoryClass</name>
    <value>org.datanucleus.api.jdo.JDOPersistenceManagerFactory</value>
  </property>
  <property>
    <name>javax.jdo.option.DetachAllOnCommit</name>
    <value>true</value>
  </property>
  <property>
    <name>javax.jdo.option.NonTransactionalRead</name>
    <value>true</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionUserName</name>
    <value>root</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionPassword</name>
    <value>123456</value>
  </property>
  <property>
    <name>javax.jdo.option.Multithreaded</name>
    <value>true</value>
  </property>
  <property>
    <name>datanucleus.connectionPoolingType</name>
    <value>BoneCP</value>
  </property>
  <property>
    <name>hive.metastore.warehouse.dir</name>
    <value>/user/hive/warehouse</value>
  </property>
  <property>
    <name>hive.server2.thrift.port</name>
    <value>10000</value>
  </property>
  <property>
    <name>hive.server2.thrift.bind.host</name>
    <value>master</value>
  </property>
  <property>
    <name>hive.metastore.uris</name>
    <value>thrift://master:9083</value>
  </property>
  <property>
    <name>system:java.io.tmpdir</name>
    <value>/usr/local/hive-3.1.2/bin/hive-data/tmp</value> //需额外创建此目录
  </property>
  <property>
    <name>system:user.name</name>
    <value>root</value>
  </property>
</configuration>
```
加载MySQL驱动包至Hive目录。加载MySQL驱动包mysql-connector-java-
5.1.30.jar到/usr/local/hive-3.1.2/lib目录。
解决JAR包版本冲突问题。删除较低版本的guava JAR包，并复制Hadoop目录下较高版本的JAR包到Hive安装目录的lib目录下。

```bash
rm -rf /usr/local/hive-3.1.2/lib/guava-14.0.1.jar
rm -rf /usr/local/hive-3.1.2/lib/guava-19.0.jar
cp /usr/local/hadoop-3.1.4/share/hadoop/common/lib/guava-27.0-jre.jar /usr/local/hive-3.1.2/lib/
```

添加系统环境变量。执行“vi /etc/profile”命令，添加Hive安装目录到环境变量。修改完成并保存退出后执行“source  /etc/profile”命令使系统环境变量生效。

```bash
export HIVE_HOME=/usr/local/hive-3.1.2
export PATH=$HIVE_HOME/bin:$PATH
```
初始化元数据库。进入Hive安装目录的bin子目录，执行 “./schematool -dbType mysql -initSchema” 命令，执行结果如下图，表示元数据库初始化成功。

![图片60](图片1.jpg)

启动Hive Metastore服务。在Hadoop集群已启动的情况下，由于在hive-site.xml配置文件中指定了hive.metastore.uris的端口，故执行 “hive --service metastore &” 命令即可启动Hive Metastore服务。

```bash
cd /usr/local/hadoop-3.1.4/sbin   //对Hadoop目录依据安装版本做相应调整
./stop-all.sh     //如有服务未停，可先停服务
./start-dfs.sh
./start-yarn.sh
mapred --daemon start historyserver
hive --service metastore &  //启动Hive Metastore服务
jps    //显示进程列表，正常情况下有5个进程运行
hive       //进入Hive CLI
```
启动Hive Metastore服务后，即可支持多个客户端同时访问元数据，且多个客户端不需要知道MySQL数据库的用户名和密码。
启动HiveServer2服务。可执行“nohup hive --service hiveserver2 &”命令启动HiveServer2服务。HiveServer2是一种能使客户端执行Hive查询的服务。HiveServer2是HiveServer的改进版，HiveServer已经被废弃。
HiveServer2可以支持多客户端并发和身份认证，旨在为开放API客户端（如JDBC和ODBC）提供更好的支持，后续章节可能会用到此服务。

### 任务描述
Hive CLI是客户端与Hive进行交互的3种主要方式之一。
在使用Hive的过程中，用户可以不退出Hive，在Hive CLI里执行Linux Shell命令和Hadoop dfs命令，以方便在实践中简单查询。
在Linux Shell界面里也可以执行Hive的脚本文件完成建表、查询等任务。
本任务的内容是学习如何启动Hive CLI，如何在Hive中执行Bash Shell命令、Hadoop dfs命令，以及如何在Shell中执行Hive查询。

### 启动Hive CLI
Hive可提供命令行界面，即CLI，执行 “hive --help” 命令可列出Hive命令行选项的说明，如下图。

![图片61](图片1.jpg)

启动Hive和使用Hive CLI的说明如下。
启动Hive。要执行Hive命令首先要启动Hive Metastore服务，而启动Hive Metastore服务前须先启动Hadoop集群，进入Hive CLI，如下图。

![图片62](图片2.jpg)

查看后台服务情况。执行命令“jps”可查看后台服务情况，master主机进程列表如左图，slave1主机进程列表如右图。

![图片63](图片1.jpg)

![图片64](图片3.jpg)

### 在Hive中执行Bash Shell和Hadoop dfs命令
在Hive CLI中，用户无须退出即可执行Bash Shell命令和Hadoop dfs命令。
在Hive CLI中执行Base Shell的命令。在Bash Shell命令前加上感叹号并且以分号结尾，例如，在Hive CLI中执行的“pwd”和“ls  /”命令分别为“!pwd;”和“!ls  /;”，如下图。注意“!”和“;”必须使用半角格式。

![图片65](图片2.jpg)

在Hive CLI中执行Hadoop dfs命令。将Hadoop命令中的关键字“hadoop”去掉，然后以分号结尾，例如，查看HDFS根目录文件情况，如下图。

![图片66](图片1.jpg)

### 在Shell中执行Hive查询
在Linux的Shell中也可以执行Hive查询，主要通过“hive -e”“hive -f”命令实现。
在Shell下执行“hive -e”命令。

```hive
// 设置zjsm为当前数据库，并查询其中media_index表的前3行数据
hive -e "USE zjsm; SELECT * FROM media_index LIMIT 3;";  
```Hive允许在不启动Hive CLI的情况下，直接执行HQL查询命令。
例如，查询数据库zjsm中media_index表的前3行数据，执行结果如下图。

![图片67](图片2.jpg)

通过-S选项开启静默模式，省略“OK”“Time taken”等提示，直接将结果保存至指定文件中。
修改代码，添加参数“-S”，查询数据库zjsm中media_index表的前3行数据并将结果保存至/tmp/testquery，，执行结果如下图。

![图片68](图片1.jpg)

在文件中执行Hive查询。在Hive中可以使用“-f文件名”方式执行指定文件中的一个或多个查询语句，一般将Hive查询文件保存为具有.q或.hq1扩展名的文件。

```bash
hive -f  /opt/testQuery.hql;
```
例如，将代码中的查询语句保存至/opt/testQuery.hql，并执行该文件，执行结果如下图。

![图片67](图片2.jpg)

### 小结
本章首先阐述了将Hive作为广电大数据项目的数据仓库，由此对当前市场上常用虚拟机平台工具VMware Workstation进行了介绍。
接着对如何一步一步部署大数据基础平台进行了介绍，并从Hadoop集群的部署、MySQL数据库的安装和配置、Hive的安装和配置及启动、Hive CLI的使用方法等方面进行了详细讲解。
