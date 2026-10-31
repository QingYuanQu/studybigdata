---
title: LayUI
date: 2022-03-23 15:55:26
categories:
- LayUI
tags:
- LayUI
---

# Lay UI

### 1\. 环境搭建

#### 1.1 下载

在官网https://www.ilayuis.com/即可完成下载。

![image-20230108102738037](img/LayUI/image-20230108102738037)

#### 1.2 创建项目

创建`Maven`项目，选择`create from archetype`，然后从列表中选择`maven-archetype-webapp`。

![image-20230108104959242](img/LayUI/image-20230108104959242)

设置项目的`GroupId`和`ArtifactId`

![image-20230108104257544](img/LayUI/image-20230108104257544)

#### 1.3 webapp

在`main`目录下，创建`java`目录，将下载的`layui`解压到`webapp`目录内，目录结构如下图：

![image-20230109103935775](img/LayUI/image-20230109103935775)

#### 1.4 导入依赖

```xml
<dependency>
    <groupId>org.apache.tomcat.embed</groupId>
    <artifactId>tomcat-embed-core</artifactId>
    <version>9.0.36</version>
</dependency>
<dependency>
    <groupId>org.apache.tomcat.embed</groupId>
    <artifactId>tomcat-embed-jasper</artifactId>
    <version>9.0.36</version>
</dependency>
```

#### 1.5 Tomcat配置

创建类`MainServer`，并设置`Tomcat`启动信息。

```java
import org.apache.catalina.LifecycleException;
import org.apache.catalina.startup.Tomcat;

import javax.servlet.ServletException;

public class MainServer {
    private static final String CONTEXT_PATH = "/";

    public static void main(String[] args) throws LifecycleException, ServletException {
        //创建tomcat对象
        Tomcat tomcat = new Tomcat();
        //设置启动端口
        tomcat.setPort(8088);
        //引导Http引擎
        tomcat.getConnector();

        tomcat.getHost().setAppBase(".");
        tomcat.addWebapp(CONTEXT_PATH, getAbsolutePath() + "src/main/webapp");
        tomcat.start();
        tomcat.getServer().await();
    }

    private static String getAbsolutePath() {
        String path = null;
        String folderPath = MainServer.class.getProtectionDomain().getCodeSource().getLocation().getPath();
        if (folderPath.indexOf("target") > 0) {
            path = folderPath.substring(0, folderPath.indexOf("target"));
        }
        return path;
    }
}
```

#### 1.6 JSP页面配置

##### 1.6.1 头信息标签

在页面的顶部引入 头信息标签

```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
```

##### 1.6.2 head

```html
<link rel="stylesheet" href="layui/css/layui.css">
<script src="layui/layui.js"></script>
```

### 2\. 页面元素

#### 2.1 布局

响应式栅格布局，每行分`12`等分。

*   `layui-container`居中显示有固定尺寸
*   `layui-fluid` 占满行宽

```html
<!-- <div class="layui-container"> -->
<div class="layui-fluid">
    <div class="layui-row">
        <div class="layui-col-md9 layui-col-lg6 layui-bg-orange">
            你的内容 9/12
        </div>
        <div class="layui-col-md3 layui-col-lg6 layui-bg-gray">
            你的内容 3/12
        </div>
    </div>

    <%--移动设备、平板、桌面端的不同表现：--%>
        <div class="layui-row">
            <div class="layui-col-xs6 layui-col-sm6 layui-col-md4 layui-col-lg3">
                移动：6/12 | 平板：6/12 | 桌面：4/12;
            </div>
            <div class="layui-col-xs6 layui-col-sm6 layui-col-md4 layui-col-lg3">
                移动：6/12 | 平板：6/12 | 桌面：4/12;
            </div>
            <div class="layui-col-xs4 layui-col-sm12 layui-col-md4 layui-col-lg3">
                移动：4/12 | 平板：12/12 | 桌面：4/12;
            </div>
            <div class="layui-col-xs4 layui-col-sm7 layui-col-md8 layui-col-lg3">
                移动：4/12 | 平板：7/12 | 桌面：8/12;
            </div>
            <div class="layui-col-xs4 layui-col-sm5 layui-col-md4 layui-col-lg3">
                移动：4/12 | 平板：5/12 | 桌面：4/12;
            </div>
        </div>
</div>
```

#### 2.2 字体图标

`class="layui-icon 具体的图表样式"`

