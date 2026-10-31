<!-- Slide number: 1 -->
# 第9章 数据可视化后起之秀——pyecharts

![](图片1.jpg)
· 绘制常用图表
· 绘制组合图表
· 定制图表主题
· 整合Web框架

### Notes:

<!-- Slide number: 2 -->
 学习目标
掌握 图表类，配置项，渲染图表
2

1

了解 安装pyecharts
了解
熟悉
掌握

掌握
熟悉 定制图表主题，整合Web框架
4

掌握 常用图表、组合图表
3

### Notes:

<!-- Slide number: 3 -->
目录页

![](图片18.jpg)
9.1    pyecharts概述
9.2   pyecharts基础知识
9.3    绘制常用图表
9.4    绘制组合图表
9.5   定制图表主题

<!-- Slide number: 4 -->
目录页

![](图片18.jpg)
9.6   整合Web框架
9.7   实例：虎扑社区分析
9.8   本章小结

<!-- Slide number: 5 -->
目录页

![](图片18.jpg)

9.1    pyecharts概述
9.2   pyecharts基础知识
9.3    绘制常用图表
9.4    绘制组合图表
9.5   定制图表主题

<!-- Slide number: 6 -->
9.1 pyecharts概述
matplotlib作为Python中著名的基础绘图库，它拥有着极其丰富的可视化功能，但其仍存在诸多不足，比如图表无法与用户交互、 API过于复杂等。为此，Python中引入了可视化神器——pyecharts库，使用pyecharts可以快速地生成效果惊艳的Echarts 图表。

![](Picture6.jpg)

<!-- Slide number: 7 -->
9.1 pyecharts概述
自2013年6月百度EFE数据可视化团队研发的Echarts 1.0发布到GitHub网站以来，一直备受业界权威的关注并获得广泛好评，成为目前成熟且流行的可视化图表工具，被应用到诸多数据可视化的开发领域。Python作为数据分析领域最受欢迎的语言，也加入到Echarts的使用行列，并研发出方便Python开发者使用的数据可视化工具，自此便诞生了pyecharts库。

![](图片1.jpg)

<!-- Slide number: 8 -->
9.1 pyecharts概述
与matplotlib相比， pyecharts库具有以下优势：
简洁的API使开发者使用起来非常便捷，且支持链式调用。
程序可在主流的Jupyter Notebook或JupyterLab工具上运行。
程序可以轻松地集成至 Flask、Sanic、Django 等主流的Web框架中。
灵活的配置项可以轻松搭配出精美的图表。
详细的文档和示例可以帮助开发者快速地上手。
400多个地图文件、原生百度地图为地理数据可视化提供强有力的支撑。

<!-- Slide number: 9 -->
9.1 pyecharts概述
在使用pyecharts进行开发之前，开发者需要先在本地计算机中安装pyecharts。pyecharts官方支持 v0.5.x和v1两个版本，两个版本之间互不兼容，其中v0.5.x是较早的版本，且已经停止维护；v1是一个全新的版本，它支持Python3.6以上的开发环境。截止到本书完稿时，pyecharts的最新版本为1.5.1。

![](Picture6.jpg)

<!-- Slide number: 10 -->
9.1 pyecharts概述
打开Anaconda Prompt工具，在提示符的后面输入如下命令：
命令

conda install pyecharts
安装完成后，在命令提示符后面输入python，之后输入如下导入语句：

from pyecharts.charts import Bar
示例
执行以上语句后，若Anaconda Prompt窗口没有出现任何错误信息，说明pyecharts安装成功，否则说明安装失败。

<!-- Slide number: 11 -->
多学一招：Echarts

![https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1588673906452&di=785a35df03b10722f4c510225358a567&imgtype=0&src=http%3A%2F%2Fimg1.juimg.com%2F160107%2F330826-16010GZ00148.jpg](Picture2.jpg)
Echarts（Enterprise Charts，商业产品图表库），是一个使用 JavaScript 编写的、开源的可视化图表库，它提供了一系列直观且生动的、可交互的、可高度个性化定制的图表，可以流畅地运行在 PC 和移动设备上，并且兼容当前绝大部分浏览器（IE8/9/10/11、Chrome、Firefox、Safari等）。

