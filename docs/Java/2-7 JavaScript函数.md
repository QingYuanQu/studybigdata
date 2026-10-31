---
title: 【实训2-7】JavaScript 函数
date: 2023-03-21 18:14:00
categories:
- JavaEE 
tags:
- JavaEE 
---

# 【实训2-7】JavaScript 函数

##  实训目的

学习 JavaScript 函数，会编写简单的函数。

## 实训内容介绍

- JavaScript 函数
- 全局变量
- 局部变量
- 实训总结

## JavaScript 函数

 在“【实训2-5】JavaScript 入门”中用过的 `alert() `就是一个函数，我们也可以编写自己的函数。 在控制台中，按照教材第36页的讲解，编写 `add()` 函数，并以 `2` 和 `3` 为参数调用。要求代码与教材完全一致。 观察运行的结果。 

## 全局变量

 在测试器上运行下述代码，这是演示全局变量的。
```javascript
function add(a, b){
  z = a + b; // 函数内，没有用var声明，是全局变量
  return z;
}

alert("函数add的返回值："+add(1, 2));  // 这里是 1 + 2
alert(typeof(z)); // 函数外，z的值是3，类型是number
alert("全局变量的值："+z);
```

 观察运行结果。

## 局部变量

重新打开一个标签页，然后打开控制台， 在控制台运行下述代码，与前一步不同，这是演示局部变量的。
```javascript
function add(a, b){
  var z = a + b; // 函数内，用var声明，成为局部变量
  return z;
}

alert("函数add的返回值："+add(1, 3));  // 这里是 1 + 3
alert(typeof(z)); // 函数外，z没有定义，类型是undefined
alert("局部变量的值："+z); // 函数外，z没有定义，运行时错误
//注意：在测试器内，如果前一次运行过全局变量的代码，这时 z 的值是前一次运行时的值 3
//如果以前没有运行过（不曾为全局变量赋值），或者点击了“清空所有”按钮，则 z 变量是没有定义
```


观察运行结果。

## 实训总结

 本次实训学习了 JavaScript 函数，还学习了全局变量和局部变量的区别。  