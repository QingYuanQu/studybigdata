---
title: 基于JSP的学生信息管理系统
date: 2023-05-07 17:03:00
categories:
- JavaEE
tags:
- JavaEE
- 基于JSP的学生信息管理系统
---

# 基于JSP的学生信息管理系统


### 相关Jar包  

 https://www.studybigdata.cn/file/javaee/jars/jsp.zip


### 初始化数据库及表的创建

```sql
set names gbk;
create database mybatis2 DEFAULT CHARSET utf8 collate utf8_general_ci;
use mybatis2;

drop table if exists t_student;

create table t_student(
    id int primary key auto_increment,
    name varchar(20) not null,
    age tinyint default null,
    sex char(1) default null,
    account varchar(16) default null,
    password varchar(64) default null,
    type_id int default null
);

insert into t_student(name, age,sex,account,password, type_id) values('张三', 18, 'f','zhangsan','123',1);
insert into t_student(name, age,sex,account,password, type_id) values('李四', 19, 'm','lisi',    '123',1);
insert into t_student(name, age,sex,account,password, type_id) values('王五', 20, 'f','wangwu',  '123',1);
```

### Java Source

##### 获取数据库连接对象(JDBCUtil.java)

```java
package com.studybigdata.javaee.jsp.student.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class JDBCUtil {
  public static final String URL = "jdbc:mysql://localhost:3306/mybatis2?characterEncoding=utf-8";
  public static final String USER = "root";
  public static final String PASSWORD = "123456";
  private static Connection conn = null;

  static{
    try{
	  // 高版本MySQL使用 com.mysql.cj.jdbc.Driver
      Class.forName("com.mysql.jdbc.Driver"); 
      conn = DriverManager.getConnection(URL, USER, PASSWORD);
    }catch(ClassNotFoundException e){
      e.printStackTrace();
    }catch(SQLException e){
      e.printStackTrace();
    }
  }

  public static Connection getConnection(){
    return conn;
  }
}
```

##### POJO(Student.java)

POJO: Plain Ordinary *Java* Object 普通Java对象。

```java
public class Student {
	private Integer id;
	private String name;
	private Integer age;
	private String sex;
	private String account;
	private String password;
	private Integer typeId;
//toString()、getter()、setter()略。
}
```



##### 数据访问对象(StudentDao.java)