<!-- Slide number: 12 -->
多学一招：Echarts

![https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1588673906452&di=785a35df03b10722f4c510225358a567&imgtype=0&src=http%3A%2F%2Fimg1.juimg.com%2F160107%2F330826-16010GZ00148.jpg](Picture2.jpg)
Echarts的底层基于ZRender（二维绘图引擎，支持Canvas、SVG、VML等多种渲染方法）创建了坐标系、图例、提示框等基础组件，并基于这些组件创建了丰富的图表，包括常见的折线图、柱形图、散点图、饼图等；用于地理数据可视化的统计地图、热力图等；用于关系数据可视化的树状图、旭日图；用于多维数据可视化的平行坐标；用于BI 的漏斗图、仪表盘，还有任意混搭展现的组合图表。

<!-- Slide number: 13 -->
多学一招：Echarts
标题组件：包括主标题和副标题，位于图表的左上角。
图例组件：位于图表的顶部中心位置，用户通过单击可显示或隐藏图例项对应的图形。
提示框组件：用于显示鼠标悬浮在图形上方的提示内容。
数据区域缩放组件：用于供用户选择关注细节的数据信息、概览图形数据的整体或去除离群点的影响 。
视觉映射组件：标识某一数值范围内数值及颜色对应关系的控件，可细分为分段型视觉映射组件和连续型视觉映射组件。

![123](图片1.jpg)
Echarts生成的气泡图

<!-- Slide number: 14 -->
多学一招：Echarts

![](图片1.jpg)

除了这些公共组件，还有很多其他可供用户交互的组件，例如时间线等，大家可到pyecharts官网进行深入学习，此处不再赘述。

<!-- Slide number: 15 -->
目录页

![](图片18.jpg)
9.1    pyecharts概述

9.2   pyecharts基础知识
9.3    绘制常用图表
9.4    绘制组合图表
9.5   定制图表主题

<!-- Slide number: 16 -->
9.2.1 快速绘制图表
示例

# 创建 Bar 类的对象 , 并指定画布的大小
bar = Bar(init_opts=opts.InitOpts(
                 width='600px', height='300px' ))
# 添加 x 轴和 y 轴的数据
bar.add_xaxis(["衬衫", "羊毛衫", "雪纺衫",
                         "裤子", "高跟鞋", "袜子"])
bar.add_yaxis("商家A", [5, 20, 36, 10, 75, 90])
# 设置标题、y 轴标签
bar.set_global_opts(title_opts=opts.TitleOpts(title="柱形图示例"),yaxis_opts=opts.AxisOpts(
name="销售额(万元)", name_location="center",
name_gap=30))
bar.render_notebook()

![](图片11.jpg)

<!-- Slide number: 17 -->
9.2.1 快速绘制图表

![](图片1.jpg)

与matplotlib相比，pyecharts通过更少的代码便绘制了带有标题、图例、注释文本的柱形图。

<!-- Slide number: 18 -->
多学一招：链式调用

pyecharts在v1版本增加了链式调用的功能。
链式调用是指简化同一对象多次访问属性或调用方法的编码方式，以避免多次重复使用同一个对象变量，使代码变得简洁、易懂。
示例

bar = (
    Bar(init_opts=opts.InitOpts(width='600px', height='300px'))
    .add_xaxis(["衬衫", "羊毛衫", "雪纺衫", "裤子", "高跟鞋", "袜子"])
    .add_yaxis("商家A", [5, 20, 36, 10, 75, 90])
    .set_global_opts(title_opts=opts.TitleOpts(title="柱形图示例"))
)
bar.render_notebook()

<!-- Slide number: 19 -->
9.2.2 认识图表类

![](图片1.jpg)
pyecharts库支持绘制30余种丰富的Echarts 图表，针对每种图表均提供了相应的类，并将这些图表类封装到pyecharts.charts模块中 。
常用图表类

