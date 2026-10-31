---
title: Maven
date: 2022-03-23 15:55:26
categories:
- Maven
---

# Maven

> **下载地址**
>
> https://dlcdn.apache.org/maven/maven-3/3.8.4/binaries/apache-maven-3.8.4-bin.zip
>
> **学习Maven**
>
> https://maven.apache.org/guides/getting-started/maven-in-five-minutes.html



## 配置文件

##### settings.xml

```xml
< !--远程仓库地址-- >
<mirror>
    <id>alimaven</id>
    <name>aliyun maven</name>
    <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
    <mirrorOf>central</mirrorOf>        
</mirror>
    
< !--本地仓库-- >
<localRepository>D:\maven-repo</localRepository>
```





## Plugins

##### maven-jar-plugin

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-jar-plugin</artifactId>
    <version>2.6</version>
    <configuration>
        <archive>
            <manifest>
                <mainClass>com.studybigdata.hadoop.mapred.DepartSalaryMain</mainClass>
            </manifest>
        </archive>
    </configuration>
</plugin>
```



##### maven-shade-plugin

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-shade-plugin</artifactId>
    <version>2.4.3</version>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <goal>shade</goal>
            </goals>
            <configuration>
                <transformers>
                    <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                       <mainClass>com.studybigdata.hadoop.mapred.WordCountMain</mainClass>
                    </transformer>
                </transformers>
            </configuration>
        </execution>
    </executions>
</plugin>
```





## 五分钟了解Maven

https://maven.apache.org/guides/getting-started/maven-in-five-minutes.html



### 创建项目

```shell
mvn archetype:generate -DgroupId="com.studybigdata.app" -DartifactId="my-app" -DarchetypeArtifactId="maven-archetype-quickstart" -DarchetypeVersion="1.4" -DinteractiveMode="false"
```





#### QA

##### Question1

```powershell
PS D:\myapp> mvn archetype:generate -DgroupId=com.mycompany.app -DartifactId=my-app -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.4 -DinteractiveMode=false
[INFO] Scanning for projects...
[INFO] ------------------------------------------------------------------------
[INFO] BUILD FAILURE
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  0.113 s
[INFO] Finished at: 2022-05-29T07:49:49+08:00
[INFO] ------------------------------------------------------------------------
[ERROR] The goal you specified requires a project to execute but there is no POM in this directory (D:\myapp). Please verify you invoked Maven from the correct directory. -> [Help 1]
[ERROR]
[ERROR] To see the full stack trace of the errors, re-run Maven with the -e switch.
[ERROR] Re-run Maven using the -X switch to enable full debug logging.
[ERROR]
[ERROR] For more information about the errors and possible solutions, please read the following articles:
[ERROR] [Help 1] http://cwiki.apache.org/confluence/display/MAVEN/MissingProjectException
```

##### Answer1

```http
https://stackoverflow.com/questions/17385864/why-does-not-archetypegenerate-with-parameters-work-for-me
# 在Windows shell中创建maven项目时，参数值加引号
```

