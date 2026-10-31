---
title: Java Server Page(JSP)
date: 2023-05-07 17:03:00
categories:
- JavaEE
tags:
- Java Server Page
---

# Java Server Page(JSP)

## 基本结构

```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<body>

</body>
</html>
```

## 指令标识

### page指令

| page指令 | 属性                                   | 注释                                                      |
| -------- | -------------------------------------- | --------------------------------------------------------- |
|          | language="java"                        | 编程语言                                                  |
|          | contentType="text/html; charset=UTF-8" | 传输的内容类型和编码，还可以是css,javascript,图片等内容； |
|          | pageEncoding="UTF-8"                   | JSP文件编码；                                             |
|          | import="java.util.Date"                | 导入相关的类，可出现多次；                                |

建议书写格式：

```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page import="java.util.Date" %>
<%@ page import="java.util.ArrayList" %>
```



### include指令

包含**文件**

文件引用指令 include 用于将另外一个 jsp 插入到引用的位置（合并到当前文件中）。

##### index.jsp

```jsp
<%@ include file="header.jsp" %>
```

##### header.jsp

```jsp
<%@ page contentType="text/html; charset=UTF-8"%>
<h1 style="text-align:center;">学生信息管理系统</h1>
```

### taglib指令

见下文JSTL标准标签库。

## 脚本标识

### 声明标识

```jsp
<%!
    //声明类
    public class Person {

        private String name;
        private Integer age;
        private String address;
		
		//getter setter略。
        @Override
        public String toString() {
            return "Person [name=" + name + ", age=" + age + ", address=" + address + "]";
        }
    }

    //声明变量
    String welcome = "欢迎光临";

    //声明方法
    public String Hello(){
        return "Hello World";
    }

%>
```



### 程序标识

```jsp
<%
	Person p = new Person("张三",18,"山东省泰安市岱岳区");
	String address = "山东省枣庄市";
	p.setAddress(address);	
	
	out.println(p);
%>
```
> 程序标识中的Java语句相当于main方法中的java语句；程序标识中不能定义方法，声明的变量是局部变量；

### 表达式标识

```jsp
<%=p %>
<%=welcome %>
<%=Hello() %>
```

> 表达式标识 `<%=p %>` 相当于 `out.println(p);`

### 注释标识

```jsp
<%-- JSP注释，一般人看不到我。。。 --%>
<!-- HTML注释，普通用户也可以看到我 -->
```

## 动作标识

### include

包含**页面**

```jsp
<jsp:include page="other.jsp"></jsp:include>
```

### forward 

转发**页面**

```jsp
<jsp:forward page="other.jsp" ></jsp:forward>
```

## 内置对象

### out

```java
out.println("hello")
```

### request

##### 属性

```java
request.setAttribute("name", "zhangsan");
String name = (String) request.getAttribute("name");
```

### response

##### 重定向

```java
response.sendRedirect("another.jsp");
```

### session

会话

```java
session.setAttribute("account", username); //设置属性
session.getAttribute("account"); //查询属性值
session.invalidate(); //session失效
```

### application

应用

```java
application.setAttribute("count", 1); //设置属性
application.getAttribute("count"); //查询属性值
```



> 注意： 
>
> **JSP九大内置对象不能在声明标识中使用**:
>
> service方法中定义了内置对象，程序标识<% %>中的代码是放到service方法中运行的，所以可以直接在程序标识中使用内置对象；
> 		声明标识<%! %>的代码是和service方法平级的，没有内置对象，所以不能在声明标识中直接使用内置对象。
>
> **除非特殊改造**：
>
> `ServletContext application=getServletContext();`
> 		  `ServletConfig config =getServletConfig(); `
>
> https://blog.csdn.net/weixin_41824716/article/details/95937393
>
> https://blog.csdn.net/han_hhh/article/details/102905280

## EL表达式语言

```java
${1+2}
${1*2}
${3%2==0?"偶数":"奇数"} <!--奇数-->
```



##### 注意：

下面这种情况查询变量id的值为空

```jsp
<%
	id = 10
%>
${id} <!--取值为空-->
```



因为EL表达式是从作用域中查询变量，做如下改写：

```jsp
<%
	id = 10
    request.setAttribute("id", id);//将id设置成request作用域中的属性
%>

${id} 
```





## JSTL标准标签库

1. 导入jstl-1.2.jar包
2. 引入taglib指令

```jsp
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
```



##### out

```jsp
<c:out value = "hello" />
<c:out value = "${1+1 }" />
```

##### set

```jsp
<c:set var="score" value="82" scope="request" />
```

##### if

```jsp
<c:if test="${score>=80}" var="result">
	<c:out value="优秀" />
</c:if>

<!--c:if 标签没有配对的 else 标签，因此，只能将条件判断的结果保存到一个变量中，然后根据这个变量的值，取反，来实现 else 功能。-->
<c:if test="${!result}" >
	<p>不优秀</p>
</c:if>
```

##### forEach

```jsp
<!--  [1,100] -->
<c:forEach begin="1" end="100" step="1" var="i" >
${i}
</c:forEach>


<!--  [1,100]中的偶数 -->
<c:forEach begin="1" end="100" step="1" var="i" >

	<c:if test="${i%2==0}">
		${i}
	</c:if>
</c:forEach>
```



##### 小例子

遍历List

```jsp
<%
	List<String> list = new LinkedList<String>();
	list.add("张三");
	list.add("李四");
	list.add("王五");
	request.setAttribute("strList", list);
%>

<c:if test="${requestScope.strList!=null}">
	<c:forEach items="${requestScope.strList}" var="i" >
		${i}
	</c:forEach>
</c:if>
```

## EL与JSTL应用

##### Book.java

```java
public class Book {
	
	private String title;
	private String author;
	private double price;
	
	public Book(String title, String author, double price) { // 构造方法
		this.title = title;
		this.author = author;
		this.price = price;
	}
	// 此处省略 setter 和 getter 方法
}
```

##### show.jsp

```jsp
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.*" %>
<%@ page import="com.studybigdata.javaee.servlet.Book" %>

<%
  List<Book> list = new LinkedList<Book>(); // 初始化演示数据
  list.add(new Book("中国鸟类野外手册", "马敬能等", 85));
  list.add(new Book("艺术的故事", "贡布里希", 280));
  list.add(new Book("生存手册", "怀斯曼", 28));
  request.setAttribute("bookList", list); // 保存到 request，传递给下一个页面
%>

<table border="1" width="500">
	  <tr>
	    <td>书名</td>
	    <td>作者</td>
	    <td>价格</td>
	  </tr>
	  
	<c:forEach items="${requestScope.bookList}" var="i" >
		<tr>
			<td>${i.getTitle()}</td>
			<td>${i.getAuthor()}</td>
			<td>${i.getPrice()}</td>
		</tr>
	</c:forEach>
	
</table>
```