<!-- Slide number: 20 -->
9.2.2 认识图表类
前面介绍的图表类均继承自Base基类，它们都可以使用与类同名的构造方法创建相应的图表实例。例如，Bar类的构造方法的语法格式如下：
语法

Bar(init_opts=opts.InitOpts())
以上方法的init_opts参数表示初始化配置项，该参数需要接收一个InitOpts类的对象，通过构建的InitOpts类对象为图表指定一些通用的属性，比如画布大小等。
示例

bar = Bar(init_opts=opts.InitOpts(width='600px', height='300px'))

<!-- Slide number: 21 -->
9.2.3 认识配置项

![](图片1.jpg)
pyecharts遵循“先配置后使用”的基本原则。pyecharts.options模块中包含众多关于定制图表组件及样式的配置项。按照配置内容的不同，配置项可以分为全局配置项和系列配置项。

<!-- Slide number: 22 -->
9.2.3 认识配置项

![](图片6.jpg)
全局配置项
全局配置项是一些针对图表通用属性的配置项，包括初始化属性、标题组件、图例组件、工具箱组件、视觉映射组件、提示框组件、数据区域缩放组件，其中每个配置项都对应一个类。
pyecharts的全局配置项

<!-- Slide number: 23 -->
9.2.3 认识配置项
若pyecharts需要为图表设置全局配置项（InitOpts除外），则需要将全局配置项传入set_global_options()方法。set_global_options()方法的语法格式如下：
语法

set_global_opts(self, title_opts=opts.TitleOpts(),
legend_opts=opts.LegendOpts(),…, axispointer_opts=None)
title_opts：表示标题组件的配置项。
legend_opts：表示图例组件的配置项。
tooltip_opts：表示提示框组件的配置项。
toolbox_opts：表示工具箱组件的配置项。
brush_opts：表示区域选择组件的配置项。

<!-- Slide number: 24 -->
9.2.3 认识配置项
若pyecharts需要为图表设置全局配置项（InitOpts除外），则需要将全局配置项传入set_global_options()方法。set_global_options()方法的语法格式如下：
语法

set_global_opts(self, title_opts=opts.TitleOpts(),
legend_opts=opts.LegendOpts(),…, axispointer_opts=None)
xaxis_opts，yaxis_opts：表示x、y轴的配置项。
visualmap_opts：表示视觉映射组件的配置项。
datazoom_opts：表示数据区域缩放组件的配置项。
graphic_opts：表示原生图形元素组件的配置项。
axispointer_opts：表示坐标轴指示器组件的配置项。

<!-- Slide number: 25 -->
9.2.3 认识配置项
系列配置项

![](图片1.jpg)
系列配置项是一些针对图表特定元素属性的配置项，包括图元样式、文本样式、标签、线条样式、标记样式、填充样式等，其中每个配置项都对应一个类。
pyecharts的系列配置项

<!-- Slide number: 26 -->
9.2.3 认识配置项
前面介绍的系列配置项类都可以通过与之同名的构造方法创建实例。
创建一个标签配置项：
示例

label_opts = opts.LabelOpts(is_show=True, position='right',
color='gray', font_size=14, rotate=10)
以上示例中，LabelOpts()方法的参数is_show设为True，表示显示标签；参数position设为'right'，表示标注于图形右方；参数color设为'gray'，表示标签文本的颜色为灰色；参数font_size设为14，说明标签文本的字体大小为14号；参数rotate设为10，说明标签逆时针旋转10度。

<!-- Slide number: 27 -->
9.2.3 认识配置项
若pyecharts需要为图表设置系列配置项，则需要将系列配置项传入add()或add_xx()方法（直角坐标系图表一般使用add_yaxis()方法）中。
示例

bar.add_yaxis(“商家A”, [5, 20, 36, 10, 75, 90],
                        label_opts=opts.LabelOpts(is_show=False))

<!-- Slide number: 28 -->
多学一招：创建配置项
pyecharts可以通过构造方法或字典两种方式创建配置项，两者是等价的。

bar = Bar(dict(width="600px", height="300px"))
# 或者
bar = Bar({"width": "600px", "height": "300px"})
示例

