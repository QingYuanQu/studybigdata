# -*- coding: utf-8 -*-
"""生成《直方图》教学文档所需配图，并就地打印关键统计量供文档核对。

所有图存到 ../assets/img/（相对本脚本）。固定随机种子，保证图文可复现。

主线示例（贯穿全文）：某公司员工「单程通勤耗时」（分钟）。
选它的理由：人人有体感，且天然右偏——多数人 25~45 分钟，少数人遇堵车一路拖到 90 分钟以上，
于是偏态、分位数、组距、"几点出门才不至于迟到"这些概念能一次讲透。

依赖：numpy + matplotlib（无 scipy 依赖，KDE 用手写 numpy 实现）。
"""
import os
import warnings
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# 中文显示：用系统微软雅黑（含中文 glyph），并修复负号显示为方块的问题
plt.rcParams['font.sans-serif'] = ['Microsoft YaHei', 'SimHei',
                                   'Microsoft JhengHei', 'STSong', 'sans-serif']
plt.rcParams['axes.unicode_minus'] = False
warnings.filterwarnings('ignore')  # 屏蔽无关字体/渲染告警

XLABEL = '单程通勤耗时 / 分钟'
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(HERE, '..', 'assets', 'img'))
os.makedirs(OUT, exist_ok=True)


def save(fig, name):
    path = os.path.join(OUT, name)
    fig.savefig(path, dpi=150, bbox_inches='tight')
    plt.close(fig)
    print('[fig]', name, '->', path)


def kde_eval(x, grid, bw='scott'):
    """手写高斯核密度估计（避免 scipy 依赖）。返回与 grid 等长的概率密度。"""
    n = len(x)
    std = x.std(ddof=1)
    iqr = float(np.subtract(*np.percentile(x, [75, 25])))
    if bw == 'scott':
        h = n ** (-1 / 5) * std
    elif bw == 'silverman':
        h = 0.9 * n ** (-1 / 5) * min(std, iqr / 1.34)
    else:
        h = float(bw)
    u = (grid[:, None] - x[None, :]) / h
    phi = np.exp(-0.5 * u ** 2) / np.sqrt(2 * np.pi)
    return phi.mean(axis=1) / h, h


def fig_normal_pdf():
    """图：正态分布 N(μ,σ²) 的钟形——μ 定中心、σ 定胖瘦（1.8 节配图）。"""
    mu, sigma = 30, 8
    x = np.linspace(mu - 4*sigma, mu + 4*sigma, 400)
    f = 1/(sigma*np.sqrt(2*np.pi)) * np.exp(-(x-mu)**2/(2*sigma**2))
    fig, ax = plt.subplots(figsize=(7.2, 3.8))
    ax.plot(x, f, 'k-', lw=2.2)
    ax.fill_between(x, f, color='#4C72B0', alpha=0.12)
    ax.axvline(mu, color='#C44E52', lw=1.6, label=r'$\mu$（中心）')
    ax.axvline(mu - sigma, color='gray', ls='--', lw=1.2)
    ax.axvline(mu + sigma, color='gray', ls='--', lw=1.2,
               label=r'$\mu\pm\sigma$（展布 / 标准差）')
    hpk = 1/(sigma*np.sqrt(2*np.pi))
    ax.annotate(r'峰高 $1/(\sigma\sqrt{2\pi})$',
                xy=(mu, hpk), xytext=(mu + 0.3*sigma, hpk*0.88),
                fontsize=8, ha='left')
    ax.set_title(r'正态分布 $N(\mu,\sigma^2)$：$\mu$ 定中心、$\sigma$ 定胖瘦')
    ax.set_xlabel('通勤耗时 / 分钟')
    ax.set_ylabel('密度')
    ax.legend(fontsize=8)
    ax.grid(alpha=0.3)
    ax.set_ylim(0, hpk*1.25)
    fig.tight_layout()
    save(fig, 'hist_normal_pdf.png')
    print('[stat] 正态钟形：mu=%.1f, sigma=%.1f, 峰高=%.4f' % (mu, sigma, hpk))


