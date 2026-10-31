<!-- Slide number: 1 -->
# 第8章 使用matplotlib绘制高级图表
· 绘制漏斗图
· 绘制桑基图
· 绘制树状图
· 绘制华夫饼图
· 绘制等高线图
· 绘制矢量场流线图
· 绘制棉棒图
· 绘制哑铃图
· 绘制甘特图
· 绘制人口金字塔图

![](图片1.jpg)

### Notes:

<!-- Slide number: 2 -->
 学习目标
了解 常见高级图表的特点
1

掌握 高级图表的绘制方法
2

了解

掌握

### Notes:

<!-- Slide number: 3 -->
目录页

![](图片18.jpg)
8.1    绘制等高线图
8.2   绘制矢量场流线图
8.3    绘制棉棒图
8.4    绘制哑铃图
8.5    绘制甘特图
8.6    绘制人口金字塔图

<!-- Slide number: 4 -->
目录页

![](图片18.jpg)
8.7    绘制漏斗图
8.8   绘制桑基图
8.9    绘制树状图
8.10    绘制华夫饼图
8.11    本章小结

<!-- Slide number: 5 -->
目录页

![](图片18.jpg)

8.1    绘制等高线图
8.2   绘制矢量场流线图
8.3    绘制棉棒图
8.4    绘制哑铃图
8.5    绘制甘特图
8.6    绘制人口金字塔图

<!-- Slide number: 6 -->
8.1 绘制等高线图

![coutour](图片5.jpg)
等高线图是地形图上高程相等的相邻各点所连成的闭合曲线，它会将地面上海拔高度相同的点连成环线，之后将环线垂直投影到某一水平面上，并按照一定的比例缩绘到图纸上，常见于山谷、山峰或梯度下降算法的场景。

<!-- Slide number: 7 -->
8.1 绘制等高线图
等高线图包含三个主要的信息，分别为坐标点的x值、坐标点y值以及坐标点的高度。假设坐标点的高度为h，则h、x、y之间的关系如下所示：

<!-- Slide number: 8 -->
8.1 绘制等高线图
在matplotlib中，使用pyplot模块的contour()、contourf()函数可以绘制和填充等高线图。contour()函数的语法格式如下所示：
语法

contour([X, Y,]Z, [levels,]**kwargs)
X，Y：表示坐标点的网格数据。
Z：表示坐标点对应的高度数据。
levels：表示等高线的数量。若levels为n，则说明绘制n+1条等高线。
colors：表示不同高度的等高线颜色。
cmap：表示颜色映射表。
linewidths：表示等高线的宽度。
linestyles：表示等高线的线型。

<!-- Slide number: 9 -->
8.1 绘制等高线图

![](图片1.jpg)

需要注意的是，参数X、Y需要接收网格数据，即以坐标矩阵批量地描述点的位置。numpy模块的meshgrid()函数可以生成网格数据。除此之外，contourf()与contour()函数的参数相似，此处不再赘述。

<!-- Slide number: 10 -->
8.1 绘制等高线图

fig = plt.figure()
ax = fig.add_subplot(111)
# 绘制等高线
con = ax.contour(x_grid, y_grid, calcu_elevation(x_grid, y_grid), 8, colors='black')
# 填充等高线的颜色
ax.contourf(x_grid, y_grid, calcu_elevation(x_grid, y_grid), 8, alpha=0.75, cmap=plt.cm.copper)
# 为等高线添加文字标签
ax.clabel(con, inline=True, fmt='%1.1f', fontsize=10)
示例

![](Picture2.jpg)

<!-- Slide number: 11 -->
目录页

![](图片18.jpg)
8.1    绘制等高线图

8.2   绘制矢量场流线图
8.3    绘制棉棒图
8.4    绘制哑铃图
8.5    绘制甘特图
8.6    绘制人口金字塔图

<!-- Slide number: 12 -->
8.2 绘制矢量场流线图

![C:\Users\admin\Desktop\1213.png](图片5.jpg)
矢量场流线图可以表现矢量场的流态，常见于科学和自然学科中的磁场、万有引力和流体运动等场景。
矢量场流线图包含多条带有箭头的线条，其中线条的长度表示矢量场的强度，箭头的方向表示矢量场的方向。此外，矢量场的强度也可以使用线条的密度来表示。

<!-- Slide number: 13 -->
8.2 绘制矢量场流线图
使用pyplot模块的streamplot()函数可以绘制矢量场流线图。