```java
package com.studybigdata.javaee.jsp.student.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.ngweb.student.pojo.Student;
import org.ngweb.student.util.JDBCUtil;

public class StudentDao {
	//添加学生信息
	public void addStudent(Student student) throws SQLException{
		//获得与数据库的连接
		Connection conn = JDBCUtil.getConnection();
		//SQL语句
		String sql = "insert into t_student(id, name, age, sex, account, password, type_id) values (null,?,?,?,?,?,?)";
		//获得PreparedStatement对象
		PreparedStatement pst = conn.prepareStatement(sql);
		//设置sql中的参数
		pst.setString(1, student.getName());
		pst.setInt(2, student.getAge());
		pst.setString(3, student.getSex());
		pst.setString(4, student.getAccount());
		pst.setString(5, student.getPassword());
		pst.setInt(6, student.getTypeId());
		//操作数据库
		pst.execute();
	}
	
	//更新学生信息
	public void updataStudent(Student student) throws SQLException{
		//获得与数据库的连接
		Connection conn = JDBCUtil.getConnection();
		//SQL语句
		String sql = "update t_student set name=?, age=?,sex=?,account=?,password=?,type_id=? where id=?";
		//获得PreparedStatement对象
		PreparedStatement pst = conn.prepareStatement(sql);
		//设置sql中的参数
		pst.setString(1, student.getName());
		pst.setInt(2, student.getAge());
		pst.setString(3, student.getSex());
		pst.setString(4, student.getAccount());
		pst.setString(5, student.getPassword());
		pst.setInt(6, student.getTypeId());
		pst.setInt(7, student.getId());
		//操作数据库
		pst.execute();
	}
	
	//删除学生信息
	public void deleteStudent(int id) throws SQLException{
		//获得与数据库的连接
		Connection conn = JDBCUtil.getConnection();
		//SQL语句
		String sql = "delete from t_student where id=?";
		//获得PreparedStatement对象
		PreparedStatement pst = conn.prepareStatement(sql);
		//设置sql中的参数
		pst.setInt(1, id);
		//ִ操作数据库
		pst.execute();
	}
	
	//查询所有的学生信息
	public List<Student> query() throws SQLException{
		//获得与数据库的连接
		Connection conn = JDBCUtil.getConnection();
		//SQL语句
		String sql = "select * from t_student";
		//获得PreparedStatement对象
		PreparedStatement pst = conn.prepareStatement(sql);
		//获得结果集
		ResultSet rs = pst.executeQuery();
        List<Student> studentList = new ArrayList<Student>();
        Student s =null;
        while(rs.next()){
        	s = new Student();
        	s.setId(rs.getInt("id"));
        	s.setName(rs.getString("name"));
        	s.setAge(rs.getInt("age"));
        	s.setSex(rs.getString("sex"));
        	s.setAccount(rs.getString("account"));
        	s.setPassword(rs.getString("password"));
        	s.setTypeId(rs.getInt("type_id"));
        	studentList.add(s);
        }
        return studentList;
	}
	
	//根据id查询学生信息
	public Student getById(int id) throws SQLException{
		Student s = null;
		//获得与数据库的连接
		Connection conn = JDBCUtil.getConnection();
		//SQL语句
		String sql = "select * from t_student where id = ?";
		//获得PreparedStatement对象
		PreparedStatement pst = conn.prepareStatement(sql);
		//设置sql中的参数
		pst.setInt(1, id);
		//ִ获得结果集
		ResultSet rs = pst.executeQuery();
		while(rs.next()){
        	s = new Student();
        	s.setId(rs.getInt("id"));
        	s.setName(rs.getString("name"));
        	s.setAge(rs.getInt("age"));
        	s.setSex(rs.getString("sex"));
        	s.setAccount(rs.getString("account"));
        	s.setPassword(rs.getString("password"));
        	s.setTypeId(rs.getInt("type_id"));
		}
		return s;
	}

	//查询用户是否存在
	public boolean isExistent(Student student) throws SQLException{
		//获得与数据库的连接
		Connection conn = JDBCUtil.getConnection();
		//SQL语句
		String sql = "select * from t_student where account=? and password=?";
		//获得PreparedStatement对象
		PreparedStatement pst = conn.prepareStatement(sql);
		//设置sql中的参数
		pst.setString(1, student.getAccount());
		pst.setString(2, student.getPassword());
		//ִ获得结果集
		ResultSet rs = pst.executeQuery();
		while(rs.next()){
        	 return true;
		}
		return false;
	}
}
```

##### 测试类

在`test`包中新建测试类；

```java
public class Test {
	public static void main(String [] args) throws SQLException{
		
		StudentDao stuDao = new StudentDao();
		List<Student> stuList = stuDao.query();
		
		for(int i=0; i<stuList.size(); i++){
			System.out.println(stuList.get(i));
		}
	}
}
```

进行下述步骤前，请完成[基于前端的学生信息管理系统](../基于前端的学生信息管理系统)。

### JSP Source
在`基于前端的学生信息管理系统`中我们创建了多个文件扩展名为`html`的文件，将这些文件的扩展名修改为`jsp`。

#### 登录注销

##### login.jsp

将`index.html`复制为`login.jsp`，此页面用来接收用户输入的账号密码，将数据的提交地址设置为本页面，即设置 `action="#"`，本页面对用户输入的账号和密码与数据库中的数据进行比对，如果登录信息正确，则创建`session`对象，并则将用户重定向到首页；

```jsp
<!-- JSP page 指令 -->
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@ page import="com.studybigdata.javaee.jsp.student.pojo.Student" %>
<%@ page import="com.studybigdata.javaee.jsp.student.dao.StudentDao" %>


<!-- JSP 程序标识 -->
<%
    String msg="";
    request.setCharacterEncoding("UTF-8");
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    if(username!=null && password!=null){
        Student student = new Student();
        student.setAccount(username);
        student.setPassword(password);

        StudentDao studentDao = new StudentDao();

        if(studentDao.isExistent(student)){
            session.setAttribute("account", username);
            response.sendRedirect("index.jsp");
        }else{
            msg = "用户名或密码不正确";
            out.print(msg);
            request.setAttribute("msg", msg);
        }
    }
%>
```

