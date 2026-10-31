---
title: HTML基础
date: 2022-10-14 09:55:26
tags:
---



<h1 align="center" style="color:red">HTML基础</h1>

# Hello World

```html
<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <title>Hello World</title>
</head>

<body>

    <h1>我的第一个标题</h1>

    <p>我的第一个段落。</p>
    
	<a href="http://www.baidu.com">这是一个链接</a>
</body>

</html>
```

- 元素

- 内容

- 属性

  属性总是以名称/值对的形式出现，**比如：name="value"**。

  

# HTML基础



## 注释

<p align="center" style="color:red">BEGIN</p>

- 源码

```html
<!-- 注释： -->
```

<p align="center" style="color:red">END</p>





## 标题

<p align="center" style="color:red">BEGIN</p>

HTML 标题（Heading）是通过<h1> - <h6> 标签来定义的。

- 源码

```html
<h1>一级标题</h1>
<h2>二级标题</h2>
<h3>三级标题</h3>
```

- 效果

<h1>一级标题</h1>
<h2>二级标题</h2>
<h3>三级标题</h3>

<p align="center" style="color:red">END</p>



## 段落

<p align="center" style="color:red">BEGIN</p>

- 源码

```html
<p>这是一个段落 </p>
```



- 效果

<p>第一段</p>

<p>第二段</p>

<p align="center" style="color:red">END</p>







## 文本格式化

<p align="center" style="color:red">BEGIN</p>

- 源码

```html
<b>加粗文本</b><br/>
<i>斜体文本</i><br/>
<code>用来定义计算机代码文本</code><br/>
这是 <sub> 下标</sub> 和 <sup> 上标</sup>
<del>删除</del>
```



- 效果

<b>加粗文本</b><br/>
<i>斜体文本</i><br/>
<code>用来定义计算机代码文本</code><br/>
这是 <sub> 下标</sub> 和 <sup> 上标</sup>
<del>删除</del>

<p align="center" style="color:red">END</p>







## 换行

<p align="center" style="color:red">BEGIN</p>

- 源码

```html
<br>
```

- 效果

<p>第一段文字</p><br><p>第二段文字</p>

<p align="center" style="color:red">END</p>







## 水平线

<p align="center" style="color:red">BEGIN</p>

- 源码

```html
<hr>
```

- 效果

<hr>
<p align="center" style="color:red">END</p>






## 列表

<p align="center" style="color:red">BEGIN</p>

### 无序列表

- 源码

```html
<ul>
    <li>item1</li>
    <li>item2</li>
    <li>item3</li>
</ul>
```



- 效果

<ul>
    <li>item1</li>
    <li>item2</li>
    <li>item3</li>
</ul>

### 有序列表

- 源码

```html
<ol>
    <li>item1</li>
    <li>item2</li>
    <li>item3</li>
</ol>
```



- 效果

<ol>
    <li>item1</li>
    <li>item2</li>
    <li>item3</li>
</ol>



<p align="center" style="color:red">END</p>








## 链接

<p align="center" style="color:red">BEGIN</p>

- 源码

```html
	<a href="http://www.baidu.com">这是一个链接</a>
```



- 效果

​	<a href="http://www.baidu.com">百度</a>

<p align="center" style="color:red">END</p>





## 图像



<p align="center" style="color:red">BEGIN</p>

- 源码

```html
<img border="0" src="./img/scrapy_architecture_01.png" alt="scrapy_architecture" width="304" height="228">
```



- 效果

<img border="0" src="./img/scrapy/scrapy_architecture_01.png" alt="scrapy_architecture" width="482" height="283">

<p align="center" style="color:red">END</p>



## 表格

### 基础表格

<p align="center" style="color:red">BEGIN</p>

- 源码

```html
<table border="1">

    <tr>
        <th>第一列</th>
        <th>第二列</th>
    </tr>

    <tr>
        <td>第一行第一列</td>
        <td>第一行第二列</td>
    </tr>

    <tr>
        <td>第二行第一列</td>
        <td>第二行第二列</td>
    </tr>
</table>
```



