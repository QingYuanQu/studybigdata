import numpy as np
import matplotlib.pyplot as plt

plt.rcParams['font.sans-serif'] = ['Microsoft YaHei']
plt.rcParams['axes.unicode_minus'] = False

rng = np.random.default_rng(20260920)

commute = rng.lognormal(np.log(34), 0.32, 2000)
x = commute[:400]        # 先从全员里抽 400 人来看，对应图1

counts, edges, patches = plt.hist(x, bins=12, edgecolor='white')
plt.show()
print(counts)   # 各组人数，长度 = 组数
print(edges)    # 各组边界，长度 = 组数 + 1