bar = Bar(init_opts=opts.InitOpts(
width="600px", height="300px"))
示例

<!-- Slide number: 29 -->
9.2.4 渲染图表
图表基类Base主要提供了两个渲染图表的方法：render()和render_notebook() 。

![](Picture6.jpg)

<!-- Slide number: 30 -->
9.2.4 渲染图表
render()方法
render()方法用于将图表渲染到HTML文件，默认为位于程序根目录的render.html文件。

render(self, path="render.html", template_name="simple_chart.html",
env=None, **kwargs)
语法
path：表示生成文件的路径，默认为“render.html”。
template_name：表示模板的路径。
render()方法会返回HTML文件的路径字符串。

<!-- Slide number: 31 -->
9.2.4 渲染图表
render_notebook()方法
render_notebook()方法用于将图表渲染到Jupyter Notebook工具中，它无需接收任何参数。
示例

bar.render_notebook()

<!-- Slide number: 32 -->
目录页

![](图片18.jpg)
9.1    pyecharts概述
9.2   pyecharts基础知识

9.3    绘制常用图表
9.4    绘制组合图表
9.5   定制图表主题

<!-- Slide number: 33 -->
9.3.1 绘制折线图
pyecharts绘制各种图表的过程大致相同，可以分为以下几步：
（1）创建与图表对应类的对象。
（2）添加图表数据。
（3）添加图表系列配置项。
（4）添加图表全局配置项。
（5）渲染图表。

![](Picture6.jpg)

<!-- Slide number: 34 -->
9.3.1 绘制折线图
pyecharts的Line类表示折线图，该类中提供了一个add_yaxis()方法，使用add_yaxis()方法可以为折线图添加数据和配置项。
语法

add_yaxis(self, series_name, y_axis, is_selected=True,
is_connect_nones=False, xaxis_index=None, …itemstyle_opts= None)
series_name：表示系列的名称，显示于提示框和图例中。
y_axis：表示系列数据。
color：表示系列的注释文本的颜色。
is_symbol_show：表示是否显示标记及注释文本，默认为True。

<!-- Slide number: 35 -->
9.3.1 绘制折线图
pyecharts的Line类表示折线图，该类中提供了一个add_yaxis()方法，使用add_yaxis()方法可以为折线图添加数据和配置项。
语法

add_yaxis(self, series_name, y_axis, is_selected=True,
is_connect_nones=False, xaxis_index=None, …itemstyle_opts= None)
symbol：表示标记的图形，可以为'circle'（圆形）、'rect'（矩形）、'roundRect'（圆角矩形）、'triangle'（三角形）、'diamond'（菱形）、'pin'（大头针）、'arrow'（箭头）、'none'（无）。
symbol_size：表示标记的大小，可以接收单一数值，也可以接收诸如 [width, height]的数组。
stack：表示将轴上同一类目的数据堆叠放置。

<!-- Slide number: 36 -->
9.3.2 绘制饼图或圆环图
pyecharts的Pie类表示饼图，该类中提供了一个add()方法，使用add()方法可以为饼图添加数据和配置项。
语法

add(self, series_name, data_pair, color=None, radius=None, center=None,
rosetype=None, is_clockwise=True,…, itemstyle_opts=None)
series_name：表示系列的名称，显示于提示框和图例中。
data_pair：表示系列数据帧。
radius：表示饼图的半径，可以接收一个包含两个元素的数组，其中数组的第一项为内半径，第二项为外半径。
center：表示饼图的中心坐标。
is_clockwise：表示饼图的扇区是否按顺时针排布。

<!-- Slide number: 37 -->
9.3.3 绘制散点图

pyecharts的Scatter类表示散点图，EffectScatter类表示带有涟漪特效的散点图，这两个类中均提供了一个add_yaxis()方法，使用add_yaxis()方法可以为散点图添加数据和配置项。
语法