##### logout.jsp

```jsp
<!-- JSP 脚本-程序标识 -->
<%
	session.invalidate();
%>
<!-- JSP 动作标识 -->
<jsp:forward page="login.jsp" />
```



#### 首页

##### index.jsp
复制`index.html`为`index.jsp`，在本页面中通过`StudentDao.query()`方法查询出所有学生`List<Student>`，设置为`request`对象的属性；将`request`对象转发到`view.jsp`中进行显示。
```jsp
<!-- JSP page 指令 -->
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@ page import="com.studybigdata.javaee.jsp.student.pojo.Student" %>
<%@ page import="com.studybigdata.javaee.jsp.student.dao.StudentDao" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>

<!-- JSP 脚本-程序标识 -->
<%
	StudentDao dao = new StudentDao();
	List<Student> list = dao.query();
	request.setAttribute("studentList", list);
%>
<!-- JSP 动作标识 -->
<jsp:forward page="view.jsp"></jsp:forward>
```



#### 查询

##### view.jsp
本页面将收到的所有学生数据通过JSP标准标签语言（`jstl`）和`el`表达式展示出来。
```jsp
<!-- JSP page 指令 -->
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<!--  taglib 指令 -->
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- JSTL JSP标准标签语法 -->
<c:forEach items="${studentList}" var="student">
  <tr>
    <td>${student.id}</td>
    <td>${student.name}</td>
    <td>${student.age}</td>
    <td>${student.sex=='m'?"男":"女"}</td>
    <td>${student.account}</td>
    <td>${student.password}</td>
    <td><a href="deleteOperation.jsp?id=${student.id}">删除</a></td>
    <td><a href="update.jsp?id=${student.id}">更新</a></td>
  </tr>
</c:forEach>
```
为注销操作增加注销处理地址`logout.jsp`

```jsp
<p>用户：${sessionScope.account} &nbsp;&nbsp;&nbsp;<a href="logout.jsp">注销</a></p>
```

为添加操作增加添加页面

```html
<a href="add.jsp">添加</a>
```

为查询按钮添加查询处理地址`findOperation.jsp`

```jsp
<form action="findOperation.jsp" method="post" class="formclass">
    id: <input type="text" name="id" value="" class="information"/>
    name: <input type="text" name="name" value="" class="information"/>
    age: <input type="text" name="age" value="" class="information"/>
    <input type="submit" value="查询" class="btn"/>
</form>
```





##### findOperation.jsp
本页面查询出符合条件的学生记录，转发回`view.jsp`
```jsp
<!-- JSP page 指令 -->
<%@ page import="com.studybigdata.javaee.jsp.student.pojo.Student" %>
<%@ page import="com.studybigdata.javaee.jsp.student.dao.StudentDao" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>


<!-- JSP 脚本-程序标识 -->
<%
    StudentDao studentDao = new StudentDao();
    String id = request.getParameter("id");
    List<Student> studentList = null;
    if(id==""){
    	studentList = studentDao.query();
    }else{
        Student student = studentDao.getById(Integer.parseInt(id));
        studentList = new ArrayList<Student>();
        studentList.add(student);
    }

    request.setAttribute("studentList", studentList);
%>
<jsp:forward page="view.jsp"/>
```



#### 增加

##### add.jsp

重命名`add.html`为`add.jsp`；当添加学生信息时，把学生信息提交到`addOperation.jsp`地址中，由`addOperation.jsp`将进行数据插入数据库；

##### addOperation.jsp
新增`addOperation.jsp`页面，根据`add.jsp`传递过来的数据，构造`Student`对象；  
`StudentDao`的`addStudent()`方法将`Student`对象插入到数据库的表中；  
新增成功后，重定向到`index.jsp`页面。

