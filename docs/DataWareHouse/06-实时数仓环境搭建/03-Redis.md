# 源码编译安装Redis

使用**root**用户操作。

### 第一步：安装编译依赖与工具

CentOS 7 Minimal 缺少开发工具组，需要先安装 `gcc`、`make` 等必要组件。

```bash
yum install -y epel-release
yum groupinstall -y "Development Tools"
yum install -y tcl wget
```

> **说明**：`tcl` 用于编译完成后执行 Redis 自带的单元测试（非必须，但建议安装以验证编译正确性）。

### 第二步：下载 Redis 6.2.20 源码包

进入 `/usr/local/src` 目录，下载并解压源码。

```bash
cd /usr/local/src
wget https://download.redis.io/releases/redis-6.2.20.tar.gz
tar xzf redis-6.2.20.tar.gz
cd redis-6.2.20
```

### 第三步：编译与安装

Redis 的 Makefile 支持直接指定安装路径。

```bash
# 编译（-j 参数可根据 CPU 核心数加速，如 make -j4）
make

# 可选：运行测试确保编译正确（耗时约2-5分钟）
# make test

# 安装到 /usr/local/redis 目录
make PREFIX=/usr/local/redis install
```

安装完成后，Redis 的可执行文件位于 `/usr/local/redis/bin`。

### 第四步：配置环境变量与目录结构

为了方便使用，将 Redis 命令路径加入系统 PATH，并创建配置文件与数据存储目录。

```bash
# 建立软链接，使 redis-server 等命令全局可用
ln -sf /usr/local/redis/bin/redis-* /usr/local/bin/

# 创建配置文件目录
mkdir -p /etc/redis

# 创建数据持久化目录
mkdir -p /var/lib/redis

# 复制配置文件模板
cp /usr/local/src/redis-6.2.20/redis.conf /etc/redis/redis.conf
```

### 第五步：修改配置文件

编辑 `/etc/redis/redis.conf` 中的关键参数，使其更适合后台服务运行。

```bash
vi /etc/redis/redis.conf
```

需要修改或确认以下几项：

| 配置项        | 原值                      | 新值                 | 说明                                            |
| :------------ | :------------------------ | -------------------- | :---------------------------------------------- |
| `daemonize`   | `yes`                     |                      | 改为 yes，使其作为后台守护进程运行              |
| `pidfile`     | `/var/run/redis_6379.pid` |                      | 确认 PID 文件路径                               |
| `dir`         | `/var/lib/redis`          |                      | 修改为刚才创建的目录，存放 dump.rdb 文件        |
| `logfile`     |                           | /var/log/redis.log   | 指定日志文件路径（可选）                        |
| `bind`        | `127.0.0.1 ::1`→          | `0.0.0.0`            | 如需远程连接，可改为 `0.0.0.0` 并配合防火墙策略 |
| `requirepass` | `# requirepass foobared`  | `requirepass 123456` | 取消注释并设置强密码                            |

> **dump.rdb** 是 **Redis** 默认的 **持久化快照文件**，核心作用是将内存数据**全量备份**到磁盘，用于重启恢复或灾难备份。
>
> **安全提醒**：如果允许远程访问，务必设置 `requirepass` 或配置防火墙白名单。

### 第六步：创建 Systemd 服务管理文件

CentOS 7 使用 Systemd 管理服务。创建 `redis.service` 文件便于开机自启和状态管理。

```bash
vi /etc/systemd/system/redis.service
```

填入以下内容：

```ini
[Unit]
Description=Redis In-Memory Data Store
After=network.target

[Service]
User=root
Group=root
Type=forking
ExecStart=/usr/local/bin/redis-server /etc/redis/redis.conf
ExecStop=/usr/local/bin/redis-cli -a 123456 shutdown
Restart=always
PIDFile=/var/run/redis_6379.pid

[Install]
WantedBy=multi-user.target
```



### 第七步：启动 Redis 并设置开机自启

```bash
# 重新加载 Systemd 配置
systemctl daemon-reload

# 启动 Redis
systemctl start redis

# 查看状态（确认显示 active (running)）
systemctl status redis

# 设置开机自启动
systemctl enable redis
```

### 第八步：防火墙放行（仅当需要远程访问时）

如果 Redis 只在本机使用，**请不要开启防火墙端口**。若确实需要外部连接，执行以下命令：

```bash
# 开放默认端口 6379
firewall-cmd --zone=public --add-port=6379/tcp --permanent
firewall-cmd --reload
```

### 第九步：验证安装

使用客户端连接并测试。

```bash
# 本地连接（未设置密码时）
redis-cli ping
# 应返回 PONG

# 如果设置了密码，使用 -a 参数
redis-cli -a 你的密码 ping
```



## Java连接Redis

#### dependency

```xml
    <dependency>
        <groupId>redis.clients</groupId>
        <artifactId>jedis</artifactId>
        <version>3.3.0</version>
    </dependency>
```



#### code

```java
package com.zhangsan.edu.util;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

public class JedisUtil {
    private static JedisPool jedisPool;

    private static void initJedisPool() {
        JedisPoolConfig poolConfig = new JedisPoolConfig();
        poolConfig.setMaxTotal(100);
        poolConfig.setMaxIdle(5);
        poolConfig.setMinIdle(5);
        poolConfig.setBlockWhenExhausted(true);
        poolConfig.setMaxWaitMillis(2000);
        poolConfig.setTestOnBorrow(true);
        jedisPool = new JedisPool(poolConfig,"node1",6379,10000);
    }
    public static Jedis getJedis(){
        if(jedisPool == null){
            initJedisPool();
        }
        // 获取Jedis客户端
        Jedis jedis = jedisPool.getResource();
        return jedis;
    }

    public static void main(String[] args) {
        Jedis jedis = getJedis();
        String pong = jedis.ping();
        System.out.println(pong);
    }
}

```