语法
streamplot(x, y, u, v, density=1, linewidth=None, col=None, cmap=None, norm=None,
arrowsize=1, arrowstyle='-|>', minlength=0.1, transform=None, zorder=None,
start_points=None, maxlength=4.0, integration_direction='both', *, data=None)
x，y：表示间距均匀的网格数据。
u，v：表示(x,y)速率的二维数组。
density：表示流线的密度。
linewidth：表示流线的宽度。
arrowsize：表示箭头的大小。
arrowstyle：表示箭头的类型。
minlength：表示流线的最小长度。
maxlength：表示流线的最大长度。

<!-- Slide number: 14 -->
8.2 绘制矢量场流线图

import numpy as np
import matplotlib.pyplot as plt
y, x = np.mgrid[0:5:50j, 0:5:50j]
u = x
v = y
fig = plt.figure()
ax = fig.add_subplot(111)
# 绘制矢量场流线图
ax.streamplot(x, y, u, v)
plt.show()
示例

![](Picture2.jpg)

<!-- Slide number: 15 -->
目录页

![](图片18.jpg)
8.1    绘制等高线图
8.2   绘制矢量场流线图

8.3    绘制棉棒图
8.4    绘制哑铃图
8.5    绘制甘特图
8.6    绘制人口金字塔图

<!-- Slide number: 16 -->
8.3 绘制棉棒图
棉棒图亦称为火柴杆图、大头针图或棒棒糖图，由线段（茎）与标记符号（茎头，默认为圆点）连接而成，其中线段表示数据点到基线的距离，标记符号表示数据点的数值。棉棒图是柱形图或条形图的变形，主要用于比较标记符号的相对位置，而非比较线段的长度。

![](图片7.jpg)

<!-- Slide number: 17 -->
8.3 绘制棉棒图
使用pyplot模块的stem()函数可以绘制棉棒图。
语法

stem([x,] y, linefmt=None, markerfmt=None, basefmt=None, bottom=0,
label=None, use_line_collection=False, data=None)
x，y：表示茎的x值和茎头的y值。
linefmt：表示茎属性的字符串。
markerfmt：表示茎头属性的字符串。
basefmt：表示基线属性的字符串。
bottom：表示基线的y值。
label：表示应用于图例的标签。
use_line_collection：若设为True，则将棉棒图的所有线段存储到一个LineCollection类对象中；若设为False，则将棉棒图的所有线段存储到列表中。

<!-- Slide number: 18 -->
8.3 绘制棉棒图
stem()函数会返回一个形如(markerline, stemlines, baseline) 的元组，其中元组的第1个元素markerline为代表棉棒图标记的Line2D对象，第2个元素stemlines为代表棉棒图线段的Line2D对象，第3个元素baseline为代表基线的Line2D对象。

![](图片2.jpg)

<!-- Slide number: 19 -->
8.3 绘制棉棒图
下面根据表格中的数据，将轿车品牌列的数据作为x轴的标签，将燃料消耗量列的数据作为y轴的数据，使用stem()绘制不同品牌轿车燃料消耗量的棉棒图。

![](图片1.jpg)

![](Picture2.jpg)

<!-- Slide number: 20 -->
8.3 绘制棉棒图

![](Picture2.jpg)
茎头是圆形

由图可知，赛欧轿车的燃料消耗量最大，约为7.9L/km。
茎是虚线

<!-- Slide number: 21 -->
目录页

![](图片18.jpg)
8.1    绘制等高线图
8.2   绘制矢量场流线图
8.3    绘制棉棒图

8.4    绘制哑铃图
8.5    绘制甘特图
8.6    绘制人口金字塔图

<!-- Slide number: 22 -->
8.4 绘制哑铃图

![](图片1.jpg)
哑铃图亦称为DNA图（图表横着看像哑铃，竖着看像DNA），主要用于展示两个数据点之间的变化。哑铃图可以看作散点图与线型图的组合，适用于比较各种项目“前”与“后”的位置及项目的等级排序的场景。

<!-- Slide number: 23 -->
8.4 绘制哑铃图
下面根据health.xlsx文件的数据，将city列的数据作为y轴的刻度标签，将pct_2014和pct_2013两列的数据作为数据点，再在两个数据点之间添加线条，绘制由数据点和线条组成的哑铃图 。

![](Picture2.jpg)

![](图片8.jpg)

<!-- Slide number: 24 -->
8.4 绘制哑铃图

![](Picture2.jpg)