```jsp
<!-- JSP page 指令 -->
<%@ page import="com.studybigdata.javaee.jsp.student.pojo.Student" %>
<%@ page import="com.studybigdata.javaee.jsp.student.dao.StudentDao" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>

<!-- JSP 脚本-程序标识 -->
<%
    request.setCharacterEncoding("utf-8");
    StudentDao studentDao = new StudentDao();
    Student student = new Student();
    student.setName(request.getParameter("name"));
    student.setAge(Integer.parseInt(request.getParameter("age")));
    student.setSex(request.getParameter("sex"));
    student.setAccount(request.getParameter("account"));
    student.setPassword(request.getParameter("password"));
    student.setTypeId(Integer.parseInt(request.getParameter("typeId")));
    studentDao.addStudent(student);
    response.sendRedirect("index.jsp");
%>
```



#### 删除

##### deleteOperation.jsp

```jsp
<!-- JSP page 指令 -->
<%@ page import="com.studybigdata.javaee.jsp.student.dao.StudentDao" %>

<!-- JSP 脚本-程序标识 -->
<%
    request.setCharacterEncoding("utf-8");
    StudentDao studentDao = new StudentDao();
    int id = Integer.parseInt(request.getParameter("id"));
    studentDao.deleteStudent(id);
    response.sendRedirect("index.jsp");
%>
```

#### 更新

##### update.jsp

```jsp
<!-- JSP page 指令 -->
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@ page import="com.studybigdata.javaee.jsp.student.pojo.Student" %>
<%@ page import="com.studybigdata.javaee.jsp.student.dao.StudentDao" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>



<!-- JSP 脚本-程序标识： 读取被更新的学生信息 -->
<%
    String id = request.getParameter("id");
    StudentDao studentDao = new StudentDao();
    Student student = studentDao.getById(Integer.parseInt(id));
    request.setAttribute("student", student);
%>

<!-- 更新操作数据处理地址 -->
      <form action="updateOperation.jsp" method="post" onsubmit="return check()" class="contact_form">
        <input type="hidden" name="id" value="${student.id}" />
      <ul>
          <li class="usually">
            <span>用户名：</span>
              <!-- 将旧的学生信息读出，填充到表单中，供用户修改 -->
            <input type="text" name="name" value="${student.name}" />
          </li>

          <li class="usually">
            <span>年龄：</span>
            <input type="text" name="age" value="${student.age}" />
          </li>

          <li class="usually">
            <span>性别： </span>
            <input type="radio" name="sex" value="m" id="male" ${ student.sex=="m" ? "checked":"" } />
            <label for="male">男</label>
            <input type="radio" name="sex" value="f" id="female" ${ student.sex=="f" ? "checked":"" } />
            <label for="female">女</label>
          </li>

          <li class="usually">
            <span>账号：</span>
            <input type="text" name="account" value="${student.account}" />
          </li>

          <li class="usually">
            <span>密码：</span>
            <input type="text" name="password" value="${student.password}" />
          </li>

          <li class="usually">
            <span>类型：</span>
            <select name="typeId">
              <option value="1" ${student.typeId==1 ? "selected" :"" } >管理员</option>
              <option value="2" ${student.typeId==2 ? "selected" : "" } >用户</option>
            </select>
          </li>

          <li>
            <input type="submit" value="修改" class="submit" />
          </li>
        </ul>
      </form>
```

##### updateOperation.jsp

```jsp
<!-- JSP page 指令 -->
<%@ page import="com.studybigdata.javaee.jsp.student.pojo.Student" %>
<%@ page import="com.studybigdata.javaee.jsp.student.dao.StudentDao" %>

<!-- JSP 脚本-程序标识 -->
<%
    request.setCharacterEncoding("utf-8");

    StudentDao studentDao = new StudentDao();

    Student student = new Student();
    student.setId(Integer.parseInt(request.getParameter("id")));
    student.setName(request.getParameter("name"));
    student.setAge(Integer.parseInt(request.getParameter("age")));
    student.setSex(request.getParameter("sex"));
    student.setAccount(request.getParameter("account"));
    student.setPassword(request.getParameter("password"));
    student.setTypeId(Integer.parseInt(request.getParameter("typeId")));

    studentDao.updataStudent(student);

    response.sendRedirect("index.jsp");
%>
```

