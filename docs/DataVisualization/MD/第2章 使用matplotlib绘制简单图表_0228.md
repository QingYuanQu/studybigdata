<!-- Slide number: 1 -->
第2章 使用matplotlib绘制简单图表
· 绘制折线图
· 绘制柱形图或堆积柱形图
· 绘制条形图或堆积条形图
· 绘制直方图
· 绘制饼图或圆环图
· 绘制散点图或气泡图

![](图片1.jpg)

### Notes:

<!-- Slide number: 2 -->
 学习目标
掌握 绘制折线图，绘制柱形图或堆积柱形图
1

掌握 绘制条形图或堆积条形图，绘制堆积面积图、直方图
2

掌握
掌握
掌握

掌握
掌握 绘制箱形图，绘制雷达图，绘制误差棒图
4

掌握 绘制饼图或圆环图，绘制散点图或气泡图
3

### Notes:

<!-- Slide number: 3 -->
目录页
2.1    绘制折线图

![](图片18.jpg)
2.2   绘制柱形图或堆积柱形图
2.3  绘制条形图或堆积条形图
2.4    绘制堆积面积图
2.5    绘制直方图
2. 6   绘制饼图或圆环图

<!-- Slide number: 4 -->
目录页
2.7    绘制散点图或气泡图

![](图片18.jpg)

<!-- Slide number: 5 -->
目录页

2.1    绘制折线图

![](图片18.jpg)
2.2   绘制柱形图或堆积柱形图
2.3  绘制条形图或堆积条形图
2.4    绘制堆积面积图
2.5    绘制直方图
2. 6   绘制饼图或圆环图

<!-- Slide number: 6 -->
2.1.1 使用plot()绘制折线图
使用pyplot的plot()函数可以快速地绘制折线图。
语法

plot（x, y, fmt, label=None, *args, **kwargs）
x：表示x轴的数据，默认值为range(len(y))。
y：表示y轴的数据。
fmt：表示快速设置线条样式的格式字符串。
label：表示应用于图例的标签文本。
plot()函数会返回一个包含Line2D类对象（代表线条）的列表。

### Notes:

<!-- Slide number: 7 -->
2.1.1 使用plot()绘制折线图
使用pyplot的plot()函数还可以绘制具有多个线条的折线图，通过以下任意一种方式均可以完成。

第1种
plt.plot(x1, y1)
plt.plot(x2, y2)

第3种
arr = np.array([[1, 2, 3],
                         [4, 5, 6],
                         [7, 8, 9],
                         [10, 11, 12]])
plt.plot(arr[0], arr[1:])

第2种
plt.plot(x1, y1, x2, y2)

<!-- Slide number: 8 -->
2.1.2 实例1：未来15天最高气温和最低气温
人们每天的生活离不开天气预报，无论是居家还是外出，人们都时刻关注着天气的变化，以便随时备好伞具、增减衣服，或者为后期的出行计划做好准备。

![水中的倒影 中度可信度描述已自动生成](图片3.jpg)

![](Picture4.jpg)

![](Picture2.jpg)

<!-- Slide number: 9 -->
2.1.2 实例1：未来15天最高气温和最低气温
本实例要求根据下表的数据，将日期列的数据作为x轴数据，将最高气温和最低气温两列的数据作为y轴数据，使用plot()函数绘制下图所示的折线图。

![](图片1.jpg)

![](图片4.jpg)

### Notes:
y_max = np.array([32, 33, 34, 34, 33, 31, 30, 29, 30, 29, 26, 23, 21, 25, 31])
y_min = np.array([19, 19, 20, 22, 22, 21, 22, 16, 18, 18, 17, 14, 15, 16, 16])

<!-- Slide number: 10 -->
2.1.2 实例1：未来15天最高气温和最低气温

![](图片9.jpg)
最高气温
温度

由图可知，未来15天的最高气温和最低气温都呈现逐步下降后反弹的趋势。
最低气温
日期

<!-- Slide number: 11 -->
目录页
2.1    绘制折线图

![](图片18.jpg)

2.2   绘制柱形图或堆积柱形图
2.3  绘制条形图或堆积条形图
2.4    绘制堆积面积图
2.5    绘制直方图
2. 6   绘制饼图或圆环图

<!-- Slide number: 12 -->
2.2.1 使用bar()绘制柱形图或堆积柱形图
使用pyplot的bar()函数可以快速地绘制柱形图或堆积柱形图 。
语法