add_yaxis(self, series_name, y_axis, is_selected=True, xaxis_index=None,
yaxis_index=None, color=None,…, itemstyle_opts=None)
series_name：表示系列的名称，显示于提示框和图例中。
y_axis：表示系列数据。
is_selected：表示是否选中图例。
symbol：表示标记的图形。
symbol_size：表示标记的大小。

<!-- Slide number: 38 -->
9.3.4 绘制3D柱形图

pyecharts的Bar3D类表示3D柱形图，该类中提供了一个add()方法，使用add()方法可以为3D柱形图添加数据和配置项。
语法

add(self, series_name, data, shading=None, itemstyle_opts=None,
,…,grid3d_opts=opts.Grid3DOpts())
series_name：表示系列的名称。
data：表示数据。
shading：表示阴影。
xaxis3d_opts：表示x轴的配置项。
yaxis3d_opts：表示y轴的配置项。
zaxis3d_opts：表示z轴的配置项。

<!-- Slide number: 39 -->
9.3.5 绘制统计地图

pyecharts的Map类表示统计地图，该类中提供了一个add()方法，使用add()方法可以为统计地图添加数据和配置项。
语法

add(self, series_name, data_pair, maptype="china", is_selected=True,
is_roam=True, center=None, …, emphasis_itemstyle_opts=None)
series_name：表示系列的名称。
data_pair：表示数据项，可以为诸如(坐标点名称, 坐标点值)形式的值。
maptype：表示地图的类型。
zoom：表示当前视角的缩放比例，默认值为1。
is_map_symbol_show：表示是否显示标记图形。

<!-- Slide number: 40 -->
9.3.6 绘制漏斗图

pyecharts的Funnel类表示漏斗图，该类中提供了一个add()方法，使用add()方法可以为漏斗图添加数据和配置项。
语法

add(self, series_name, data_pair, is_selected=True, color=None,
sort_="descending", gap=0, , itemstyle_opts=None)
series_name：表示系列的名称。
data_pair：表示系列数据项。
is_selected：表示是否选中图例。
sort_：表示数据排序，可以取值为'ascending'、'descending'或'none'。
gap：表示数据图形的间距，默认为0。

<!-- Slide number: 41 -->
9.3.7 绘制桑基图

pyecharts的Saneky类表示桑基图，该类中提供了一个add()方法，使用add()方法可以为桑基图添加数据和配置项。
语法

add(self, series_name, nodes, links, is_selected=True, node_width=20,
node_gap=8, …, tooltip_opts=None)
series_name：表示系列的名称。
nodes：表示分支的序列。
links：表示链接的序列。
node_width：表示分支的宽度。
node_gap：表示分支的间隔。

<!-- Slide number: 42 -->
目录页

![](图片18.jpg)
9.1    pyecharts概述
9.2   pyecharts基础知识
9.3    绘制常用图表

9.4    绘制组合图表
9.5   定制图表主题

<!-- Slide number: 43 -->
9.4 绘制组合图表

除了前面介绍的单图表，pyecharts也支持绘制组合图表，即同一画布显示的多个图表。多个图表按照不同的组合方式，可以分为并行多图、顺序多图、选项卡多图和时间轮播多图。

![](Picture6.jpg)

<!-- Slide number: 44 -->
9.4.1 并行多图

pyecharts.charts的Grid类表示并行排列的组合图表，它可以采用左右布局或上下布局的方式显示多个图表。Grid类中包含一个add()方法，使用add()方法可以为组合图表添加图表或配置项。
语法

add(self, chart, grid_opts, grid_index=0, is_control_axis_index=False)
chart：表示图表。
grid_opts：表示直角坐标系配置项。
grid_index：表示直角坐标系网格索引，默认为0。
is_control_axis_index：表示是否由自己控制坐标轴索引，默认为False。

<!-- Slide number: 45 -->
9.4.2 顺序多图

pyecharts.charts的Page类表示顺序显示的组合图表，它可以在同一网页中按顺序渲染多个图表。Page 类的构造方法的语法格式如下所示：
语法