2013年PCT指标的变化率
由图可知，洛杉矶市人口PCT指标的变化率最大，圣路易斯市人口PCT指标的变化率最小。
2014年PCT指标的变化率

<!-- Slide number: 25 -->
目录页

![](图片18.jpg)
8.1    绘制等高线图
8.2   绘制矢量场流线图
8.3    绘制棉棒图
8.4    绘制哑铃图

8.5    绘制甘特图
8.6    绘制人口金字塔图

<!-- Slide number: 26 -->
8.5 绘制甘特图
甘特图亦称为横道图、条状图，它通过活动列表和时间刻度表示特定项目的顺序与持续时间。甘特图一般以时间为横轴，项目为纵轴，可以直观地展示每个项目的进展情况，便于管理者了解项目的剩余任务及评估工作进度。

![](图片1.jpg)

<!-- Slide number: 27 -->
8.5 绘制甘特图
甘特图类似于条形图，这两种图表的图形都是横向矩形条，但甘特图中每个矩形条的起始位置是不同的。
使用pyplot的barh()函数可以绘制一个甘特图，只需要给该函数的left参数传值，指定每个矩形条的x坐标即可。

![](图片8.jpg)

<!-- Slide number: 28 -->
8.5 绘制甘特图
已知某公司预计开辟一个新项目，为确保项目的可行性，将该项目分解成“项目确定”“问卷设计”“试访”“问卷确定”“实地执行”“数据录入”“数据分析”和“报告提交” 8个子任务，并指定了各子任务的周期。

![](图片1.jpg)

<!-- Slide number: 29 -->
8.5 绘制甘特图
已知每个子任务的开发周期依次为：0.5, 1.5, 1, 3, 0.5, 1, 1,2，下面根据这些数据，使用barh()函数绘制一个甘特图，通过该图表展示整个项目的开发周期。

ticks = np.array(['报告提交', '数据分析', '数据录入', '实地执行', '问卷确定', '试访', '问卷设计', '项目确定'])
y_data = np.arange(1, 9)
x_data = np.array([0.5, 1.5, 1, 3, 0.5, 1, 1,2])
fig,ax = plt.subplots(1, 1)
ax.barh(y_data, x_data, tick_label=ticks,
left=[7.5, 6, 5.5, 3, 3, 2, 1.5, 0], color='#CD5C5C')
[ax.spines[i].set_visible(False) for i in ['top', 'right']]
示例

![](Picture2.jpg)

<!-- Slide number: 30 -->
8.5 绘制甘特图

![C:\Users\admin\Desktop\gantt.png](图片8.jpg)

每个红色的条形代表任务的周期，条形越长代表周期越长。由图可知，“实地执行”任务的周期最长，共计3天。

<!-- Slide number: 31 -->
目录页

![](图片18.jpg)
8.1    绘制等高线图
8.2   绘制矢量场流线图
8.3    绘制棉棒图
8.4    绘制哑铃图
8.5    绘制甘特图

8.6    绘制人口金字塔图

<!-- Slide number: 32 -->
8.6 绘制人口金字塔
人口金字塔图是指用类似古埃及金字塔的形象描述人口年龄与性别分布状况的图形，用于表现人口的现状及其发展类型。人口金字塔图一般以年龄为纵轴、以人口数为横轴，按年龄自然顺序自下而上在纵轴左侧和右侧绘制并列的横向矩形条，纵轴左侧为男，右侧为女。

![](图片1.jpg)

<!-- Slide number: 33 -->
8.6 绘制人口金字塔
人口金字塔图中左侧的一组矩形条代表各年龄段男性的人口数，右侧的一组矩形条代表各年龄段女性的人口数。使用pyplot模块的barh()函数可以绘制一个人口金字塔图。

![](图片1.jpg)

<!-- Slide number: 34 -->
8.6 绘制人口金字塔

![](图片7.jpg)
2018年中国国家统计局对某城市的人口进行抽样调查，并将调查后的结果整理到population.xlsx文件中，具体如右表所示。

![](Picture2.jpg)

<!-- Slide number: 35 -->
8.6 绘制人口金字塔
下面使用pandas读取population.xlsx文件的数据，并根据读取的数据绘制一个下图所示的人口金字塔图。

![](Picture2.jpg)
左侧的矩形条代表不同年龄段的男性人口数量，右侧的矩形条代表不同年龄段的女性人口数量。由图可知，各年龄段男性人口的数量与女性人口的数量相差不大，且位于40～49岁年龄段的人口数量最多。