def main():
    rng = np.random.default_rng(20260920)

    # ==================================================================
    # 主数据：某公司 2000 名员工某工作日的「单程通勤耗时」（分钟）
    # 用对数正态模拟：天然右偏，符合"多数人集中在半小时上下、少数人极度漫长"的真实形貌
    # 全文所有示例都取自这一批，各图只是抽取的人数不同
    # ==================================================================
    commute = rng.lognormal(np.log(34), 0.32, 2000)

    print('[stat] 全员 n=%d：min=%.1f, 中位数=%.1f, 均值=%.1f, P90=%.1f, max=%.1f'
          % (len(commute), commute.min(), np.median(commute), commute.mean(),
             np.percentile(commute, 90), commute.max()))

    # ---- 图1.8：正态分布钟形（1.8 节配图，独立于通勤数据，纯讲形状）----
    fig_normal_pdf()

    # ---- 图1：概念图（先从全员里抽 400 人来看）----
    x1 = commute[:400]
    fig, ax = plt.subplots(figsize=(8, 4.2))
    counts, edges, patches = ax.hist(x1, bins=12, color='#4C72B0',
                                     edgecolor='white', alpha=0.9)
    ax.set_title('图1  400 名员工的单程通勤耗时（组数 k=12）')
    ax.set_xlabel(XLABEL)
    ax.set_ylabel('人数')
    # 在最高的柱子上标注人数
    top = int(np.argmax(counts))
    ax.text((edges[top] + edges[top + 1]) / 2, counts[top] + 1,
            str(int(counts[top])), ha='center', va='bottom', fontsize=9)
    ax.grid(axis='y', alpha=0.3)
    save(fig, 'hist_01_concept.png')
    print('[stat] 图1 n=%d：耗时 %.1f~%.1f 分钟，分成 12 组后组距 h=%.2f 分钟'
          % (len(x1), x1.min(), x1.max(), np.diff(edges)[0]))
    print('[stat] 图1 最高的柱子=%d 人，落在区间 [%.1f, %.1f)'
          % (counts[top], edges[top], edges[top + 1]))

    # ---- 图2b：histtype 的三种画法（单组示例，桥接参数表与多组数据）----
    # 注意：step 不填充、只有轮廓，轮廓色由 edgecolor 决定；若也设成白就看不见，
    # 故 step 面板改用可见的蓝色描边，bar/stepfilled 用白边做柱间分隔。
    fig, axes = plt.subplots(1, 3, figsize=(13, 4))
    for ax, ht in zip(axes, ['bar', 'step', 'stepfilled']):
        ec = '#4C72B0' if ht == 'step' else 'white'
        ax.hist(x1, bins=12, histtype=ht, color='#4C72B0',
                edgecolor=ec, linewidth=1.5, alpha=0.85)
        ax.set_title("histtype='%s'" % ht)
        ax.set_xlabel(XLABEL)
        ax.set_ylabel('人数')
    fig.suptitle("同一批通勤数据：'bar' vs 'step' vs 'stepfilled'"
                 "（单组下 'barstacked' 与 'bar' 外观相同）", fontsize=11)
    fig.tight_layout()
    save(fig, 'hist_02b_histtype.png')

    # ---- 图2：柱状图 vs 直方图 对比 ----
    ways = ['地铁', '自驾', '公交', '骑行', '步行']   # 通勤方式 = 离散类别
    people = [820, 560, 310, 190, 120]               # 各方式人数
    fig, axes = plt.subplots(1, 2, figsize=(11, 4.2))
    axes[0].bar(ways, people, color='#C44E52', edgecolor='white')
    axes[0].set_title('柱状图：横轴是离散类别（各通勤方式，柱间有间隙）')
    axes[0].set_ylabel('人数')
    axes[1].hist(commute, bins=15, color='#55A868', edgecolor='white')
    axes[1].set_title('直方图：横轴是连续数值被切段（通勤耗时，柱相连）')
    axes[1].set_xlabel(XLABEL)
    axes[1].set_ylabel('人数')
    fig.tight_layout()
    save(fig, 'hist_02_bar_vs_hist.png')

    # ---- 图3：组数对分布形态的影响 ----
    x3 = commute
    fig, axes = plt.subplots(1, 3, figsize=(13, 4))
    for ax, k in zip(axes, [5, 20, 60]):
        ax.hist(x3, bins=k, color='#8172B3', edgecolor='white', alpha=0.9)
        ax.set_title('k = %d 组' % k)
        ax.set_xlabel(XLABEL)
        ax.set_ylabel('人数')
    fig.suptitle('图3  同一份通勤数据（n=2000）不同组数：'
                 '组太少抹平细节，组太多全是锯齿', fontsize=11)
    fig.tight_layout()
    save(fig, 'hist_03_bin_effect.png')

    # ---- 图4：人数 vs 频率密度 ----
    x4 = commute[:800]
    fig, axes = plt.subplots(1, 2, figsize=(11, 4.2))
    c1, e1, _ = axes[0].hist(x4, bins=14, color='#4C72B0', edgecolor='white')
    axes[0].set_title('density=False：纵轴=人数')
    axes[0].set_ylabel('人数')
    c2, e2, _ = axes[1].hist(x4, bins=14, density=True,
                              color='#DD8452', edgecolor='white')
    axes[1].set_title('density=True：纵轴=频率密度（矩形面积之和=1）')
    axes[1].set_ylabel('频率密度')
    for ax in axes:
        ax.set_xlabel(XLABEL)
    # 验证面积
    area_freq = np.sum(c1 * np.diff(e1))
    area_dens = np.sum(c2 * np.diff(e2))
    fig.tight_layout()
    save(fig, 'hist_04_density.png')
    hh = float(np.diff(e1)[0])
    print('[stat] 图4 n=%d，组距 h=%.4f 分钟' % (len(x4), hh))
    print('[stat] 人数直方图矩形面积之和 = %.4f  (应≈ 组距×人数 = %.4f×%d = %.1f)'
          % (area_freq, hh, len(x4), hh * len(x4)))
    print('[stat] 频率密度直方图矩形面积之和 = %.4f  (应≈1)' % area_dens)

    # ---- 图4b：不等距分箱（纵轴是人数时"高度骗人"，必须比面积）----
    # 通勤场景天然适合不等距：高峰期所在的 30~45 分钟拆细看，
    # 罕见的超长通勤合并成一档。这么切正好能演示"看高度会误判"。
    edges_un = [0, 15, 30, 35, 40, 45, 60, 150]
    fig, axes = plt.subplots(1, 2, figsize=(11, 4.2))
    cu, eu, _ = axes[0].hist(x4, bins=edges_un, color='#4C72B0',
                             edgecolor='white')
    axes[0].set_title('不等距 + 人数：最高的柱子是 15~30 分钟档')
    axes[0].set_ylabel('人数')
    cd, ed, _ = axes[1].hist(x4, bins=edges_un, density=True,
                             color='#DD8452', edgecolor='white')
    axes[1].set_title('不等距 + 频率密度：最挤的其实是 30~35 分钟档')
    axes[1].set_ylabel('频率密度')
    for ax in axes:
        ax.set_xlabel(XLABEL)
        ax.set_xticks(edges_un)
        ax.set_xticklabels(['%g' % v for v in edges_un], rotation=45)
    fig.tight_layout()
    save(fig, 'hist_04b_unequal.png')
    tu, td = int(np.argmax(cu)), int(np.argmax(cd))
    print('[stat] 不等距分组边界 = %s' % (edges_un,))
    print('[stat] 人数最高的组：第%d组 [%.0f,%.0f) -> %d 人'
          % (tu + 1, eu[tu], eu[tu + 1], cu[tu]))
    print('[stat] 密度最高的组：第%d组 [%.0f,%.0f) -> 密度 %.5f'
          % (td + 1, ed[td], ed[td + 1], cd[td]))
    print('[stat] 不等距 density 面积和 = %.4f (应≈1)' % np.sum(cd * np.diff(ed)))
    print('[stat] 各组明细（区间 / 宽度 / 人数 / 折算成每 5 分钟的人数）：')
    for i in range(len(cu)):
        w = eu[i + 1] - eu[i]
        print('       [%3.0f,%3.0f)  宽%3.0f 分钟  %4d 人  %6.1f 人/5分钟'
              % (eu[i], eu[i + 1], w, cu[i], cu[i] / w * 5))

    # ---- 图5：几种选 bin 规则对比 ----
    x5 = commute
    rules = ['sturges', 'fd', 'sqrt', 'auto']
    fig, axes = plt.subplots(2, 2, figsize=(11, 7))
    chosen = {}
    for ax, rule in zip(axes.ravel(), rules):
        _, edges, _ = ax.hist(x5, bins=rule, color='#64B5CD',
                              edgecolor='white', alpha=0.9)
        k = len(edges) - 1
        chosen[rule] = k
        ax.set_title("bins='%s'  →  k=%d 组" % (rule, k))
        ax.set_xlabel(XLABEL)
        ax.set_ylabel('人数')
    fig.suptitle('图5  matplotlib 内置选 bin 规则（同一份通勤数据，n=2000）',
                 fontsize=11)
    fig.tight_layout()
    save(fig, 'hist_05_rules.png')
    # 同时用公式核对
    n = len(x5)
    sturges = int(np.ceil(1 + np.log2(n)))
    sqrt_k = int(np.ceil(np.sqrt(n)))
    iqr = float(np.subtract(*np.percentile(x5, [75, 25])))
    fd_h = 2 * iqr / n ** (1 / 3)
    fd_k = int(np.ceil((x5.max() - x5.min()) / fd_h))
    print('[stat] IQR = %.4f 分钟' % iqr)
    print('[stat] Sturges 公式 k=ceil(1+log2(%d)) = %d  (matplotlib 选 %d)'
          % (n, sturges, chosen['sturges']))
    print('[stat] sqrt 规则 k=ceil(sqrt(%d)) = %d  (matplotlib 选 %d)'
          % (n, sqrt_k, chosen['sqrt']))
    print('[stat] Freedman-Diaconis: h=%.3f, k=ceil(R/h)=%d  (matplotlib 选 %d)'
          % (fd_h, fd_k, chosen['fd']))

    # ---- 图6：多组数据（地铁 vs 自驾）----
    metro = rng.lognormal(np.log(32), 0.22, 700)   # 地铁：准，波动小
    car = rng.lognormal(np.log(41), 0.42, 700)     # 自驾：慢，堵起来没谱
    fig, axes = plt.subplots(1, 2, figsize=(11, 4.2))
    axes[0].hist([metro, car], bins=18, histtype='bar', label=['地铁', '自驾'],
                 color=['#4C72B0', '#C44E52'], edgecolor='white', alpha=0.85)
    axes[0].set_title('并列（histtype="bar"）')
    axes[0].legend()
    axes[1].hist([metro, car], bins=18, histtype='barstacked',
                 label=['地铁', '自驾'],
                 color=['#4C72B0', '#C44E52'], edgecolor='white', alpha=0.85)
    axes[1].set_title('堆叠（histtype="barstacked"）')
    axes[1].legend()
    for ax in axes:
        ax.set_xlabel(XLABEL)
        ax.set_ylabel('人数')
    fig.tight_layout()
    save(fig, 'hist_06_multi.png')
    print('[stat] 地铁 n=%d：中位数=%.1f, P90=%.1f 分钟'
          % (len(metro), np.median(metro), np.percentile(metro, 90)))
    print('[stat] 自驾 n=%d：中位数=%.1f, P90=%.1f 分钟'
          % (len(car), np.median(car), np.percentile(car, 90)))

    # ---- 图7：直方图 + 正态曲线 + KDE ----
    x7 = commute[:1500]
    fig, ax = plt.subplots(figsize=(8, 4.4))
    ax.hist(x7, bins=30, density=True, color='#999999',
            edgecolor='white', alpha=0.6, label='直方图（频率密度）')
    g = np.linspace(x7.min() - 5, x7.max() + 5, 400)
    mu, sd = x7.mean(), x7.std(ddof=1)
    ax.plot(g, 1 / (sd * np.sqrt(2 * np.pi)) * np.exp(-0.5 * ((g - mu) / sd) ** 2),
            'r-', lw=2, label='正态拟合曲线')
    dens, h = kde_eval(x7, g, bw='scott')
    ax.plot(g, dens, 'k--', lw=2, label='核密度估计 KDE (Scott)')
    ax.set_title('图7  通勤耗时：直方图叠加正态曲线与核密度估计')
    ax.set_xlabel(XLABEL)
    ax.set_ylabel('频率密度')
    ax.legend()
    ax.grid(alpha=0.3)
    save(fig, 'hist_07_kde.png')
    skew = float(((x7 - mu) ** 3).mean() / sd ** 3)
    print('[stat] 图7 n=%d：均值=%.2f, 标准差=%.2f, 中位数=%.2f, 偏度≈%.3f'
          % (len(x7), mu, sd, np.median(x7), skew))
    print('[stat] KDE 带宽 h=%.4f（Scott，n=%d）' % (h, len(x7)))

    # ---- 图7b：KDE 循序渐进（按数据点个数 1→2→3→5→9 逐步"堆"出来）----
    # 固定带宽 h = 全量数据的 Scott 带宽，保证 5 张图可比；只增数据点，看密度曲线如何"长"出来
    g_step = np.linspace(x7.min() - 5, x7.max() + 5, 400)
    panels = []
    ymax = 1 / np.sqrt(2 * np.pi) / h  # 单个核峰值（只有 1 个人时即上限）
    for cnt in [1, 2, 3, 5, 9]:
        xs = x7[:cnt]
        u = (g_step[:, None] - xs[None, :]) / h
        phi = np.exp(-0.5 * u ** 2) / np.sqrt(2 * np.pi)
        kde = phi.mean(axis=1) / h
        panels.append((cnt, xs, phi, kde))
        ymax = max(ymax, kde.max())
    for cnt, xs, phi, kde in panels:
        fig, ax = plt.subplots(figsize=(7.2, 3.8))
        for i in range(phi.shape[1]):
            ax.plot(g_step, phi[:, i] / h, color='#4C72B0', lw=1, alpha=0.45)
        ax.plot(g_step, kde, 'k-', lw=2, label='KDE (h=%.2f)' % h)
        ax.plot(xs, np.full_like(xs, -0.03 * ymax), '|', color='gray', alpha=0.6)
        ax.set_ylim(-0.06 * ymax, ymax * 1.12)
        ax.set_title(('1 个人：只有 1 座小山包（一条高斯曲线）'
                      if cnt == 1 else '%d 个人：前 %d 座山包叠加' % (cnt, cnt)))
        ax.set_xlabel(XLABEL)
        ax.set_ylabel('频率密度')
        ax.legend(fontsize=8, loc='upper right')
        ax.grid(alpha=0.3)
        fig.tight_layout()
        save(fig, 'hist_07b_n%d.png' % cnt)
    print('[stat] 渐进 KDE：1 人峰值≈%.4f，9 人峰值≈%.4f（固定 h=%.4f）'
          % (panels[0][3].max(), panels[-1][3].max(), h))

    # ---- 图7c：带宽 h 的影响 ----
    fig, ax = plt.subplots(figsize=(8, 4.4))
    ax.hist(x7, bins=30, density=True, color='#999999',
            edgecolor='white', alpha=0.5, label='直方图')
    for factor, c, lab in [(0.5, '#C44E52', 'h = 0.5×Scott（跟着每个样本抖）'),
                           (1.0, 'black', 'h = Scott'),
                           (2.0, '#55A868', 'h = 2×Scott（长尾被抹平）')]:
        d, _ = kde_eval(x7, g, bw=h * factor)
        ax.plot(g, d, lw=2, color=c, label=lab)
    ax.set_title('带宽 h 的作用：h 越大越平滑，h 越小越贴近每个样本')
    ax.set_xlabel(XLABEL)
    ax.set_ylabel('频率密度')
    ax.legend(fontsize=8)
    ax.grid(alpha=0.3)
    fig.tight_layout()
    save(fig, 'hist_07c_kde_bandwidth.png')
    print('[stat] 带宽 h=%.4f (Scott); 0.5h=%.4f; 2h=%.4f'
          % (h, h * 0.5, h * 2.0))

    # ---- 图8：累积直方图（"留多少时间才不至于迟到"）----
    x8 = commute
    fig, ax = plt.subplots(figsize=(8, 4.2))
    ax.hist(x8, bins=30, cumulative=True, density=True, histtype='stepfilled',
            color='#937860', alpha=0.6, edgecolor='black')
    ax.set_title('图8  累积直方图：留多少分钟出门，心里才有底')
    ax.set_xlabel(XLABEL)
    ax.set_ylabel('累积频率（到该时刻已到公司的比例）')
    ax.grid(alpha=0.3)
    save(fig, 'hist_08_cum.png')
    q1, med, q3 = np.percentile(x8, [25, 50, 75])
    for p, t in [(0.5, med), (0.25, q1), (0.75, q3), (0.9, np.percentile(x8, 90))]:
        print('[stat] %.0f%% 的人在 %.1f 分钟内到达' % (p * 100, t))

    print('[done] 所有配图已生成于', OUT)


if __name__ == '__main__':
    main()