Page(page_title="Awesome-pyecharts", js_host= "",
interval=1, layout=PageLayoutOpts())
page_title：表示HTML网页的标题。
js_host：表示远程的主机地址，默认为"https://assets.pyecharts.org/assets/"。
interval：表示每个图例之间的间隔，默认为1。
layout：表示布局配置项。

<!-- Slide number: 46 -->
9.4.2 顺序多图

Grid类提供了一个add()方法，使用add()方法可以为组合图表添加多个图表实例。
语法

add(*charts)
charts: 任意图表实例

<!-- Slide number: 47 -->
9.4.3 选项卡多图

pyecharts.charts的Tab类表示以选项卡形式显示的组合图表，它可以点击不同的选项卡来切换显示多个图表。Tab类的构造方法的语法格式如下所示：
语法

Tab(page_title="Awesome-pyecharts", js_host="")
以上方法的参数与Page()方法的参数相同，此处不再赘述。

<!-- Slide number: 48 -->
9.4.3 选项卡多图

Tab类提供了一个add()方法，使用add()方法可以为组合图表添加图表。add()方法的语法格式如下所示：
语法

add(self, chart, tab_name)
以上方法的参数chart表示任意图表，tab_name表示选项卡标签的名称。

<!-- Slide number: 49 -->
9.4.4 时间线轮播多图

pyecharts.charts的Timeline类表示时间线轮播的组合图表，它可以通过点击时间线的时间节点来切换显示多个图表。Timeline类中提供两个重要的方法add_schema()和add() 。

![](Picture6.jpg)

<!-- Slide number: 50 -->
9.4.4 时间线轮播多图

add_schema()方法
add_schema()方法用于为图表添加指定样式的时间线。
语法

add_schema(self, axis_type="category", orient="horizontal", symbol=None, symbol_size=None, …, itemstyle_opts=None)
axis_type：表示坐标轴的类型，可以取值为'value'（数值轴）、'category'（类目轴）、'time'（时间轴）、'log'（对数轴）。
orient：表示时间线的类型，可以取值为'horizontal'（水平）和'vertical'（垂直）。
play_interval：表示播放的速度，单位为ms。

<!-- Slide number: 51 -->
9.4.4 时间线轮播多图

add_schema()方法
add_schema()方法用于为图表添加指定样式的时间线。
语法

add_schema(self, axis_type="category", orient="horizontal", symbol=None, symbol_size=None, …, itemstyle_opts=None)
is_auto_play：表示是否自动播放，默认为False。
is_loop_play：表示是否循环播放，默认为True。
is_rewind_play：表示是否反向播放，默认为False。
is_timeline_show：表示是否显示时间线组件。
width：表示时间线区域的宽度。
height：表示时间线区域的高度。

<!-- Slide number: 52 -->
9.4.4 时间线轮播多图

add ()方法
add ()方法用于添加图表和时间点。
语法

add(self, chart, time_point)
chart：表示图表。
time_point：表示时间点。

<!-- Slide number: 53 -->
多学一招：pyecharts.faker包

pyecharts.faker是一个pyecharts官方提供的测试数据包，它包含一个_Faker类的对象Faker，通过Faker对象访问属性来获取一些测试数据。

![](图片3.jpg)
Faker对象的常用属性及其对应的测试数据

<!-- Slide number: 54 -->
多学一招：pyecharts.faker包

![https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1588673906452&di=785a35df03b10722f4c510225358a567&imgtype=0&src=http%3A%2F%2Fimg1.juimg.com%2F160107%2F330826-16010GZ00148.jpg](Picture2.jpg)
除此之外，Faker对象还包含两个比较常用的方法：choose()和values()，其中choose()是一个实例方法，用于从前面表格的前7组测试数据中随机获取一组测试数据；values()是一个静态方法，用于生成一个包含7个随机整数n（20<=n<=150）的列表。

<!-- Slide number: 55 -->
目录页

![](图片18.jpg)
9.1    pyecharts概述
9.2   pyecharts基础知识
9.3    绘制常用图表
9.4    绘制组合图表

9.5   定制图表主题

<!-- Slide number: 56 -->
9.5 定制图表主题
pyecharts 内置了十多种不同风格的图表主题，包括LIGHT、DARK、CHALK等，并将这些图表主题封装为全局变量ThemeType引用类的属性中。