- 效果

<table border="1">
    <tr>
        <th>第一列</th>
        <th>第二列</th>
    </tr>
    <tr>
        <td>第一行第一列</td>
        <td>第一行第二列</td>
    </tr>
    <tr>
        <td>第二行第一列</td>
        <td>第二行第二列</td>
</table>



<p align="center" style="color:red">END</p>





### 跨行跨列

<p align="center" style="color:red">BEGIN</p>

- 源码

```html
<b>单元格跨两列:</b>

<table border="1">
    <tr>
        <th>姓名</th>
        <th colspan="2">电话</th>
    </tr>
    <tr>
        <td>张三</td>
        <td>15388888888</td>
        <td>15366666666</td>
    </tr>
</table>
<b>单元格跨两行:</b>

<table border="1">
    <tr>
        <th>姓名:</th>
        <td>张三</td>
    </tr>
    <tr>
        <th rowspan="2">电话:</th>
        <td>15388888888</td>
    </tr>
    <tr>
        <td>15366666666</td>
    </tr>
</table>
```



- 效果

<b>单元格跨两列:</b>

<table border="1">
<tr>
  <th>姓名</th>
  <th colspan="2">电话</th>
</tr>
<tr>
  <td>张三</td>
  <td>15388888888</td>
  <td>15366666666</td>
</tr>
</table>
<b>单元格跨两行:</b>

<table border="1">
<tr>
  <th>姓名:</th>
  <td>张三</td>
</tr>
<tr>
  <th rowspan="2">电话:</th>
  <td>15388888888</td>
</tr>
<tr>
  <td>15366666666</td>
</tr>
</table>
<p align="center" style="color:red">END</p>



## 按钮

<p align="center" style="color:red">BEGIN</p>

- 源码

```html
<button>确认</button>
```

- 效果

<button>搜索</button>

<p align="center" style="color:red">END</p>





## 文本框

<p align="center" style="color:red">BEGIN</p>

- 源码

```html
<input type="text" name="txtbox1" placeholder="请输入手机号"> 
```

- 效果

<div>
<input type="text" name="txtbox1" placeholder="请输入手机号"> 
 </div>

<p align="center" style="color:red">END</p>







## 提交按钮

<p align="center" style="color:red">BEGIN</p>

- 源码

```html
<input type="submit" value="提交"> 
```

- 效果

<div>
    <input type="submit" value="提交"> 
</div>

<p align="center" style="color:red">END</p>





## 单选按钮

<p align="center" style="color:red">BEGIN</p>

- 源码

```html
<div>
    <input type="radio" name="sex" value="male"> 男<br>
    <input type="radio" name="sex" value="female"  checked="True"> 女<br>
</div>
```

- 效果

<div>
    <input type="radio" name="sex" value="male"> 男<br>
    <input type="radio" name="sex" value="female" checked="True"> 女<br>
</div>

<p align="center" style="color:red">END</p>



## 复选框

<p align="center" style="color:red">BEGIN</p>

- 源码

```html
<div>
    <input type="checkbox" name="chinese" value="chinese"  checked="True">语文<br>
    <input type="checkbox" name="math" value="math"  checked="True">数学<br>
    <input type="checkbox" name="english" value="english">英语<br>
</div>
```

- 效果

<div>
    <input type="checkbox" name="chinese" value="chinese"  checked="True">语文<br>
    <input type="checkbox" name="math" value="math"  checked="True">数学<br>
    <input type="checkbox" name="english" value="english">英语<br>
</div>

<p align="center" style="color:red">END</p>





## 下拉列表

<p align="center" style="color:red">BEGIN</p>

- 源码

```html
<div>
    <select name="city">
        <option value="jinan">济南</option>
        <option value="taian">泰安</option>
        <option value="heze" selected>菏泽</option>
        <option value="zaozhuang">枣庄</option>
    </select>
</div>
```

- 效果

<div>
    <select name="city">
        <option value="jinan">济南</option>
        <option value="taian">泰安</option>
        <option value="heze" selected>菏泽</option>
        <option value="zaozhuang">枣庄</option>
    </select>
