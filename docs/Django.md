---
title: Django
date: 2022-03-23 15:55:26
categories:
- Django
tags:
- Django
---

# Django

## Django

官网：https://www.djangoproject.com/

文档：https://docs.djangoproject.com/zh-hans/4.0/

## 安装Django

```shell
(python37) PS C:\Users\Qingyuan_Qu> pip install django
(python37) PS C:\Users\Qingyuan_Qu> python -m django --version
```

## Django Admin

```shell
(python37) PS C:\Users\Qingyuan_Qu> django-admin.exe
    startproject # 创建Project
    runserver # 启动项目
    startapp # 创建App
    
    # 可以将迁移看作是数据库架构的版本控制系统。
    showmigrations # 迁移：列出项目的迁移和迁移的状态
    makemigrations # 迁移：基于模型的修改创建迁移文件
    migrate # 迁移： 负责应用和撤销迁移
    sqlmigrate # 迁移：展示迁移使用的 SQL 语句
    
    squashmigrations
    check
    compilemessages
    createcachetable
    dbshell
    diffsettings
    dumpdata
    flush
    inspectdb
    loaddata
    makemessages
    sendtestemail
    shell
    sqlflush
    sqlsequencereset
    test
    testserver
```

https://docs.djangoproject.com/zh-hans/4.0/topics/migrations/

`manage.py` 会在每个 Django 项目中自动创建。它做的事情和 `django-admin` 一样，但也设置了 [`DJANGO_SETTINGS_MODULE`](https://docs.djangoproject.com/zh-hans/4.0/topics/settings/#envvar-DJANGO_SETTINGS_MODULE) 环境变量，使其指向你的项目的 `settings.py` 文件。



#### 创建项目

```powershell
(python37) PS D:\PycharmProjects\pythonProject> django-admin.exe startproject smartlibrary
```



#### 创建应用

```powershell
(python37) PS D:\PycharmProjects\pythonProject> cd .\smartlibrary\
(python37) PS D:\PycharmProjects\pythonProject\smartlibrary> python .\manage.py startapp authorize
(python37) PS D:\PycharmProjects\pythonProject\smartlibrary> python .\manage.py startapp home
```



##### 将`App`添加到`Project`

`settings.py`

```python
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'authorize.apps.AuthorizeConfig',
    'home.apps.HomeConfig'
]
```



#### 添加模型

##### App home

```python
class book(models.Model):
    name = models.CharField(max_length=50, blank=False, verbose_name="书名", default='')
    price = models.FloatField(blank=False, verbose_name="价格", default=0)
    cover = models.ImageField(verbose_name="封面", upload_to='upload', default='img/default.png')
    introduction = models.TextField(verbose_name="介绍", blank=True, default='')
    url = models.URLField(verbose_name='URL', blank=True, default='')
    publish = models.CharField(verbose_name='出版社', max_length=50, default='', blank=True)
    rating = models.CharField(verbose_name='评分', max_length=5, default='0')

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = "图书管理"
        verbose_name_plural = "图书管理"


class hits(models.Model):
    userid=models.IntegerField(default=0)
    bookid=models.IntegerField(default=0)
    hitnum=models.IntegerField(default=0)

    def __str__(self):
        return str(self.userid)

    class Meta:
        verbose_name = "点击量"
        verbose_name_plural = "点击量"
```

在`admin.py`中注册模型

```python
from django.contrib import admin

from .models import book
from .models import hits

admin.site.register(book)
admin.site.register(hits)
```



##### App  authorize

```python
class user(models.Model):
    name = models.CharField(max_length=50, default='')
    email = models.EmailField()
    password = models.CharField(max_length=6, default='admin')

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = '用户管理'
        verbose_name_plural = '用户管理'
```

在`admin.py`中注册模型

```python
from django.contrib import admin

from .models import user

admin.site.register(user)
```



#### 模型的迁移

```powershell
# 基于模型的修改创建迁移
PS D:\smartlibrary> python .\manage.py makemigrations home
PS D:\smartlibrary> python .\manage.py makemigrations authorize

# 展示迁移的SQL
PS D:\smartlibrary> python .\manage.py sqlmigrate home 0001
PS D:\smartlibrary> python .\manage.py sqlmigrate authorize 0001

# 创建数据库和表
PS D:\smartlibrary> python .\manage.py migrate

# SQLite3
PS D:\smartlibrary> sqlite3.exe .\db.sqlite3
.help
.databases
.tables
.quit
```



#### 添加超级用户

```powershell
PS D:\smartlibrary> python .\manage.py createsuperuser
```



#### 启动Django

```powershell
PS D:\smartlibrary> python .\manage.py runserver
```

#### 汉化

```python
LANGUAGE_CODE = 'zh-hans'
TIME_ZONE = 'Asia/Shanghai'
```