---
title: anaconda
date: 2023-02-11 22:14:00
categories:
- anaconda
tags:
- anaconda
---

## anaconda navigator无法打开
```shell
anaconda-navigator --reset
```

## 删除虚拟环境
```shell
conda env remove -p C:\Users\Qingyuan_Qu\.conda\envs\python37
```

## 在指定目录创建虚拟环境
```shell
conda create --prefix=D:\ProgramData\anaconda3\envs\python37 python=3.7
```