</div>

<p align="center" style="color:red">END</p>



## 多行文本框

<p align="center" style="color:red">BEGIN</p>

- 源码

```html
<textarea rows="5" cols="100">
我是一个多行文本框。
</textarea>
```

- 效果

<textarea rows="5" cols="100">
我是一个多行文本框。
</textarea>

<p align="center" style="color:red">END</p>





## 表单

<p align="center" style="color:red">BEGIN</p>

- 源码

```html
<form name="register" action="/school/register" method="post">
    请填写表单注册账号<br>
    账号: <input type="text" name="account" placeholder="请输入账号"><br>
    密码: <input type="password" name="password" placeholder="请输入密码"><br>
    性别：<br>
    &nbsp;&nbsp;&nbsp;&nbsp;<input type="radio" name="sex" value="male"> 男<br>
    &nbsp;&nbsp;&nbsp;&nbsp;<input type="radio" name="sex" value="female" checked="True"> 女<br>
    选修科目：<br>
    <input type="checkbox" name="chinese" value="chinese" checked="True">语文<br>
    <input type="checkbox" name="math" value="math" checked="True">数学<br>
    <input type="checkbox" name="english" value="english">英语<br>
    所在城市：<br>
    <select name="city">
        <option value="jinan">济南</option>
        <option value="taian">泰安</option>
        <option value="heze" selected>菏泽</option>
        <option value="zaozhuang">枣庄</option>
    </select><br>
    自我介绍：<br>
    <textarea rows="5" cols="100">
自我介绍，不少于200字。
</textarea>
    <br>
    <input type="submit" value="提交">
</form>
```

- 效果

<form name="register" action="/school/register" method="post">
    请填写表单注册账号<br>
    账号: <input type="text" name="account" placeholder="请输入账号"><br>
    密码: <input type="password" name="password" placeholder="请输入密码"><br>
    性别：<br>
    &nbsp;&nbsp;&nbsp;&nbsp;<input type="radio" name="sex" value="male"> 男<br>
    &nbsp;&nbsp;&nbsp;&nbsp;<input type="radio" name="sex" value="female" checked="True"> 女<br>
    选修科目：<br>
    <input type="checkbox" name="chinese" value="chinese" checked="True">语文<br>
    <input type="checkbox" name="math" value="math" checked="True">数学<br>
    <input type="checkbox" name="english" value="english">英语<br>
    所在城市：<br>
    <select name="city">
        <option value="jinan">济南</option>
        <option value="taian">泰安</option>
        <option value="heze" selected>菏泽</option>
        <option value="zaozhuang">枣庄</option>
    </select><br>
    自我介绍：<br>
    <textarea rows="5" cols="100">
自我介绍，不少于200字。
</textarea>
    <br>
    <input type="submit" value="提交">
</form>

<p align="center" style="color:red">END</p>



## 特殊符号

<p align="center" style="color:red">BEGIN</p>

- 源码

```html
&copy;
&reg;
&trade;
&#9775;
&#9781;
```

- 效果

&copy;
&reg;
&trade;
&#9775;
&#9781;


- 更多

> https://www.w3school.com.cn/charsets/ref_html_symbols.asp

<p align="center" style="color:red">END</p>



# CSS样式

## 样式简介

### 背景色

```css
{
	background-color:red;
	background-image:
}
```



### 文本

| 属性            | 取值                                    | 描述             |
| --------------- | --------------------------------------- | ---------------- |
| color           | red                                     | 文本颜色         |
| direction       | rtl, ltr                                | 文本方向         |
|                 |                                         |                  |
| font-family     |                                         |                  |
| font-size       |                                         |                  |
| font-weight     |                                         |                  |
|                 |                                         |                  |
| text-align      | center                                  | 对齐元素中的文本 |
| text-height     | 像素、数值、百分百                      | 行距             |
| text-decoration | none, overline, line-through, underline | 文本修饰         |
| text-indent     | 50px                                    | 首行缩进         |
| text-transform  | uppercase, lowercase, capitalize        | 大小写           |
|                 |                                         |                  |
| letter-spacing  | 2px                                     | 字符间距         |
| word-spacing    | 30px                                    | 单词间距         |