```html
<i class="layui-icon layui-icon-heart-fill"></i>
<i class="layui-icon layui-icon-heart"></i>
<i class="layui-icon layui-icon-heart"></i>
<i class="layui-icon layui-icon-light" style="font-size: 30px; color: #1E9FFF;"></i>
```

#### 2.3 按钮

`class="layui-btn 主题 样式"`

```html
<button type="button" class="layui-btn">标准的按钮</button>
<a href="http://www.layui.com" class="layui-btn">可跳转的按钮</a>
<a href="http://www.layui.com" class="layui-btn layui-btn-primary">主题的按钮</a>
<a href="http://www.layui.com" class="layui-btn layui-btn-primary layui-btn-sm">主题的按钮</a>
<a href="http://www.layui.com" class="layui-btn layui-btn-primary layui-btn-radius ">圆角的按钮</a>
<a href="http://www.layui.com" class="layui-btn layui-btn-primary layui-btn-sm  layui-btn-radius ">
    <i class="layui-icon layui-icon-heart-fill" style="font-size: 30px; color: #1E9FFF;"></i>
    带图标的按钮
</a>
```

#### 2.4 表单

`class="layui-form"`

```html
<form class="layui-form" action="">
    <div class="layui-form-item">
        <label class="layui-form-label">输入框</label>
        <div class="layui-input-block">
            <input type="text" name="title" required  lay-verify="required" placeholder="请输入标题" autocomplete="off" class="layui-input">
        </div>
    </div>
    <div class="layui-form-item">
        <label class="layui-form-label">密码框</label>
        <div class="layui-input-inline">
            <input type="password" name="password" required lay-verify="required" placeholder="请输入密码" autocomplete="off" class="layui-input">
        </div>
        <div class="layui-form-mid layui-word-aux">辅助文字</div>
    </div>
    <div class="layui-form-item">
        <label class="layui-form-label">选择框</label>
        <div class="layui-input-block">
            <select name="city" lay-verify="required">
                <option value="">请选择城市</option>
                <option value="0">北京</option>
                <option value="1">上海</option>
                <option value="2">广州</option>
                <option value="3">深圳</option>
                <option value="4">杭州</option>
            </select>
        </div>
    </div>
    <div class="layui-form-item">
        <label class="layui-form-label">复选框</label>
        <div class="layui-input-block">
            <input type="checkbox" name="like[write]" title="写作">
            <input type="checkbox" name="like[read]" title="阅读" checked>
            <input type="checkbox" name="like[dai]" title="发呆">
        </div>
    </div>
    <div class="layui-form-item">
        <label class="layui-form-label">开关</label>
        <div class="layui-input-block">
            <input type="checkbox" name="switch" lay-skin="switch">
        </div>
    </div>
    <div class="layui-form-item">
        <label class="layui-form-label">单选框</label>
        <div class="layui-input-block">
            <input type="radio" name="sex" value="男" title="男">
            <input type="radio" name="sex" value="女" title="女" checked>
        </div>
    </div>
    <div class="layui-form-item layui-form-text">
        <label class="layui-form-label">文本域</label>
        <div class="layui-input-block">
            <textarea name="desc" placeholder="请输入内容" class="layui-textarea"></textarea>
        </div>
    </div>
    <div class="layui-form-item">
        <div class="layui-input-block">
            <button class="layui-btn layui-btn-lg" lay-submit lay-filter="formDemo">立即提交</button>
            <button type="button" class="layui-btn" id="test1">
                <i class="layui-icon">&#xe67c;</i>上传图片
            </button>
        </div>
    </div>
</form>
```

##### JavaScript

```javascript
<script>
    // 必须要导入form模块，才能保证表单正常渲染
    layui.use('form', function(){
        var form = layui.form;
        //监听提交
        form.on('submit(formDemo)', function(data){// data就是表单中的所有数据
            layer.msg(JSON.stringify(data.field));
            return false;
        });
    });
</script>
```

#### 2.5 数据表格

##### 2.5.1 数据

`data.jsp`

```json
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
{"msg":"no data",
"code":0,
"data":[{"id":1,"username":"shine1","sex":"男","city":"保定","score":100},
{"id":2,"username":"shine2","sex":"女","city":"石家庄","score":100},
{"id":3,"username":"shine3","sex":"男","city":"邢台","score":100}],
"count":100}
```

数据格式解释:

*   **code**: `0`代表查询成功，`1`会显示`msg`中的内容。
*   **count** 是为分页准备的，共有多少条数据