![](图片1.jpg)
ThemeType引用类的属性及说明

<!-- Slide number: 57 -->
9.5 定制图表主题
前表中列举的属性可以传入InitOpts()方法的theme参数，之后在初始化图表类时将InitOpts类对象传给init_opts参数，如此便修改了图表默认的主题风格。

bar = (
    # 创建Bar类对象，将图表主题替换为ThemeType.ROMA
    Bar(init_opts=opts.InitOpts(theme=ThemeType.ROMA))
    .add_xaxis(x_data)
    .add_yaxis("商家A", y_a)
    .add_yaxis("商家B", y_b)
    .set_global_opts(title_opts=opts.TitleOpts(title="柱形图"))
)
示例

<!-- Slide number: 58 -->
目录页

![](图片18.jpg)

9.6   整合Web框架
9.7   实例：虎扑社区分析
9.8   本章小结

<!-- Slide number: 59 -->
9.6 整合Web框架
pyecharts可以轻松地整合Web框架，包括主流的 Django 和 Flask框架等，实现在Web项目中绘制图表的功能。不同的框架和使用场景需要有不同的整合方法。

![C:\Users\admin\Desktop\02.jpg](Picture2.jpg)

<!-- Slide number: 60 -->
9.6 整合Web框架
新建Django项目
打开命令行工具，在命令提示符的后面输入如下命令：

django-admin startproject pyecharts_django_demo
以上命令执行后会在根目录中创建一个名称为pyecharts_django_
demo的Django项目。

<!-- Slide number: 61 -->
9.6 整合Web框架
新建Django项目
创建完项目之后，继续在命令行中输入如下命令创建一个应用程序：

python manage.py startapp demo

<!-- Slide number: 62 -->
9.6 整合Web框架
新建Django项目
打开pyecharts_django_demo/settings.py文件，在该文件中注册应用程序demo，注册完的代码如下所示：

# pyecharts_django_demo/settings.py
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'demo'  # 注册的应用程序]

<!-- Slide number: 63 -->
9.6 整合Web框架
新建Django项目
由于创建的demo应用中欧不包含urls.py文件，需要手动创建urls.py文件。编辑demo/urls.py文件，代码如下：

from django.conf.urls import url
from . import views
urlpatterns = [
    url(r'^$', views.index, name='index'),
]

<!-- Slide number: 64 -->
9.6 整合Web框架
新建Django项目
在pyecharts_django_demo/urls.py文件中增加'demo.urls'，代码如下：

pyecharts_django_demo/urls.py
from django.conf.urls import include, url
from django.contrib import admin
urlpatterns = [
    url(r'^admin/', admin.site.urls),
    url(r'demo/', include('demo.urls'))
]

<!-- Slide number: 65 -->
9.6 整合Web框架
2. 复制pyecharts模板
在demo目录下新建templates 文件夹，此时demo的目录如下所示：
示例

__init__.py  __pycache__  admin.py  apps.py  migrations  models.py
templates  tests.py  urls.py  views.py
将位于pyecharts.render.templates目录下的pyecharts 模板中的macro和simple_chart.html文件复制到新建的templates 文件夹中。

<!-- Slide number: 66 -->
9.6 整合Web框架
3. 渲染图表
打开demo/views.py文件，在该文件中增加绘制图表的代码：
示例