## 引入方式
### 内联样式

内联样式也称为行内样式表，CSS是在元素的开始标签的style属性中定义的。

```html
<body style="background-color:red;"></body>
```

### 内部样式

内部样式（internal）在`<head>`区域中的`<style>`区域中定义

```html
<head>
    <style type="text/css">
        body {
            background-color: yellow;
        }
    </style>
</head>
```

### 外部引用

外部样式表（external）在单独文件中定义，然后在HTML文件的`<head></head>`标签对中使用link标签来引用。

##### HTML

```html
<link rel="stylesheet" type="text/css" href="index.css">
```

##### CSS

```css
body {
    background-color: red;
}
```

在实际开发中，一般都是使用外部样式表比较多，但是并不代表内部样式表以及行内样式表就一无是处。

### 优先级

```shell
内联 > 内部 > 外部
```

 


## 选择器

### 通用选择器

选择所有元素

```
*{
}
```

### 元素选择器

元素选择器，就是“选中”相同的元素，然后对相同的元素定义同一个CSS样式。

##### HTML

```html
<p>Lorem</p>
<p>Lorem</p>
<div>Lorem</div>
```

##### CSS

```css
p {
    color: red;
}
```

上述p元素选择器样式只会修改p元素的样式，不会修改div元素的样式。

### class选择器

class选择器，也就是“类选择器”。我们可以对“相同的元素”或者“不同的元素”定义相同的class属性，对属于相同class的元素设置统一的样式。在CSS中使用"."来选择元素。

##### HTML

```html
<p class="g1">Lorem</p>
<p class="g1">Lorem</p>
<div class="g1">Lorem</div>
```

##### CSS

```css
.g1 {
    background-color: gray;
}
```

注意：

```css
p.g1 /*只有class="g1"的p元素会使用该样式*/
```

```html
<p class="center large">这个段落使用两个样式。</p>
```

### id选择器

我们可以为元素设置一个id属性，然后针对设置了这个id的元素定义CSS样式，这就是id选择器，在CSS中使用"#" 来选择元素。

##### HTML

```html
<p class="g1" id="one">Lorem</p>
<p class="g1" id="two">Lorem</p>
<div class="g1" id="three">Lorem</div>
```

##### CSS

```css
#one {
    background-color: red;
}

#two {
    background-color: yellow;
}

#three {
    background-color: green;
}
```

### 分组选择器

对多个元素使用同一样式，减少代码量（和类选择器相似，但是不用在每个元素上写class="xxxx"了）

```css
h1, h2, p {
  text-align: center;
  color: red;
}
```

### 后代选择器

后代选择器，就是选择元素内部中所有的某一种元素，包括子元素和其他后代元素（如“孙元素”）。

我们可以定义后代选择器来创建一些规则，使这些规则在某些文档结构中起作用，而在另外一些结构中不起作用。 

````html
<h1>This is a <em>important</em> heading</h1> 
<p>This is a <em>important</em> paragraph.</p> 
````

如果您希望只对 h1 元素中的 em 元素应用样式，可以这样写：  

```css
 h1 em {color:red;} 
```

注意：两个元素之间的层次间隔可以是无限的。

## 盒子模型


![box-model](.\img\html\box-model.webp)

![img](img/html/box-model-details.png)

- 由里至外：内容（Width,Height） ->  填充（Padding）->  边框（Border）-> 外边距（Margin）



## 块级元素与行级元素

#### 行内元素

行内元素：<span> <a> <img>等

通过 display: inline; 可将行级元素转换为块级元素，

#### 块级元素 

块级元素：<h1> <div> <li> <p> <form>等。

通过 display: block; 可将行内元素转为块级元素。

###  删除与隐藏

```css
display: None; /*删除，不占用空间*/
visibility: hidden; /*隐藏，仍占据空间*/
```