##### 2.5.2 动态表格

```html
<table id="demo" lay-filter="test"></table>
<script>
    // 必须要导入 table模块 layui.use('table',...)
    layui.use('table', function(){
        var table = layui.table;
        // 为表格填充数据
        table.render({
            elem: '#demo'
            ,height: 312
            ,toolbar:true
            ,url: 'data.jsp' //获取数据
            ,page: false //不开启分页
            ,cols: [[ //表头
                {field:'id', title: 'ID', sort: true}
                ,{field:'username', width:80, title: '用户名'}
                ,{field:'sex', width:80, title: '性别', sort: true}
                ,{field:'city',  title: '城市'} //没定义宽度则占满剩余所有宽度，都不定义则所有列均分
                ,{field:'score',width:80, title: '评分', sort: true}
            ]]
        });
    });
</script>
```

##### 2.5.3 分页参数

分页条细节定制

```javascript
page: {limit:1//每页显示1条
    ,limits:[1,2,3] //可选每页条数
    ,first: '首页' //首页显示文字，默认显示页号
    ,last: '尾页'
    ,prev: '<em>←</em>' //上一页显示内容，默认显示 > <
    ,next: '<i class="layui-icon layui-icon-next"></i>'
    ,layout:['prev', 'page', 'next','count','limit','skip','refresh'] //自定义分页布局
     } //开启分页
```

##### 2.5.4 显示工具栏

右上角工具按钮 `toolbar: true`

```json
toolbar:true
```

##### 2.5.5 操作按钮

为每行增加操作按钮

```javascript
cols: [[ //表头
    ... ...
    ,{field:"right",title:"操作",toolbar: '#barDemo'} // 将此行代码追加到cols内。
]]



<!-- 如下script可以定义在页面的任何位置 -->
<script type="text/html" id="barDemo">
        <a class="layui-btn layui-btn-xs" lay-event="edit">编辑</a>
        <a class="layui-btn layui-btn-danger layui-btn-xs" lay-event="del">删除</a>
</script>
```

##### 2.5.6 操作按钮回调

按钮的单击事件

```javascript
// 事件注册
table.on('tool(test)', function(obj){
    var data = obj.data; //获得当前行数据
    //获得 lay-event 对应的值（也可以是表头的 event 参数对应的值）
    var layEvent = obj.event;
    var tr = obj.tr; //获得当前行 tr 的 DOM 对象（如果有的话）
    if(layEvent === 'del'){ //删除
        layer.confirm('真的删除行么', function(index){
            // 向服务端发送删除请求
            // 此处可以发送ajax
            obj.del(); //删除对应行（tr）的DOM结构
            layer.close(index);
        });
    } else if(layEvent === 'edit'){ //编辑
        // 向服务端发送更新请求
        // 同步更新缓存对应的值
        obj.update({
            username: 'shine001',
            city: '北京',
            sex:'女',
            score:99});
    }
});
```

#### 2.6 导航nav

导航条

*   class="layui-nav" 水平导航条

*   class="layui-nav layui-nav-tree" 垂直导航条

```html
<ul class="layui-nav layui-nav-tree" lay-filter="">
    <li class="layui-nav-item"><a href="">最新活动</a></li>
    <li class="layui-nav-item layui-this"><a href="">产品</a></li>
    <li class="layui-nav-item"><a href="">大数据</a></li>
    <li class="layui-nav-item">
        <a href="javascript:;">解决方案</a>
        <dl class="layui-nav-child"> <!-- 二级菜单 -->
            <dd><a href="">移动模块</a></dd>
            <dd><a href="">后台模版</a></dd>
            <dd><a href="">电商平台</a></dd>
        </dl>
    </li>
    <li class="layui-nav-item"><a href="">社区</a></li>
</ul>
<script>
    //注意：导航 依赖 element 模块，否则无法进行功能性操作
    layui.use('element', function(){});
</script>
```

#### 2.7 动画

`LayUI`提供了动画支持

```html
<!-- 整个div会在页面显示时，以特定动画显示出来 -->
<div class="layui-anim layui-anim-up" style="height: 100px">aa</div>
<!-- 额外添加样式类：layui-anim-loop 使得动画循环运行 -->
<div class="layui-anim layui-anim-rotate layui-anim-loop"
     style="text-align:center;line-height: 100px;margin-left:50px;height: 100px;width:100px">bb</div>
```

> https://www.ilayuis.com/doc/element/anim.html