bar(x, height, width=0.8, bottom=None, align=‘center’, tick_label=None, xerr=None, yerr=None, **kwargs)
x:表示柱形的x坐标值。
height:表示柱形的高度。
width:表示柱形的宽度，默认为0.8。
bottom:表示柱形底部的y值，默认为0。
tick_label：表示柱形对应的刻度标签。
xerr，yerr :若未设为None，则需要为柱形图添加水平/垂直误差棒。

<!-- Slide number: 13 -->
2.2.1 使用bar()绘制柱形图或堆积柱形图
bar()函数会返回一个BarContainer类的对象。
BarContainer类的对象是一个包含柱形或误差棒的容器，它亦可以视为一个元组，可以遍历获取每个柱形或误差棒。
BarContainer类的对象也可以访问patches或errorbar属性分别获取图表中所有的柱形或误差棒。

<!-- Slide number: 14 -->
2.2.1 使用bar()绘制柱形图或堆积柱形图
绘制有一组柱形的柱形图

![](Picture2.jpg)
示例

x = np.arange(5)
y1 = np.array([10, 8, 7, 11, 13])
# 柱形的宽度
bar_width = 0.3
# 绘制柱形图
plt.bar(x, y1, tick_label=['a', 'b', 'c', 'd', 'e'], width=bar_width)

<!-- Slide number: 15 -->
2.2.1 使用bar()绘制柱形图或堆积柱形图
绘制有两组柱形的柱形图
示例

x = np.arange(5)
y1 = np.array([10, 8, 7, 11, 13])
y2 = np.array([9, 6, 5, 10, 12])
# 柱形的宽度
bar_width = 0.3
# 根据多组数据绘制柱形图
plt.bar(x, y1, tick_label=['a', 'b', 'c', 'd', 'e'], width=bar_width)
plt.bar(x+bar_width, y2, width=bar_width)
plt.show()
# x不能是list类型，list类型不能加标量

![](Picture2.jpg)

<!-- Slide number: 16 -->
2.2.1 使用bar()绘制柱形图或堆积柱形图
绘制堆积柱形图
在使用bar()函数绘制图表时，可以通过给该函数的bottom参数传值的方式控制柱形的y值，使后绘制的柱形位于先绘制的柱形的上方。

![](图片3.jpg)
示例

# 绘制堆积柱形图
plt.bar(x, y1, tick_label=['a', 'b', 'c', 'd', 'e'], width=bar_width)
plt.bar(x, y2, bottom=y1,width=bar_width)

<!-- Slide number: 17 -->
2.2.1 使用bar()绘制柱形图或堆积柱形图
绘制有误差棒的柱形图
在使用bar()函数绘制图表时，还可以通过给xerr、yerr参数传值的方式为柱形添加误差棒。

![](图片2.jpg)

# 偏差数据
error = [2, 1, 2.5, 2, 1.5]
# 绘制带有误差棒的柱形图
plt.bar(x, y1, tick_label=['a', 'b', 'c', 'd', 'e'], width=bar_width)
plt.bar(x, y1, bottom=y1, width=bar_width, yerr=error)
示例

<!-- Slide number: 18 -->
2.2.2 实例2:2013~2019财年阿里巴巴淘宝和天猫平台的GMV
随着互联网与电子商务的快速发展，人们的消费模式发生了翻天覆地的变化，越来越多的消费者选择网络购物，省时省力。

![](图片2.jpg)

阿里巴巴公司作为中国电商的引领者，其旗下的淘宝和天猫是深受消费者欢迎的网购平台。

<!-- Slide number: 19 -->
2.2.2 实例2:2013~2019财年阿里巴巴淘宝和天猫平台的GMV
本实例要求根据下表的数据，将财年列的数据作为x轴数据，将GMV列的数据作为y轴数据，使用bar()函数绘制下图所示的柱形图。

![](Picture2.jpg)

![](图片1.jpg)

### Notes:
x = np.arange(1, 8)
y = np.array([10770, 16780, 24440, 30920, 37670, 48200, 57270])
# 绘制柱形图
plt.bar(x, y, tick_label=["FY2013", "FY2014", "FY2015",
                          "FY2016", "FY2017", "FY2018", "FY2019"], width=0.5)

<!-- Slide number: 20 -->
2.2.2 实例2:2013~2019财年阿里巴巴淘宝和天猫平台的GMV

![](Picture2.jpg)

宽度0.5
2013~2019财年的成交总额逐年增加，至2019年已经达到近60000亿元。
GMV
财年

<!-- Slide number: 21 -->
目录页
2.1    绘制折线图

