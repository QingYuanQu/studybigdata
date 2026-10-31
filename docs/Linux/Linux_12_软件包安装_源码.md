---
title: Linux软件安装 - 源码安装
date: 2023-01-14 15:55:26
categories:
- Linux
tags:
- Linux
- 源码安装Nginx
- 源码安装Redis
marp: true
---





## 源码安装

| 步骤               | 主要功能                      | 输入                    | 输出              | 关键作用                                   | 主要影响的目录                      | 典型文件操作                                                |
| :----------------- | :---------------------------- | :---------------------- | :---------------- | :----------------------------------------- | :---------------------------------- | :---------------------------------------------------------- |
| **`configure`**    | **配置** (检查环境/生成规则)  | 源代码 + 系统环境       | Makefile          | 检查依赖、定义安装路径、决定启用哪些功能   | 当前源码目录                        | 创建 `Makefile`、`config.log` 等配置文件                    |
| **`make`**         | **编译** (构建二进制文件)     | Makefile + 源代码       | 可执行程序/库文件 | 调用编译器（如 gcc）将源代码转换成机器码   | 当前源码目录及其子目录              | 创建大量的 `.o` 目标文件和最终的程序文件                    |
| **`make install`** | **安装** (拷贝文件到系统目录) | 编译好的文件 + Makefile | 安装到系统的程序  | 将可执行文件、配置文件复制到标准系统路径下 | 系统目录（如 `/usr/local`、`/etc`） | 复制文件到 `/bin`、`/lib`、`/etc`，创建系统文件夹，设置权限 |

## Redis安装

```shell
[root@node2 ~]# yum install gcc-c++
[root@node2 ~]# wget https://download.redis.io/releases/redis-6.2.20.tar.gz
[root@node2 ~]# tar -zxf redis-6.2.20.tar.gz
[root@node2 ~]# cd redis-6.2.20/src
[root@node2 src]# make
# make操作将编译后的二进制程序安装到 /usr/local/bin/redis-server
[root@node2 src]# make install
```

### redis.conf 配置

```ini
# 关闭Redis自身守护进程（交给systemd管理）
daemonize no
supervised no
#注释
#bind 127.0.0.1 -::1 
```

### 服务化启动

`/etc/systemd/system/redis.service`

```ini
[Unit]
Description=Redis Server
After=network.target

[Service]
# 核心：Redis启动命令（替换为你的实际路径）
ExecStart=/usr/local/bin/redis-server /etc/redis/redis.conf
Type=simple
ExecStop=/usr/local/bin/redis-cli shutdown
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
```



```bash
[root@node2 ~]# systemctl daemon-reload   # 重载配置
[root@node2 ~]# systemctl start redis     # 启动服务
[root@node2 ~]# systemctl enable redis    # 开机自启
[root@node2 ~]# systemctl status redis    # 检查状态
```



---



## Nginx安装

Web服务器软件

```shell
# 下载Nginx
# wget http://nginx.org/download/nginx-1.21.4.tar.gz
--2021-11-19 00:42:27--  http://nginx.org/download/nginx-1.21.4.tar.gz
Resolving nginx.org (nginx.org)... 3.125.197.172, 2a05:d014:edb:5704::6, 2a05:d014:edb:5702::6
Connecting to nginx.org (nginx.org)|3.125.197.172|:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 1070260 (1.0M) [application/octet-stream]
Saving to: ‘nginx-1.21.4.tar.gz’

nginx-1.21.4.tar.gz                                  100%[=====================================================================================================================>]   1.02M   254KB/s    in 4.1s    

2021-11-19 00:42:32 (254 KB/s) - ‘nginx-1.21.4.tar.gz’ saved [1070260/1070260]


# 安装依赖
# yum -y install gcc zlib zlib-devel pcre-devel openssl openssl-devel

# 解压
# tar -zxf nginx-1.21.4.tar.gz 


# 进人Nginx主目录
# cd nginx-1.21.4

#执行命令
#  ./configure
#  make
#  make install


# 启动
# 检查配置文件

# /usr/local/nginx/sbin/nginx  -t
#启动
# /usr/local/nginx/sbin/nginx
# 重启加载配置
# /usr/local/nginx/sbin/nginx -s reload



# 测试
[root@localhost nginx-1.21.4]# wget 192.168.111.128
--2021-11-19 00:50:19--  http://192.168.111.128/
Connecting to 192.168.111.128:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 615 [text/html]
Saving to: ‘index.html’

index.html                                           100%[=====================================================================================================================>]     615  --.-KB/s    in 0s      

2021-11-19 00:50:19 (107 MB/s) - ‘index.html’ saved [615/615]


# 为了可以外部访问，关闭防火墙，或者放开80端口
# 查看防火墙状态
[root@localhost nginx-1.21.4]# systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
   Active: active (running) since Thu 2021-11-18 21:03:13 PST; 4h 42min ago
     Docs: man:firewalld(1)
 Main PID: 1029 (firewalld)
    Tasks: 2 (limit: 4771)
   Memory: 812.0K
   CGroup: /system.slice/firewalld.service
           └─1029 /usr/libexec/platform-python -s /usr/sbin/firewalld --nofork --nopid

Nov 18 21:03:12 localhost.localdomain systemd[1]: Starting firewalld - dynamic firewall daemon...
Nov 18 21:03:13 localhost.localdomain systemd[1]: Started firewalld - dynamic firewall daemon.
Nov 18 21:03:13 localhost.localdomain firewalld[1029]: WARNING: AllowZoneDrifting is enabled. This is considered an insecure configuration option. It will be removed in a future release. Please consider disabli>

# 关闭防火墙
[root@localhost nginx-1.21.4]# systemctl stop firewalld
```



##### welcome.html

```html
<!DOCTYPE html>  
<html lang="zh-CN">  
<head>  
    <meta charset="UTF-8">  
    <meta name="viewport" content="width=device-width, initial-scale=1.0">  
    <title>欢迎来到我的网页</title>  
    <style>  
        body {  
            font-family: Arial, sans-serif;  
            text-align: center;  
            margin-top: 20%;  
            background-color: #f2f2f2;  
        }  
        h1 {  
            color: #333;  
        }  
    </style>  
</head>  
<body>  
    <h1>欢迎来到我的网页！</h1>  
    <p>这是一个简单的欢迎网页示例。</p>  
    <p>你可以在这里添加更多的内容，比如图片、链接、文本等。</p>  
</body>  
</html>
```

>   https://www.ctyun.cn/
>
>   140.246.94.37
>
>   天翼云： 这些端口8080，80，443，8443 需要备案后才能访问。
>
>   修改NGINX服务端口为8081，并在安全组中加入入方向规则



