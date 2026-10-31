---
title: Hadoop Windows Java API QA
date: 2026-10-09 22:02:00
tags: 
categories:
- QA

---

# Hadoop Windows 开发环境 QA

## ExitCodeException exitCode=-1073741515

### Q

```shell
log4j:WARN See http://logging.apache.org/log4j/1.2/faq.html#noconfig for more info.
FileSystem 连接成功: hdfs://node0:9000
Exception in thread "main" ExitCodeException exitCode=-1073741515:
	at org.apache.hadoop.util.Shell.runCommand(Shell.java:1009)
	at org.apache.hadoop.util.Shell.execCommand(Shell.java:1321)
	at org.apache.hadoop.fs.RawLocalFileSystem.setPermission(RawLocalFileSystem.java:840)
	at org.apache.hadoop.fs.RawLocalFileSystem$LocalFSFileOutputStream.<init>(RawLocalFileSystem.java:239)
	at org.apache.hadoop.fs.ChecksumFileSystem.create(ChecksumFileSystem.java:464)
	at org.apache.hadoop.fs.FileSystem.create(FileSystem.java:987)
	at org.apache.hadoop.fs.FileUtil.copy(FileUtil.java:414)
	at org.apache.hadoop.fs.FileSystem.copyToLocalFile(FileSystem.java:2434)
	at com.studybigdata.hadoop.hdfs.Connect1.main(Connect1.java:42)
```

### A

`-1073741515` = `0xC0000135` = **STATUS_DLL_NOT_FOUND**：进程创建成功，但加载它依赖的 DLL 时失败。

换算：`4294967296 - 1073741515 = 3221225781 = 0xC0000135`。

**结论：与 HDFS、权限、路径全都无关**，是 Windows 本地文件创建后的 chmod 步骤崩了 —— `winutils.exe` 起不来。

#### 与其他退出码的区别（别诊断错方向）

| 退出码 | 含义 | 典型原因 |
| --- | --- | --- |
| `-1073741515` / `0xC0000135` | STATUS_DLL_NOT_FOUND | **缺 VC++ 运行库** |
| `-1073741701` / `0xC000007B` | STATUS_INVALID_IMAGE_FORMAT | **位数不匹配**（32/64 混用） |
| `-1073741819` / `0xC0000005` | STATUS_ACCESS_VIOLATION | 文件损坏 / 版本错配 |
| `IOException: CreateProcess error=2` | 文件不存在 | `winutils.exe` 不在 `HADOOP_HOME\bin` |

> 异常消息尾部 `exitCode=-1073741515: ` 冒号后为空 = 子进程 stderr 为空 = 一行输出都没来得及产生就死了，与"加载器阶段崩溃"吻合。若只是文件缺失，抛的是 `IOException` 而非 `ExitCodeException`。

## 为什么"连接成功"却还是崩了？

### Q

明明打印了 `FileSystem 连接成功`，集群是通的，为什么下载失败？

### A

失败点在**本地文件系统**，不在 HDFS。调用链：

```
copyToLocalFile(false, src, dst)
  → FileUtil.copy(...)
    → 本地 FileSystem.create(dst, 默认权限 0644)     ← 带权限
      → RawLocalFileSystem$LocalFSFileOutputStream.<init>
        → RawLocalFileSystem.setPermission
          → Shell.execCommand("winutils.exe chmod 0644 ...")   ← 崩在这里
```

Windows 没有 POSIX 权限，Hadoop 只能派生 `winutils.exe chmod` 模拟；`winutils.exe` 起不来就崩。

**附带推论**：既然走到 `Shell.execCommand` 这一支，说明 `NativeIO.isAvailable() == false`，即 `hadoop.dll` 也没加载成功——它缺的必然与 `winutils.exe` 是同一个运行库。**一份运行库修两处。**

## 为什么看不到 Hadoop 自己的告警？

### Q

日志里只有 `log4j:WARN` 和我自己的 `println`，没有任何 Hadoop 的 WARN/INFO。

### A

`hadoop` 模块下**没有 `log4j.properties`**（全仓只有 `spark/`、`edu-mini/` 里有）。没有 appender ⇒ log4j 把所有日志丢弃，只剩它自己那两句 WARN 和 `System.out.println`。