def index(request):
    c = (
        Bar()
        .add_xaxis(["衬衫", "羊毛衫", "雪纺衫", "裤子", "高跟鞋", "袜子"])
        .add_yaxis("商家A", [5, 20, 36, 10, 75, 90])
        .add_yaxis("商家B", [15, 25, 16, 55, 48, 8])
        .set_global_opts(title_opts=opts.TitleOpts(title=“柱形图示例", subtitle="我是副标题"),
        yaxis_opts=opts.AxisOpts(name="销售额(万元)", name_location="center",name_gap=30))
    )
    return HttpResponse(c.render_embed())

<!-- Slide number: 67 -->
9.6 整合Web框架
4. 运行项目
在命令行中输入如下运行程序的命令：
命令

python manage.py runserver

<!-- Slide number: 68 -->
9.6 整合Web框架
4. 运行项目
在浏览器中打开http://127.0.0.1:8000/demo 即可访问服务，此时的页面如下图所示。

![](图片2.jpg)

<!-- Slide number: 69 -->
目录页

![](图片18.jpg)
9.6   整合Web框架

9.7   实例：虎扑社区分析
9.8   本章小结

<!-- Slide number: 70 -->
9.7 实例：虎扑社区分析
虎扑是一个有趣的社区，每天有众多JRs（虎扑网友间的称呼，译为家人们）在虎扑社区上分享自己对篮球、足球、游戏电竞、运动装备、影视、汽车、数码、情感等人和事的见解。某网站对虎扑社区的用户及其行为进行了数据采集，将虎扑近3个月的1000多个贴子作为抽样数据，下面对虎扑各板块发帖数、社区和NBA板块的24小时发帖量、朔州市用户地域分布进行画图分析。

![](图片1.jpg)

<!-- Slide number: 71 -->
9.7 实例：虎扑社区分析

![](图片1.jpg)
1. 虎扑各板块发帖数
虎扑社区主要包含NBA、CBA、足球、步行街、电竞等多个板块，其中统计的各板块的用户发帖量如右表所示。

<!-- Slide number: 72 -->
9.7 实例：虎扑社区分析

![](图片1.jpg)
1. 虎扑各板块发帖数
根据前面表格的数据，使用pyecharts的Pie类创建一个圆环图，使用圆环图来展示各板块的发帖数。

<!-- Slide number: 73 -->
9.7 实例：虎扑社区分析
2. 虎扑社区和NBA板块的24小时发帖量
虎扑社区中NBA板块的发帖数量一直都居高不下， NBA成为大多数用户谈论的话题。某网站某天每隔2小时统计了虎扑社区及NBA板块的发帖量，整理后如右表所示。

![](图片3.jpg)

<!-- Slide number: 74 -->
9.7 实例：虎扑社区分析
2. 虎扑社区和NBA板块的24小时发帖量
根据前面表格的数据，使用pyecharts的Line类创建一个折线图，通过折线图来反映虎扑社区和NBA板块24小时的发帖量 。

![](图片1.jpg)

<!-- Slide number: 75 -->
9.7 实例：虎扑社区分析
3. 虎扑社区朔州市用户地域分布
虎扑社区的用户群体日益壮大，且遍布全国各地。某网站对社区内朔州市各地区用户量进行粗略统计，统计结果（模拟数据）如右表所示。

![](图片1.jpg)

![](图片2.jpg)

<!-- Slide number: 76 -->
9.7 实例：虎扑社区分析
3. 虎扑社区朔州市用户地域分布

![](图片1.jpg)
根据前面表格的数据，使用pyecharts的Map类创建一个统计地图，通过统计地图来反映虎扑社区用户在朔州市各地区的分布情况。

<!-- Slide number: 77 -->
9.7 实例：虎扑社区分析
下面使用pyecharts的Page类创建一个组合图表，将前面创建的圆环图、折线图、统计地图按顺序依次展示到同一网页中。

page = Page()
page.add(pie_hupu, line_hupu, map_hupu)
page.render_notebook()
示例

<!-- Slide number: 78 -->
目录页

![](图片18.jpg)
9.6   整合Web框架
9.7   实例：虎扑社区分析

9.8   本章小结

<!-- Slide number: 79 -->
9.8 本章小结

![](Picture2.jpg)
本章主要介绍了后来兴起的优秀的数据可视化工具pyecharts，包括pyecharts概述、pyecharts基础知识、绘制常用的图表、绘制组合图表、定制图表主题、整合Web框架，并围绕着这些知识点开发了一个实例——虎扑社区分析。通过学习本章的内容，希望读者可以体会pyecharts的神奇之处，学会使用pyecharts绘制简单的Echarts图表。

<!-- Slide number: 80 -->