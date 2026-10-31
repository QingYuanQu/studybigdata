---
title: Linux打包解压
date: 2023-01-14 15:55:26
categories:
- Linux
tags:
- Linux打包解压
marp: true
---

## 打包解压

#### 打包与解包：tar

```shell
# 创建三个文件
[zhangsan@localhost test]$ touch hadoop.txt
[zhangsan@localhost test]$ touch spark.txt
[zhangsan@localhost test]$ touch readme.md

# 查看创建的三个文件的详细信息
[zhangsan@localhost test]$ ll
total 0
-rw-rw-r--. 1 zhangsan zhangsan 0 Nov  8 07:21 hadoop.txt
-rw-rw-r--. 1 zhangsan zhangsan 0 Nov  8 07:21 readme.md
-rw-rw-r--. 1 zhangsan zhangsan 0 Nov  8 07:21 spark.txt

# 把三个文件打包成file.tar
[zhangsan@localhost test]$ tar -cvf file.tar hadoop.txt readme.md spark.txt 
hadoop.txt
readme.md
spark.txt

# 可以看到打包的文件file.tar
[zhangsan@localhost test]$ ll
total 12
-rw-rw-r--. 1 zhangsan zhangsan 10240 Nov  8 07:22 file.tar
-rw-rw-r--. 1 zhangsan zhangsan     0 Nov  8 07:21 hadoop.txt
-rw-rw-r--. 1 zhangsan zhangsan     0 Nov  8 07:21 readme.md
-rw-rw-r--. 1 zhangsan zhangsan     0 Nov  8 07:21 spark.txt

# 查看file.tar中的内容，里面包含三个文件
[zhangsan@localhost test]$ tar -tf file.tar 
hadoop.txt
readme.md
spark.txt

# 删除掉打包前的源文件，为了下一步解压
[zhangsan@localhost test]$ rm -rf hadoop.txt readme.md spark.txt 

# 此时test文件夹下面只有file.tar文件
[zhangsan@localhost test]$ ll
total 12
-rw-rw-r--. 1 zhangsan zhangsan 10240 Nov  8 07:22 file.tar

# 解包file.tar
[zhangsan@localhost test]$ tar -xvf file.tar 
hadoop.txt
readme.md
spark.txt

# 查看解包结果
[zhangsan@localhost test]$ ll
total 12
-rw-rw-r--. 1 zhangsan zhangsan 10240 Nov  8 07:22 file.tar
-rw-rw-r--. 1 zhangsan zhangsan     0 Nov  8 07:21 hadoop.txt
-rw-rw-r--. 1 zhangsan zhangsan     0 Nov  8 07:21 readme.md
-rw-rw-r--. 1 zhangsan zhangsan     0 Nov  8 07:21 spark.txt

# 创建一个新文件hbase.txt，并把它添加到file.tar包中
[zhangsan@localhost test]$ touch hbase.txt
# r --append 追加到tar包中
hangsan@localhost test]$ tar -rvf file.tar hbase.txt 
hbase.txt

# 查看追加结果
[zhangsan@localhost test]$ tar -tf file.tar 
hadoop.txt
readme.md
spark.txt
hbase.txt

# 删除tar包内的某个文件
[zhangsan@localhost test]$ tar --delete hbase.txt -vf file.tar 
[zhangsan@localhost test]$ tar -tf file.tar 
hadoop.txt
readme.md
spark.txt
```

#### 压缩与解压：gzip

```shell
# 当前目录下有hello.txt文件
[zhangsan@localhost test]$ ll
total 4
-rw-rw-r--. 1 zhangsan zhangsan 3348 Nov  8 07:57 hello.txt

# 使用gzip压缩hello.txt文件为 hello.txt.gz，压缩完，源文件hello.txt被删除
# 添加-v verbose模式，可以看到压缩率
[zhangsan@localhost test]$ gzip -v  hello.txt 
hello.txt:  98.6% -- replaced with hello.txt.gz
[zhangsan@localhost test]$ ll
total 4
-rw-rw-r--. 1 zhangsan zhangsan 76 Nov  8 07:57 hello.txt.gz


# 解压hello.txt.gz，解压后 hello.txt.gz被删除
[zhangsan@localhost test]$ gunzip hello.txt.gz 
[zhangsan@localhost test]$ ll
total 4
-rw-rw-r--. 1 zhangsan zhangsan 3348 Nov  8 07:57 hello.txt
```