**危害**：本该出现的 `Did not find winutils.exe: ...`、`Unable to load native-hadoop library` 全被吞掉。**不能拿"没看到告警"推断 `HADOOP_HOME` 正常**（这次排查第一轮就差点被它误导）。

**修法**：把 `spark/src/main/resources/log4j.properties` 拷一份到 `hadoop/src/main/resources/`，级别设 WARN 即可。

## 怎么定位缺的是哪个 DLL？

### A

不用装任何工具，PowerShell 直接解析 PE 导入表：

```powershell
$exe = Join-Path $env:HADOOP_HOME 'bin\winutils.exe'
$b = [System.IO.File]::ReadAllBytes($exe)
$pe = [BitConverter]::ToInt32($b, 0x3C)
$machine = [BitConverter]::ToUInt16($b, $pe + 4)
$nsec    = [BitConverter]::ToUInt16($b, $pe + 6)
$optsize = [BitConverter]::ToUInt16($b, $pe + 20)
$opt     = $pe + 24
$is64    = ([BitConverter]::ToUInt16($b, $opt) -eq 0x20b)
$dd      = $opt + $(if ($is64) { 112 } else { 96 })
$impRVA  = [BitConverter]::ToUInt32($b, $dd + 8)

$secs = @()
for ($i = 0; $i -lt $nsec; $i++) {
  $o = $opt + $optsize + 40 * $i
  $secs += [pscustomobject]@{
    VA  = [BitConverter]::ToUInt32($b, $o + 12)
    VS  = [Math]::Max([BitConverter]::ToUInt32($b, $o + 8), [BitConverter]::ToUInt32($b, $o + 16))
    Ptr = [BitConverter]::ToUInt32($b, $o + 20)
  }
}
function R2O($rva) {
  foreach ($s in $secs) { if ($rva -ge $s.VA -and $rva -lt $s.VA + $s.VS) { return $s.Ptr + ($rva - $s.VA) } }
  return -1
}
"machine: 0x{0:x4} ({1})" -f $machine, $(if ($machine -eq 0x8664) {'x64'} elseif ($machine -eq 0x14c) {'x86'} else {'other'})
"导入依赖:"
$p = R2O $impRVA
while ($true) {
  $nr = [BitConverter]::ToUInt32($b, $p + 12)
  if ($nr -eq 0) { break }
  $n = R2O $nr; $s = ''
  while ($b[$n] -ne 0) { $s += [char]$b[$n]; $n++ }
  $ok = Test-Path (Join-Path $env:windir "System32\$s")
  "  {0,-30} {1}" -f $s, $(if ($ok) {'OK'} else {'缺失 <== 就是它'})
  $p += 20
}
```

本机实测截取：

```shell
machine: 0x8664 (x64)
导入依赖:
  KERNEL32.dll                   OK
  ADVAPI32.dll                   OK
  MSVCR120.dll                   缺失 <== 就是它
  RPCRT4.dll                     OK
  ...
```



## 怎么修？

### A

**根因修复 = 装缺失的 VC++ 运行库。** 按 DLL 名对号入座：

| 缺失的 DLL | 需安装 |
| --- | --- |
| `MSVCR100.dll` / `MSVCP100.dll` | Visual C++ **2010** SP1 Redistributable (x64) |
| `MSVCR110.dll` / `MSVCP110.dll` | Visual C++ **2012** Redistributable (x64) |
| `MSVCR120.dll` / `MSVCP120.dll` | Visual C++ **2013** Redistributable (x64) |
| `VCRUNTIME140.dll` / `MSVCP140.dll` | Visual C++ **2015–2022** Redistributable (x64) |

> Apache Hadoop 官方的 Windows 构建指南历来要求 VS2010/VS2013 工具链，cdarlint/winutils 这份 `hadoop-3.1.0` 的产物正是 VS2013 编的
>
> ⚠️ 常见踩坑：**2015–2022 的一体化包不包含 `MSVCR120.dll`，装了没用。** 必须装对应年份那一份。

两份关键动作，**缺一不可**：

1. **装 VC++ 2013 Redist (x64)** ⇒ `winutils.exe` 能跑起来

```http
https://www.microsoft.com/en-us/download/details.aspx?id=40784
```

2. **把 `%HADOOP_HOME%\bin` 加进 PATH**⇒ `hadoop.dll` 能被 `System.loadLibrary` 找到并加载。

改完**必须重启 IDEA** —— PATH、native 库加载都在 JVM 启动时确定。





