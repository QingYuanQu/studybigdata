---
title: Linux文件权限
date: 2023-01-14 15:55:26
categories:
- Linux
tags:
- Linux文件权限
marp: true
---

## 文件权限

```shell
drwxr-xr-x  1 root root    4096 Oct 14 19:35 home
d: directory  - :文件

rwx : 所有者权限(user, u) 111 -> 7
r-x : 所属组(group, g) 101 -> 5
r-x : 其他用户(other, o) 101 -> 5

r : read (4)
w : write (2)
x : 执行 (1)

root : 所有者
root : 所属组
```

```
chmod :更改权限
chmod 700 file
chmod u+x file
```

```bash
chown zhangsan:zhangsan hello.sh
```

