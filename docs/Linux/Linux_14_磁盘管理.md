---
title: Linux磁盘管理
date: 2023-01-14 15:55:26
categories:
- Linux
tags:
- Linux磁盘管理
marp: true
---

## 磁盘管理

### VMWare中扩展磁盘容量

#### 虚拟机设置

VMWare - 菜单栏 - 虚拟机 - 设置 

![1716338668349](./img/Linux_14_%E7%A3%81%E7%9B%98%E7%AE%A1%E7%90%86/1716338668349.png)

>   注意：该步骤需要将系统关机，如有快照，需要删除快照。
>
>   系统可用空间为宿主机D盘的可用空间。

---



#### 扩展磁盘容量



![1716338747329](./img/Linux_14_%E7%A3%81%E7%9B%98%E7%AE%A1%E7%90%86/1716338747329.png)

---



#### 扩展成功

![1716338769682](./img/Linux_14_%E7%A3%81%E7%9B%98%E7%AE%A1%E7%90%86/1716338769682.png)

---



#### 扩展成功

![1716338818497](./img/Linux_14_%E7%A3%81%E7%9B%98%E7%AE%A1%E7%90%86/1716338818497.png)



>   这种方式是增大原来sda盘的大小。



---

#### 磁盘管理

![910773d89b9144daed9bd79845ec20e](./img/Linux_14_%E7%A3%81%E7%9B%98%E7%AE%A1%E7%90%86/910773d89b9144daed9bd79845ec20e.png)

#### 新增结果

![1716340699036](./img/Linux_14_%E7%A3%81%E7%9B%98%E7%AE%A1%E7%90%86/1716340699036.png)

---



#### 添加分区

![1716340923603](./img/Linux_14_%E7%A3%81%E7%9B%98%E7%AE%A1%E7%90%86/1716340923603.png)

---

#### 分区命名

![1716340971932](./img/Linux_14_%E7%A3%81%E7%9B%98%E7%AE%A1%E7%90%86/1716340971932.png)

---

#### 添加分区成功

![1716341039250](./img/Linux_14_%E7%A3%81%E7%9B%98%E7%AE%A1%E7%90%86/1716341039250.png)

---



### VMWare中新增磁盘

---



#### 添加磁盘

![1716341236330](./img/Linux_14_%E7%A3%81%E7%9B%98%E7%AE%A1%E7%90%86/1716341236330.png)

---



![image-20240522092919292](./img/Linux_14_%E7%A3%81%E7%9B%98%E7%AE%A1%E7%90%86/image-20240522092919292.png)

---



![1716341390820](./img/Linux_14_%E7%A3%81%E7%9B%98%E7%AE%A1%E7%90%86/1716341390820.png)

---



![1716341472710](./img/Linux_14_%E7%A3%81%E7%9B%98%E7%AE%A1%E7%90%86/1716341472710.png)

---



![1716341553372](./img/Linux_14_%E7%A3%81%E7%9B%98%E7%AE%A1%E7%90%86/1716341553372.png)

---



#### 系统中重新分区

 **fdisk** - manipulate disk partition table。 `[məˈnɪpjuleɪt]` 操纵

---

#### 扩充磁盘查看

注意新增加的磁盘是下面的 sdb

<pre>[zhangsan@localhost ~]$ ls /dev/sd*
<span style="background-color:#080808"><font color="#FCE94F">/dev/sda</font></span>  <span style="background-color:#080808"><font color="#FCE94F">/dev/sda1</font></span>  <span style="background-color:#080808"><font color="#FCE94F">/dev/sda2</font></span>  <span style="background-color:#080808"><font color="#FCE94F">/dev/sda3</font></span>  <span style="background-color:#080808"><font color="#FCE94F">/dev/sda4</font></span>  <span style="background-color:#080808"><font color="#FCE94F">/dev/sdb</font></span>
</pre>



---

#### 磁盘管理

```bash
[zhangsan@localhost ~]$ su root
Password: 

# 使用磁盘管理工具fdisk
[root@localhost zhangsan]# fdisk /dev/sdb 

Welcome to fdisk (util-linux 2.32.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0xb69b5e04.

# 输入m，查看帮助信息
Command (m for help): m
```

---



#### 新建分区

```bash
# 新建分区:new
Command (m for help): new
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p #主分区
Partition number (1-4, default 1): 1 #第一个分区
First sector (2048-10485759, default 2048): 2048 # 起始扇区
Last sector, +sectors or +size{K,M,G} (2048-20971519, default 20971519):   # 或+nG
Using default value 20971519
Partition 1 of type Linux and of size 10 GiB is set
```

>   Last sector nG前需要`+`号

---



#### 打印分区结果

```bash
Command (m for help): p

Disk /dev/sdb: 10.7 GB, 10737418240 bytes, 20971520 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0xcbf87d11

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1            2048    20971519    10484736   83  Linux
```

---



#### 保存分区结果

```bash
Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
```

---

![1716344378966](./img/Linux_14_%E7%A3%81%E7%9B%98%E7%AE%A1%E7%90%86/1716344378966.png)

---



### 格式化文件系统

**mkfs** - build a Linux filesystem

```shell
# 格式化为 ext3
[root@localhost ~]# mkfs -t ext3 /dev/sdb1
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
...
Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done 
```

重新格式化为ext3

---



### 分区的挂载与卸载

#### sdb1的默认挂载点

```bash
[zhangsan@localhost 3c480221-9236-40b7-afaa-4eacf96006e7]$ pwd
/run/media/zhangsan/3c480221-9236-40b7-afaa-4eacf96006e7
```

#### 从默认挂载点卸载分区

```bash
[root@localhost ~]# umount /dev/sdb1
```

---



#### 创建新的挂载点

我们将分区`/dev/sdb1`挂载到`/home/zhangsan/disk`节点下。

```shell
[root@localhost zhangsan]# mkdir disk/
```

#### 挂载分区

```shell
[root@localhost zhangsan]# mount /dev/sdb1 /home/zhangsan/disk/
[root@localhost zhangsan]# cd disk/
```

---



#### 卸载分区

```shell
[root@localhost disk]# umount /dev/sdb1 
umount: /home/zhangsan/disk: target is busy.
[root@localhost disk]# cd ..
[root@localhost zhangsan]# umount /dev/sdb1 
```



---

### df

 report file system disk space usage

-   -h, --human-readable
                  print sizes in human readable format (e.g., 1K 234M 2G)

```bash
[root@localhost disk]# df 
Filesystem     1K-blocks    Used Available Use% Mounted on
devtmpfs         1914912       0   1914912   0% /dev
tmpfs            1930644       0   1930644   0% /dev/shm
tmpfs            1930644   12840   1917804   1% /run
tmpfs            1930644       0   1930644   0% /sys/fs/cgroup
/dev/sda3       27989656 7981936  20007720  29% /
/dev/sda1         303780  166720    137060  55% /boot
tmpfs             386132      32    386100   1% /run/user/1000
tmpfs             386132       0    386132   0% /run/user/0
/dev/sdb1       10189076   36888   9611568   1% /home/zhangsan/disk
```