<!-- Slide number: 36 -->
目录页

![](图片18.jpg)
8.7    绘制漏斗图
8.8   绘制桑基图
8.9    绘制树状图
8.10    绘制华夫饼图
8.11    本章小结

<!-- Slide number: 37 -->
8.7 绘制漏斗图
漏斗图亦称为倒三角图，它将数据呈现为几个阶段，每个阶段的占比总计为100%，从一个阶段到另一阶段的数据自上而下逐渐降低。漏斗图通过展示业务各阶段数据的变化，可以帮助运营人员快速发现问题，适用于业务流程较为规范、周期长、环节多的流程分析的场景。

![http://img.mp.itc.cn/upload/20160902/896602cfedb6471a8b307473511d4de6_th.jpg](图片6.jpg)

<!-- Slide number: 38 -->
8.7 绘制漏斗图
下面根据的表格中的数据，绘制一个由矩形条和线段组成的简易版的漏斗图 。

![](Picture2.jpg)

![](图片1.jpg)

<!-- Slide number: 39 -->
8.7 绘制漏斗图

![C:\Users\admin\Desktop\funnel_rate.png](图片11.jpg)

漏斗图中条形长短代表着客户转化率的多少。由图可知，完成交易的客户转化率为15%。

<!-- Slide number: 40 -->
目录页

![](图片18.jpg)
8.7    绘制漏斗图

8.8   绘制桑基图
8.9    绘制树状图
8.10    绘制华夫饼图
8.11    本章小结

<!-- Slide number: 41 -->
8.8 绘制桑基图
桑基图亦称为桑基能量分流图、桑基能量平衡图，是一种特定类型的流程图，用于展示数据的“流动”变化。桑基图中包含若干条从左到右延展的分支，每条分支的宽度代表着数据流量的大小，且所有主支宽度的总和等于所有分支宽度的总和，常见于能源、材料成分等场景或金融领域。

![](图片5.jpg)

<!-- Slide number: 42 -->
8.8 绘制桑基图
matplotlib.sankey模块中专门提供了表示桑基图的类Sankey，通过创建Sankey类的对象可以创建桑基图，之后可以调用add()方法为桑基图添加一些配置选项，最后调用finish()方法完成桑基图的绘制。

![](图片5.jpg)

<!-- Slide number: 43 -->
8.8 绘制桑基图
创建桑基图
matplotlib中使用Sankey类的构造方法Sankey()创建桑基图。
语法

Sankey(ax=None, scale=1.0, unit='', format='%G', gap=0.25, radius=0.1,
shoulder=0.03, offset=0.15, head_angle=100, margin=0.4,
tolerance=1e-06, **kwargs)
ax：若不提供该参数，会创建一个新的坐标轴。
scale：表示流量比例因子比例调整分支的宽度。
unit：表示与流量相关的物理单位的字符串。若设为None，则不会做数量标记。
gap：表示进入或离开顶部或底部的分支之间的间距，默认为0.25。

<!-- Slide number: 44 -->
8.8 绘制桑基图
添加桑基图的选项
Sankey类对象可以调用add()方法为桑基图添加诸如数据流量、标签等选项。
语法

add(self, patchlabel='', flows=None, orientations=None, labels='',
trunklength=1.0, pathlengths=0.25, prior=None, connect=(0, 0), rotation=0, **kwargs)
patchlabel：表示位于图表中心的标签。
flows：表示流量数据的数组，其中投入数据为正值，产生数据为负值。
orientations：表示流的方向列表或用于所有流的单个方向，可以取值为0（从左侧输入、右侧输出）、1（从顶部到顶部）或-1（从底部到底部）。
labels：表示流的标签列表或用于所有流的单个标签。
trunklength：表示输入组和输出组的基之间的长度。

<!-- Slide number: 45 -->
8.8 绘制桑基图
返回桑基图绘制完成的对象
Sankey类对象在添加完数据之后需要调用finish()方法完成绘制，并返回包含多个桑基子图的列表。桑基子图包含以下字段：
patch：表示桑基子图的轮廓。
flows：表示流量值（输入为正，输出为负）。
angles：表示箭头角度的列表。
tips：表示流路径的尖端或凹陷位置的数组，其中每一行是一个(x, y)。
text：表示中心标签的Text实例。
texts：表示流分支标签的Text实例。

<!-- Slide number: 46 -->
8.8 绘制桑基图
假设现在小明家日常生活的开支主要分为旅行、聚餐、生活、购物、深造、运动、买书和其它几类，且其中每项投入或产出值分别为0.2、0.1、0.4、0.3、-0.6、-0.05、-0.15、-0.2。下面结合这些日常生活开支的数据绘制一个桑基图。
示例

# 创建Sankey类对象
sankey = Sankey()
# 为桑基图添加数据
sankey.add(flows=flows,    labels=labels, orientations=orientations, color="black",
fc="lightgreen", patchlabel="生活消费",  alpha=0.7)
# 桑基图绘制完成的对象
diagrams = sankey.finish()

![](Picture2.jpg)

<!-- Slide number: 47 -->
8.8 绘制桑基图

![C:\Users\admin\Desktop\sankey.png](图片12.jpg)

桑基图的各个分支代表生活消费的每个选项，其中分支末端呈内凹形状的分支代表收入的数据，呈箭头形状的分支代表支出的数据。由图可知，工资和副业这两项代表的分支均属于生活消费的收入数据，其余选项的分支均属于生活消费的支出数据，且深造选项的支出最多。

<!-- Slide number: 48 -->
目录页

![](图片18.jpg)
8.7    绘制漏斗图
8.8   绘制桑基图

8.9    绘制树状图
8.10    绘制华夫饼图
8.11    本章小结

<!-- Slide number: 49 -->
8.9 绘制树状图
树状图亦称为树枝状图，是一种通过树状结构描述父子成员层次结构的图形。树形图的形状一般是一个上下颠倒的树，其根部是一个没有父成员的根节点，之后从根节点开始是用线连接子成员，使子成员变为子节点，直至线的末端为没有子成员的树叶节点为止。树状图用于说明成员之间的关系和连接，常见于分类学、进化科学、企业组织管理等领域。

![](图片5.jpg)

<!-- Slide number: 50 -->
8.9 绘制树状图

![](图片2.jpg)
树状图的绘制需要准备聚类数据。若单独使用matplotlib较为繁琐，因此这里可以结合scipy包的功能完成。scipy是一款基于numpy的、专为科学和工程设计的、易于使用的Python包，它提供了线性代数、傅里叶变换、信号处理等丰富的功能。

<!-- Slide number: 51 -->
8.9 绘制树状图

![](图片2.jpg)
scipy.cluster模块中包含众多聚类算法，主要包括矢量量化和层次聚类两种，并分别封装到vq或hierarchy模块中。hierarchy模快中提供了一系列聚类的功能，可以轻松地生成聚类数据并绘制树状图。

<!-- Slide number: 52 -->
8.9 绘制树状图
dendrogram()函数
dendrogram()函数用于将层次聚类数据绘制为树状图。
语法

dendrogram(Z, p=30, truncate_mode=None, color_threshold=None, get_leaves=True, orientation='top', labels=None, count_sort=False, distance_sort=False, show_leaf_counts=True, **kwargs)
Z：表示编码层次聚类的链接矩阵。
truncate_mode：表示截断的模式，用于压缩因观测矩阵过大而难以阅读的树状图，可以取值为None（不执行截断，默认）、'lastp'、'level'。
color_threshold：表示颜色阈值。
labels：表示节点对应的文本标签。

<!-- Slide number: 53 -->
8.9 绘制树状图
linkage()函数
linkage()函数用于将一维压缩距离矩阵或二维观测向量阵列进行层次聚类或凝聚聚类。

linkage(y, method='single', metric='euclidean', optimal_ordering=False)
语法
y：可以是一维距离向量或二维的坐标矩阵。
method：表示计算类簇之间距离的方法，常用的取值可以为'single'、 'complete'、 'average'和'ward‘，其中'single'表示将类簇与类簇之间最近的距离作为类簇间距； 'complete' 表示将类簇与类簇之间最远的距离作为类簇间距；'average'表示将类簇与类簇之间的平均距离作为类簇间距；'ward‘表示将每个类簇的方差最小化作为类簇间距。

<!-- Slide number: 54 -->
8.9 绘制树状图
美国对各个州的谋杀、暴力、爆炸犯罪案件的数量进行了统计，并将统计后的结果整理到USArrests.xlsx文件中。下面使用pandas读取USArrests.xlsx文件的数据，并将犯罪案例数量相似度高的州进行聚类后绘制一个树状图。

![](图片2.jpg)

![图表, 直方图 描述已自动生成](图片14.jpg)

<!-- Slide number: 55 -->
目录页

![](图片18.jpg)
8.7    绘制漏斗图
8.8   绘制桑基图
8.9    绘制树状图

8.10    绘制华夫饼图
8.11    本章小结

<!-- Slide number: 56 -->
8.10 绘制华夫饼图
华夫饼图亦称为直角饼图，它是饼图的变体，可以直观地展示部分与整体的比例。华夫饼图一般由100个方格组成，其中每个方格代表1%，不同颜色的方格代表不同的分类，常见于比较同类型指标完成比例的场景，比如电影上座率、公司业务实际完成率等。

![](图片5.jpg)

<!-- Slide number: 57 -->
8.10 绘制华夫饼图
matplotlib中并未提供华夫饼图的绘制函数，但可以结合pywaffle包一起使用来绘制华夫饼图。

![](图片6.jpg)

<!-- Slide number: 58 -->
8.10 绘制华夫饼图
pywaffle的安装
开发者可以直接使用pip命令安装pywaffle包。打开命令提示符工具，在提示符的后面输入如下命令：

pip install pywaffle
以上命令执行后，若命令提示符窗口出现如下字样，说明pywaffle包安装完成：
Installing collected packages: pywaffle
Successfully installed pywaffle-0.4.1

<!-- Slide number: 59 -->
8.10 绘制华夫饼图
pywaffle的安装
安装完成后，在提示符的后面输入python，之后输入如下导入语句进行验证：

from pywaffle import Waffle
执行以上语句后，若命令提示符窗口没有出现任何错误信息，说明pywaffle安装成功，否则说明安装失败。

<!-- Slide number: 60 -->
8.10 绘制华夫饼图
pywaffle的使用
pywaffle是Python中专门绘制华夫饼图的包，它提供了一个继承自Figure的子类Waffle，通过将Waffle类传递给figure()函数的FigureClass参数，即可创建一个华夫饼图。关于figure()函数中创建华夫饼图的常用参数的含义如下：
FigureClass：可以是Figure类或Figure子类。
rows：表示华夫饼图的行数。
columns：表示华夫饼图的列数。
values：表示数据，可以接收数组或字典。若values参数接收一个字典，则将字典的键作为华夫饼图的图例项。

<!-- Slide number: 61 -->
8.10 绘制华夫饼图
pywaffle的使用
pywaffle是Python中专门绘制华夫饼图的包，它提供了一个继承自Figure的子类Waffle，通过将Waffle类传递给figure()函数的FigureClass参数，即可创建一个华夫饼图。关于figure()函数中创建华夫饼图的常用参数的含义如下：
colors：表示每个分类数据的颜色列表。
vertical：表示是否按垂直方向绘制华夫饼图，默认为False。
title：表示标题，可以接收一个字典，其中字典的键为title()函数的关键字参数。
legend：表示图例，可以接收一个字典，其中字典的键为legend()函数的关键字参数。

<!-- Slide number: 62 -->
8.10 绘制华夫饼图
假设某影院于周六上映了电影《少年的你》，并统计了1号观影厅的上座率为95%。下面结合matplotlib和pywaffle绘制一个说明1号厅上座率的华夫饼图。
示例

# 创建Sankey类对象
sankey = Sankey()
# 为桑基图添加数据
sankey.add(flows=flows, labels=labels, orientations=orientations, color="black", fc="lightgreen", patchlabel="生活消费",  alpha=0.7)
# 桑基图绘制完成的对象
diagrams = sankey.finish()

![C:\Users\admin\Desktop\pywaffle.png](图片10.jpg)

<!-- Slide number: 63 -->
8.10 绘制华夫饼图

![C:\Users\admin\Desktop\pywaffle.png](图片12.jpg)
颜色为#D3D3D3
颜色为#20B2AA

<!-- Slide number: 64 -->
目录页

![](图片18.jpg)
8.7    绘制漏斗图
8.8   绘制桑基图
8.9    绘制树状图
8.10    绘制华夫饼图

8.11    本章小结

<!-- Slide number: 65 -->
8.11 本章小结

![](Picture2.jpg)
本章主要介绍了如何使用matplotlib绘制一些高级图表，包括等高线图、矢量场流线图、棉棒图、哑铃图、甘特图、人口金字塔图、漏斗图、桑基图、树状图、华夫饼图。通过学习本章的内容，希望大家可以了解常用的高级图表的特点，并可以绘制高级图表。

<!-- Slide number: 66 -->