![](图片18.jpg)
2.2   绘制柱形图或堆积柱形图

2.3  绘制条形图或堆积条形图
2.4    绘制堆积面积图
2.5    绘制直方图
2. 6   绘制饼图或圆环图

<!-- Slide number: 22 -->
2.3.1 使用barh()绘制条形图或堆积条形图
使用pyplot的barh()函数可以快速地绘制条形图或堆积条形图 。
语法

barh(y, width, height=0.8, left=None, align='center', *, **kwargs)
y：表示条形的y值。
width：表示条形的宽度。
height：表示条形的高度，默认值为0.8。
left：条形左侧的x坐标值，默认值为0。
align：表示条形的对齐方式，默认值为“center”,即条形与刻度线居中对齐。
tick_label：表示条形对应的刻度标签。
xerr，yerr：若未设为None，则需要为条形图添加水平/垂直误差棒。
barh()函数会返回一个BarContainer类的对象。

<!-- Slide number: 23 -->
2.3.1 使用barh()绘制条形图或堆积条形图
绘制有一组条形的条形图

y = np.arange(5)
x1 = np.array([10, 8, 7, 11, 13])
# 条形的高度
bar_height = 0.3
# 绘制条形图
plt.barh(y, x1, tick_label=['a', 'b', 'c', 'd', 'e'], height=bar_height)
示例

![](图片2.jpg)

<!-- Slide number: 24 -->
2.3.1 使用barh()绘制条形图或堆积条形图
绘制有两组条形的条形图

![](图片3.jpg)
示例

y = np.arange(5)
x1 = np.array([10, 8, 7, 11, 13])
x2 = np.array([9, 6, 5, 10, 12])
bar_height = 0.3
plt.barh(y, x1, tick_label=['a', 'b', 'c', 'd', 'e'], height=bar_height)
plt.barh(y+bar_height, x2,height=bar_height)

<!-- Slide number: 25 -->
2.3.1 使用barh()绘制条形图或堆积条形图
绘制堆积条形图
在使用barh()函数绘制图表时，可以通过给left参数传值的方式控制条形的x值，使后绘制的条形位于先绘制的条形右方。

![](图片2.jpg)

# 绘制堆积条形图
plt.barh(y, x1, tick_label=['a', 'b', 'c', 'd', 'e'], height=bar_height)
plt.barh(y, x2, left=x1, height=bar_height)
示例

<!-- Slide number: 26 -->
2.3.1 使用barh()绘制条形图或堆积条形图
绘制有误差棒的条形图
在使用barh()函数绘制图表时，可以通过给xerr、yerr参数传值的方式为条形添加误差棒。

![](图片3.jpg)
示例

# 偏差数据
error = [2, 1, 2.5, 2, 1.5]
# 绘制带有误差棒的条形图
plt.barh(y, x1, tick_label=['a', 'b', 'c', 'd', 'e'], height=bar_height)
plt.barh(y, x2, left=x1, height=bar_height, xerr=error)

<!-- Slide number: 27 -->
2.3.2 实例3：各商品种类的网购替代率
网络购物已经成为人们日常生活的一部分，它在创造新的消费方式的同时，也在改变着人们的消费模式和习惯，成为拉动居民消费的重要渠道。

![](图片13.jpg)

国家统计局抽取了771个样本，并根据这些样本测算用户网购替代率（网购用户线上消费对线下消费的替代比率）的情况。

<!-- Slide number: 28 -->
2.3.2 实例3：各商品种类的网购替代率
本实例要求根据下表的数据，将商品种类列的数据作为y轴的刻度标签，将替代率列的数据作为x轴数据，使用barh()函数绘制下图所示的条形图。

![](Picture2.jpg)

![](图片1.jpg)

各商品种类的网购替代率（部分）

### Notes:
# 03_substitution_rate_online
import matplotlib.pyplot as plt
import numpy as np
# 显示中文
plt.rcParams['font.sans-serif'] = ['SimHei']
plt.rcParams['axes.unicode_minus'] = False
x = np.array([0.959, 0.951, 0.935, 0.924, 0.893,
              0.892, 0.865, 0.863, 0.860, 0.856,
              0.854, 0.835, 0.826, 0.816, 0.798,
              0.765, 0.763, 0.67])