#### 压缩与解压：zip

```shell
# 将cal.sh压缩为cal.zip
[zhangsan@localhost ~]$ zip cal.zip cal.sh
  adding: cal.sh (deflated 29%)

# 查看压缩结果
[zhangsan@localhost ~]$ ll cal*
-rwxrwxr-x. 1 zhangsan zhangsan 144 Nov 20 17:50 cal.sh
-rw-rw-r--. 1 zhangsan zhangsan 264 Nov 20 18:27 cal.zip

# 解压cal.zip
[zhangsan@localhost ~]$ unzip cal.zip 
Archive:  cal.zip
# 提示你要覆盖当前目录中cal.sh吗？ 输入r，我将解压后的文件重命名为calnew.sh
replace cal.sh? [y]es, [n]o, [A]ll, [N]one, [r]ename: r
new name: calnew.sh
  inflating: calnew.sh  

# 查看解压结果，解压后的文件为calnew.sh
[zhangsan@localhost ~]$ ll cal*
-rwxrwxr-x. 1 zhangsan zhangsan 144 Nov 20 17:50 calnew.sh
-rwxrwxr-x. 1 zhangsan zhangsan 144 Nov 20 17:50 cal.sh
-rw-rw-r--. 1 zhangsan zhangsan 264 Nov 20 18:27 cal.zip
```

#### 打包压缩与解压解包

```shell
[zhangsan@localhost test]$ ll
total 4
-rw-rw-r--. 1 zhangsan zhangsan 3348 Nov  8 07:57 hello.txt
# 将文件hello.txt打包并压缩为hello.tar.gz
[zhangsan@localhost test]$ tar -cvzf hello.tar.gz hello.txt 
hello.txt
[zhangsan@localhost test]$ ll
total 8
-rw-rw-r--. 1 zhangsan zhangsan  154 Nov  8 15:40 hello.tar.gz
-rw-rw-r--. 1 zhangsan zhangsan 3348 Nov  8 07:57 hello.txt

# 删除源文件hello.txt
[zhangsan@localhost test]$ rm -rf hello.txt
[zhangsan@localhost test]$ ll
total 4

# 将文件hello.tar.gz解压缩并解包
-rw-rw-r--. 1 zhangsan zhangsan 154 Nov  8 15:40 hello.tar.gz
[zhangsan@localhost test]$ tar -xvzf hello.tar.gz 
hello.txt

# 查看解压解包后的结果
[zhangsan@localhost test]$ ll
total 8
-rw-rw-r--. 1 zhangsan zhangsan  154 Nov  8 15:40 hello.tar.gz
-rw-rw-r--. 1 zhangsan zhangsan 3348 Nov  8 07:57 hello.txt
```



#### 项目实践

1.  创建一个名为 "mydir" 的目录，并进入该目录。
2.  在 "mydir" 目录下创建两个子目录，分别为 "dir1" 和 "dir2"。
3.  在 "dir1" 目录下创建一个名为 "file1.txt" 的文件，并写入一些文本内容。
4.  将 "dir1" 目录下的 "file1.txt" 文件复制到 "dir2" 目录下，并重命名为 "file2.txt"。
5.  使用命令行列出  "mydir" 目录下的所有文件和目录，并显示详细信息（包括权限、所有者、大小等）。
6.  将 "mydir" 目录下的所有文件和目录备份到名为 "backup.tar.gz" 的压缩文件中。
7.  从压缩文件 "backup.tar.gz" 中恢复所有文件和目录到当前目录。

请按照以上要求，使用命令行完成以上任务，并给出相应的命令和解释。