### 3\. 内置模块

#### 3.1 弹窗layer

##### 3.1.1 弹窗方法

###### msg

```javascript
// 导入 layer模块
layui.use(["layer"],function(){
    var layer = layui.layer;
    //layer.msg("hello world!!");
    layer.msg("确定吗？",{btn:["确定！","放弃！"],
                      yes:function(i){layer.close(i);layer.msg("yes!!!")},
                      btn2:function(i){layer.close(i);layer.msg("no!!!")}}
             );
}）
```

###### alert

```javascript
//0-6 7种图标  0:warning  1:success  2:error  3:question  4:lock  5:哭脸  6：笑脸
layer.alert("alert弹框蓝",
            {title:'alert',icon:6 },
            function(){//点击“确定”按钮时的回调
    layer.msg("好滴");
}
           );
```

###### confirm

```javascript
layer.confirm("你确定要删除吗?",
              {shade:false,icon:3,btn:["好滴","不行"]},
              function(){layer.msg("好滴！");},
              function(){layer.msg("不行！")}
             );
```

##### 3.1.2 弹窗属性

*   `type`弹窗类型，可选值`0-4`
*   `title`弹窗标题，可选值 `text/array`
*   `content`弹窗内容，可选值`text/html/dom`

###### html

```html
<div id="testmain" style="display:none;padding:10px; height: 173px; width: 275px;">
    hello world!
</div>
<button type="button">click</button>
```

###### JavaScript

```javascript
layer.open({
    type:1,// 消息框，没有确定按钮
    title:["hello","padding-left:5px"], // 标题，及标题样式
    content:layui.$("#testmain"), // dom格式
    offset:'rb',//可以在右下角显示
    shade:false //是否遮罩
});

layer.open({
    type:2,// iframe加载，需要一个url
    content:"/nav.jsp"
});
```

#### 3.2 日期框layDate

###### html

```html
<form class="layui-form layui-form-pane" action="" method="post">
    <!-- layui-form-item 一个输入项-->
    <div class="layui-form-item">
        <label class="layui-form-label">生日</label>
        <!-- layui-input-block 输入框会占满除文字外的整行 -->
        <div class="layui-input-block">
            <input readonly id="birth" type="text" name="birth" placeholder="请选择生日日期" autocomplete="off" class="layui-input">
        </div>
    </div>
</div> 
```

###### JavaScript

```javascript
layui.use(["laydate","form","upload","layer"],function(){
    var laydate = layui.laydate;
    var layer  = layui.layer;
    //执行一个laydate实例
    laydate.render({
        elem: '#birth', //指定元素
        format:'yyyy/MM/dd',
        value:'2012/12/12' //默认值
        // value:new Date() //默认值
    });
});
```

#### 3.3 上传按钮upload

##### html

```html
<form class="layui-form layui-form-pane" action="" method="post">
    <!-- layui-form-item 一个输入项-->
    <div class="layui-form-item">
        <div class="layui-input-block">
            <button class="layui-btn layui-btn-lg" lay-submit lay-filter="formDemo">立即提交</button>
            <button type="button" class="layui-btn" id="test1">
                <i class="layui-icon">&#xe67c;</i>上传图片
            </button>
        </div>
    </div>
</form>
```

##### JavaScript

```javascript
layui.use(["laydate","form","upload","layer"],function(){
    
	var upload = layui.upload;
    var layer  = layui.layer;
    //执行实例
    var uploadInst = upload.render({
        elem: '#test1' //绑定元素
        ,url: '/data.jsp' //上传接口
        //,accept:'images' // file代表所有文件，默认是images代表图片
        ,size:100 // 文件最大100kb
        ,done: function(res){
            //上传完毕回调
            layer.msg("ok");
        }
        ,error: function(){
            //请求异常回调
            layer.msg("error");
        }
    });
});
```

#### 3.4 轮播图carousel

##### html

```html
<div class="layui-carousel" id="test1">
    <div carousel-item style="text-align: center;line-height: 280px">
        <div>条目1</div>
        <div>条目2</div>
        <div>条目3</div>
        <div>条目4</div>
        <div>条目5</div>
    </div>
</div>
```

##### JavaScript

```javascript
layui.use(['carousel'], function(){
    var carousel = layui.carousel;
    //建造实例
    carousel.render({
        elem: '#test1'
        ,width: '100%' //设置容器宽度
        ,arrow: 'always' //始终显示箭头
    });
});
```