y = np.arange(1, 19)
labels = ["家政、家教、保姆等生活服务", "飞机票、火车票", "家具", "手机、手机配件",
          "计算机及其配套产品", "汽车用品", "通信充值、游戏充值", "个人护理用品",
          "书报杂志及音像制品", "餐饮、旅游、住宿", "家用电器",
          "食品、饮料、烟酒、保健品", "家庭日杂用品", "保险、演出票务",
          "服装、鞋帽、家用纺织品", "数码产品", "其他商品和服务", "工艺品、收藏品"]
# 绘制条形图
plt.barh(y, x, tick_label=labels, align="center", height=0.6)
plt.show()

<!-- Slide number: 29 -->
2.3.2 实例3：各商品种类的网购替代率
高度为0.6

![](Picture2.jpg)

由图可知，工艺品、收藏品的网购替代率最低，家政、家教、保姆等生活服务的网购替代率最高。
网购替代率

<!-- Slide number: 30 -->
plt.rcParams['font.sans-serif'] = ['SimHei’]
#设置 matplotlib 的无衬线字体为黑体 (SimHei)，解决图表里中文显示方框乱码的问题。
plt.rcParams['axes.unicode_minus'] = False
#关闭负号的 unicode 渲染，防止设置中文字体后，坐标轴上的负号 - 变成方框无法正常显示。

<!-- Slide number: 31 -->
目录页
2.1    绘制折线图

![](图片18.jpg)
2.2   绘制柱形图或堆积柱形图
2.3  绘制条形图或堆积条形图

2.4    绘制堆积面积图
2.5    绘制直方图
2. 6   绘制饼图或圆环图

<!-- Slide number: 32 -->
2.4.1 使用stackplot()绘制堆积面积图
使用pyplot的stackplot()函数可以快速地绘制堆积面积图 。
语法

stackplot(x, y,labels=(), baseline='zero', data=None, *args, **kwargs)
x：表示x轴的数据，可以是一维数组。
y：表示y轴的数据，可以是二维数组或一维数组序列。
labels：表示每个填充区域的标签。
baseline：表示计算基线的方法，包括zero、sym、wiggle和weighted_wiggle。其中zero表示恒定零基线，即简单的叠加图；sym表示对称于零基线；wiggle表示最小化平方斜率之和；weighted_wiggle表示执行相同的操作，但权重用于说明每层的大小。

<!-- Slide number: 33 -->
2.4.1 使用stackplot()绘制堆积面积图
绘制有三个填充区域堆叠的堆积面积图

![](图片2.jpg)

x = np.arange(6)
y1 = np.array([1,4,3,5,6,7])
y2 = np.array([1,3,4,2,7,6])
y3 = np.array([3,4,3,6,5,5])
# 绘制堆积面积图
plt.stackplot(x, y1, y2, y3)
示例

<!-- Slide number: 34 -->
2.4.2 实例4：物流公司物流费用统计
近些年我国物流行业蓬勃房展，目前已经有近几千家物流公司，其中部分物流公司大打价格战，以更低的价格吸引更多的客户，从而抢占市场份额。

![](图片2.jpg)

![](图片4.jpg)

<!-- Slide number: 35 -->
2.4.2 实例4：物流公司物流费用统计
本实例要求根据下表的数据，将月份列的数据作为x轴的刻度标签，将A公司、B公司、C公司这三列数据作为y轴的数据，使用stackplot()函数绘制下图所示的堆积面积图。

![](图片12.jpg)

![](图片1.jpg)

### Notes:
# 04_logistics_cost_statistics
import numpy as np
import matplotlib.pyplot as plt
x = np.arange(1, 13)
y_a = np.array([198, 215, 245, 222, 200, 236, 201, 253, 236, 200, 266, 290])
y_b = np.array([203, 236, 200, 236, 269, 216, 298, 333, 301, 349, 360, 368])
y_c = np.array([185, 205, 226, 199, 238, 200, 250, 209, 246, 219, 253, 288])
# 绘制堆积面积图
plt.stackplot(x, y_a, y_b, y_c)
plt.show()

<!-- Slide number: 36 -->
2.4.2 实例4：物流公司物流费用统计
物流费用

![](图片3.jpg)
C公司的物流费用
B公司的物流费用

B公司的物流费用呈现明显的增长趋势， A公司和C公司的物流费用呈现平缓的波动趋势。
A公司的物流费用
月份

<!-- Slide number: 37 -->
目录页
2.1    绘制折线图

![](图片18.jpg)
2.2   绘制柱形图或堆积柱形图
2.3  绘制条形图或堆积条形图
2.4    绘制堆积面积图

2.5    绘制直方图
2. 6   绘制饼图或圆环图

<!-- Slide number: 38 -->
2.5.1 使用hist()绘制直方图
使用pyplot的hist()函数可以快速地绘制直方图 。
语法

hist(x, bins=None, range=None, density=None, weights=None,
       bottom=None,  **kwargs)
x：表示x轴的数据。
bins：表示矩形条的个数，默认为10。
range：表示数据的范围，若未设置范围，默认数据范围为(x.min(), x.max())。
cumulative  /ˈkjuːmjələtɪv/ ：表示是否计算累计频数或频率。
histtype：表示直方图的类型，支持'bar'、'barstacked'、'step'、'stepfilled‘四种取值，
其中'bar'为默认值，代表传统的直方图；'barstacked'代表堆积直方图；'step'代表未填充的线条直方图；'stepfilled'代表填充的线条直方图。

### Notes:

<!-- Slide number: 39 -->
2.5.2 实例5：人脸识别的灰度直方图
人脸识别技术是一种生物特征识别技术，它通过从装有摄像头的终端设备拍摄的人脸图像中抽取人的个性化特征，以此来识别人的身份。

![](图片3.jpg)

灰度直方图是实现人脸识别的方法之一，它将数字图像的所有像素按照灰度值的大小统计其出现的频率。

### Notes:
# 05_face_recognition
import matplotlib.pyplot as plt
import numpy as np
# 10000 个随机数
random_state = np.random.RandomState(19680801)
random_x = random_state.randn(10000)
# 绘制包含 25个矩形条的直方图
plt.hist(random_x, bins=25)
plt.show()

<!-- Slide number: 40 -->
2.5.2 实例5：人脸识别的灰度直方图
本实例要求使用一组10000个随机数作为人脸图像的灰度值，使用hist()函数绘制下图所示的灰度直方图。

![](图片14.jpg)
# 10000个随机数
random_state = np.random.RandomState(19680801)
radom_x = random_state.randn(10000)
# 绘制包含25个矩形条的直方图
plt.hist(radom_x, bins=25)

<!-- Slide number: 41 -->
2.5.2 实例5：人脸识别的灰度直方图
频率

![](图片2.jpg)

由图可知，位于-0.5~0之间的灰度值最多，位于-4~-3或3~4之间的灰度值最少。
25个矩形条
灰度值

<!-- Slide number: 42 -->
目录页
2.1    绘制折线图

![](图片18.jpg)
2.2   绘制柱形图或堆积柱形图
2.3  绘制条形图或堆积条形图
2.4    绘制堆积面积图
2.5    绘制直方图

2. 6   绘制饼图或圆环图

<!-- Slide number: 43 -->
2.6.1 使用pie()绘制饼图或圆环图
使用pyplot的pie()函数可以快速地绘制饼图或圆环图 。
语法

pie(x, explode=None, labels=None, autopct=None, pctdistance=0.6,
      startangle=None, *, data=None)
x：表示扇形或楔形的数据。
explode：表示扇形或楔形离开圆心的距离。
labels：表示扇形或楔形对应的标签文本。
autopct：表示控制扇形或楔形的数值显示的字符串，可通过格式字符串指定小数点后的位数。
pctdistance：表示扇形或楔形对应的数值标签距离圆心的比例，默认为0.6。
shadow：表示是否显示阴影。
labeldistance：表示标签文本的绘制位置（相对于半径的比例），默认为1.1。

<!-- Slide number: 44 -->
2.6.1 使用pie()绘制饼图或圆环图
使用pyplot的pie()函数可以快速地绘制饼图或圆环图 。
语法

pie(x, explode=None, labels=None, autopct=None, pctdistance=0.6,
      startangle=None, *, data=None)
startangle：表示起始绘制角度，默认从x轴的正方向逆时针绘制。
radius：表示扇形或楔形围成的圆形半径。
wedgeprops：表示控制扇形或楔形属性的字典。例如，通过wedgeprops = {'width': 0.7} 将楔形的宽度设为0.7。
textprops：表示控制图表中文本属性的字典。
center：表示图表的中心点位置，默认为（0,0）。
frame：表示是否显示图框。

<!-- Slide number: 45 -->
2.6.1 使用pie()绘制饼图或圆环图
绘制饼图

![](图片2.jpg)

示例
data = np.array([20, 50, 10, 15, 30, 55])
pie_labels = np.array(['A', 'B', 'C', 'D', 'E', 'F'])
# 绘制饼图：半径为0.5，数值保留1位小数
plt.pie(data, radius=1.5, labels=pie_labels, autopct='%3.1f%%')

<!-- Slide number: 46 -->
2.6.1 使用pie()绘制饼图或圆环图
绘制圆环图

示例

![](图片3.jpg)
data = np.array([20, 50, 10, 15, 30, 55])
pie_labels = np.array(['A', 'B', 'C', 'D', 'E', 'F'])
# 绘制圆环图
plt.pie(data, radius=1.5, wedgeprops={‘width’: 0.7},
           labels=pie_labels, autopct='%3.1f%%’,
           pctdistance=0.75)

<!-- Slide number: 47 -->
2.6.2 实例6：支付宝月账单报告
近年来随着支付App的出现，人们的生活发生了翻天覆地的变化，无论是到超市选购商品，还是跟朋友聚餐，或是来一场说走就走的旅行，都可以使用移动支付App轻松完成支付，非常便捷。

![](图片2.jpg)

支付宝是人们使用较多的支付方式，它拥有自动记录每月账单的功能，可以方便用户了解每月资金的流动情况。

<!-- Slide number: 48 -->
2.6.2 实例6：支付宝月账单报告
本实例要求根据下表的数据，将分类列的数据作为饼图的标签，将各分类对应的金额与总支出金额的比例作为饼图的数据，使用pie()函数绘制下图所示的饼图。

![](图片3.jpg)

![](图片1.jpg)

<!-- Slide number: 49 -->
2.6.2 实例6：支付宝月账单报告
起始角度为90

![](图片9.jpg)

绿色扇形的面积最大，说明餐饮美食方面的支出在当月总支出中占比最大；橙色扇形的面积最小，说明人情往来的支出在当月总支出中占比最小。
离开圆心距离为0.1
显示阴影

### Notes:

<!-- Slide number: 50 -->
目录页

2.7    绘制散点图或气泡图

![](图片18.jpg)
2.8   绘制箱形图
2.9   绘制雷达图
2.10   绘制误差棒图

### Notes:

<!-- Slide number: 51 -->
2.7.1 使用scatter()绘制散点图或气泡图
使用pyplot的scatter()函数可以快速地绘制散点图或气泡图 。
语法

scatter(x, y, s=None, c=None, marker=None, cmap=None, linewidths=None, edgecolors=None, *, **kwargs)
x，y：表示数据点的位置。
s：表示数据点的大小。
c：表示数据点的颜色。
marker：表示数据点的样式，默认为圆形。
alpha：表示透明度，可以取值为0~1。
linewidths：表示数据点的描边宽度。
edgecolors：表示数据点的描边颜色。

<!-- Slide number: 52 -->
2.7.1 使用scatter()绘制散点图或气泡图
绘制散点图

![](图片2.jpg)

示例
num = 50
x = np.random.rand(num)
y = np.random.rand(num)
plt.scatter (x, y)

<!-- Slide number: 53 -->
2.7.1 使用scatter()绘制散点图或气泡图
绘制气泡图

![](图片3.jpg)
示例

num = 50
x = np.random.rand(num)
y = np.random.rand(num)
area = (30 * np.random.rand(num))**2
plt.scatter(x, y, s=area)

<!-- Slide number: 54 -->
2.7.2 实例7：汽车速度与制动距离的关系
汽车的制动距离主要取决于汽车的车速。若车速增加1倍，则汽车的制动距离将增大至近4倍。

![](Picture2.jpg)

某汽车生产公司对一批丰田汽车进行抽样测试，并分别记录了不同的车速对应的制动距离。

<!-- Slide number: 55 -->
2.7.2 实例7：汽车速度与制动距离的关系
本实例要求根据下表的数据，将车速(km/h)列的数据作为x轴的数据，将制动距离(m)列的数据作为y轴的数据，使用scatter()函数绘制下图所示的散点图。

![](图片11.jpg)

![](图片1.jpg)

<!-- Slide number: 56 -->
2.7.2 实例7：汽车速度与制动距离的关系
制动距离

![](图片2.jpg)

由图可知，恒定条件下，制动距离随着车速的增大而增加。
车速

<!-- Slide number: 57 -->
2.11 本章小结

![](Picture2.jpg)
本章主要介绍了如何使用matplotlib库的绘图函数绘制简单的图表，包括折线图、柱形图或堆积柱形图、条形图或堆积条形图、堆积面积图、直方图、饼图或圆环图、散点图或气泡图。 通过学习本章的内容，希望大家能够掌握绘图函数的用法，可以使用这些函数绘制简单的图表，为后续的学习打好扎实的基础。

<!-- Slide number: 58 -->