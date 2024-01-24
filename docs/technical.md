---
title: 技术文档
layout: default
nav_order: 31
has_children: true
---

<!-- omit in toc -->
# 宇浩输入法开发技术文档
{: .no_toc }

<details open markdown="block">
  <summary>
    目录
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

宇浩输入法开发非一日之功,使用了很多 Python (numpy, pandas, porlas...) 程序的辅助决策.这里,谨将部分编程相关的内容予以展示和讨论,供输入法或数据分析的同好参研,以期共同进步.

本文的写作也不会是一朝一夕,我将逐渐往里面增加内容.

繁简通打、动静低重、字根分区、兼顾手感，这是宇浩输入法的四个基本设计原则，目的在于避免机器学习中的「过拟合问题」，防止输入法被局限于特定的文本空间和字形状态，以期获得更大的适用性。在保证这四个原则的基础上，作者还采用了其他的客观指标作为「宇浩算法」的约束条件，以提高输入法的整体素质，防止有严重的短板产生。做到「整体性能均衡，部分指标优异」。

以下介绍为作者设计本输入法时所考量的客观指标，这些指标在编写优化算法的时候得到了应用，并且配以不同的权重。在此将其中重要的予以列出，方便用户进行深入了解。某些指标的详细计算公式，可以参考本网站研究板块，方便有一定统计背景的研究者评议。

宇浩输入法优化时，进行局部最大化的指标，按重要性排列：

- 字根键位空间聚合度。或者说是字根排布的规律性。光华方案采用类似五笔的「首笔分区布局」，星陈方案采用类似郑码的「相似字形聚合」。该布局下，每个字根可能存在的键位空间在 4 - 6 之间。故而，每个字根优化空间只有全乱序布局的 25%。优点：依照形码设计原理，易于上手，方便学习。缺点：各项指标理论极限低于纯乱序排布方案。
- 最大化键位舒适度（简体、繁体）。键盘上每一个按键，都有一个得分。食指、中指上的按键的分较高，无名指、中指上的按键得分较低。中排的按键得分较高，下派的按键的分较低。手指位移小的按键得分较高。比如 T 得分大于 Y。因为 Z 键比较难按，在部分输入平台又预留为功能键，故而本输入法不在 Z 上设置大码。优点：提升手感，增加平台通用性。缺点：全码理论编码空间只有 26 键方案的 85%，理论极限离散水平低于 26 键方案。
- 最大化各文本空间[双手互击率](./articles/statistics#古今名著双手互击频率)。在连续文本的情况下，计算编码的双手互击率（包括标点符号）。如：「我今天去那里」，编码为 qaggtobufgdihvvtvacjksij。出现了14次同手击键，9次双手互击，故而互击率为 39.13%。这里用到了隐马尔科夫链或大样本统计，以计算每个汉字后下一个汉字的频率，从而得到连续文本的双手互击率。因为宇浩输入法是将字根按照键盘分区进行排布的，相对于全乱序字根排布的方案，双手互击方面有天生的劣势。如果不进行优化，那么会影响手感。这也是为什么宇浩输入法将双手互击率专门拿出来进行优化。宇浩输入法在保证字根分区、二十五键、重码极低、繁简通打这四个原则下，将双手互击率拉到可观的水平，星陈方案的双手互击率甚至达到了62.5%.

宇浩输入法优化时，进行局部最小化的指标，按重要性排列：

- 最小化简体文本、繁体文本、混合文本下的[全码动态选重率](./articles/statistics#单字重码计算公式)。优点：实现真正意义上的繁简通打。用户使用本方案就可以自由切换繁简输入，不用选重。缺点：影响了极限简体/繁体文本各自的动态选重率，不过本输入方案的简体/繁体动态选重率已经是**市面上最低**的，所以这个缺点可以忽略。
- 最小化 GB2312、国字常用字的静态重码数量。这是因为动态选重率高度依赖文本的状态，而静态重码数量在非典范白话文的情况下更具有代表性。
- 最小化 GBK 的静态重码数量和翻页次数。这是为了不丢失检字的性能。本输入法 CJK 全汉字单编码最高重码字数为18个，也就是说，即使是生僻字，最多翻页一次即可找到。
- 最小化简体文本下的[完美词语选重率](./articles/statistics#词语重码计算公式)，使用了当代汉语词频表。例如，「我今天去那里」被分割成「我·今天·去·那里」，一共有 4 个词语。倘若「我」和「那里」发生了重码，则选重率为 1 / 4 = 25%。优点：考虑该指标，可以优化用户打词时的选重体验。缺点：本指标的成立条件，只有当用户的分词习惯和词频表一致才有效。大多时候，用户会将词语拆成单字输入，避免词语不存在时的回删。因此，真实的文本选重率，介于单字动态选重率和完美词语选重率之间。另外，当样本空间改变时，比如输入非典范白话文的情况下，本指标参考价值也会降低。
- 最小化速度当量（[陈一凡, 张鹿, 周志农, 1990,《键位相关速度当量的研究》,《中文信息学报 Vol.4》](http://jcip.cipsc.org.cn/CN/Y1990/V4/I4/14)）。速度当量是关于「手感」的最宏观、量化的指标，是由大量实验得出的结果，具有很高的参考价值。这个指标越小，表明输入的速度越快。宇浩输入法在优化过程中，最小化字频加权速度当量。

## 算法代码

以下为「宇浩算法」伪代码，谨供参考。

```python
# 「宇浩算法」僞代碼
k_max: int  # 外層淬火輪數
l_max: int  # 内層貪婪輪數
t_k: float  # 混亂度
x_1: Sequence[str]  # 字根編碼
y_1: float  # = f(x_1) 當前各指標加權分值
x_1_best, y_1_best = x_1, y_1  # 最優解
# 外層淬火 開始
for k in range(1, k_max):
    x_2 = rand(x_1)  # 隨機擾動
    y_2 = f(x_2)
    x_2_best, y_2_best = x_2, y_2
    # 内層貪婪 開始
    for l in range(1, l_max):
        # 同大碼字根組遍歷 開始
        for roots in groups_of_roots:
            # 該組字根大碼遍歷候選鍵位或分區 開始
            for dama in dama_candidates:
                # 該組字根小碼遍歷候選鍵位的組合 開始
                for xiaoma in product(*xiaoma_candidates):
                    x_trial: Sequence[str]  # = f(x_2, dama, xiaoma)
                    y_trial: float  # = f(x_trial)
                    y_delta = y_trial - y
                    if y_delta <= 0:
                        x_2, y_2 = x_trial, y_trial
                    if y_trial < y_2_best:
                        x_2_best, y_2_best = x_trial, y_trial
                # 該組字根小碼遍歷候選鍵位的組合 結束
            # 該組大碼遍歷候選鍵位或分區 結束
        # 同大碼字根組遍歷 結束
    # 内層貪婪 結束
    y_delta = y_2_best - y_1
    if (y_delta <= 0) or (random.uniform(0, 1) < np.exp(-y_delta / t_k)):
        x_1, y_1 = x_2_best, y_2_best
    if y_2_best < y_1_best:
        x_1_best, y_1_best = x_2_best, y_2_best
    t_k = 0.75 * t_k  # 使用指數降溫
# 外層淬火結束
print(x_1_best)
```

## 量化指标

评价一个输入法的好坏,需要从不同的维度进行判断.同时,每一个人对于不同维度的偏好也是不同的.这就说明不存在一个完美的输入法,使得它对于不同维度的权重排序满足所有人的偏好排序(经济学上,有个著名的「阿罗不可能定理」 Arrow's impossibility theorem).但是,通过显示不同维度的量化数据,可以帮助用户进行权衡.

量化的数据可以反映实际的体验,但不一定能完美代表真实体验.因为量化指标无法覆盖全部的维度,且在实际当中,影响输入体验的要素(杂音)很多.例如,键盘字母的排序,是传统的还是德沃夏克的,都会影响所谓的「手感」.再比如,所谓的动态选重率,一般是基于一个大样本的文字频率,这个频率虽具有代表性,但也只是代表一种社会文化的均值.对于每一个用户来说,未必会使用相同的样本空间,例如个人姓名用字的使用频率往往会较高.如果姓名出现重码,需要选重,会使得用户的体验不佳.

在宇浩输入法的首页和[这篇文章](../articles/statistics.md)中,我对宇浩输入法所采用算法和指标进行了介绍.在这篇文章中,我将展示它们是如何在 Python 中被计算和实现的.Python 的特点是部署效率很高但运行效率不高,所以我对某些需要大量循环的函数进行了一些优化,主要是利用了 numpy, pandas, polars 等包的一些特性.这些包一般使用 C/C++/Fortran/Rust 编写,对于向量计算有着高度的优化.这篇文章中,我也会讨论某些代码为什么要这样写.

### 字集静态重码数

单字的静态重码,指的是在一个字符集中,编码完全相同的汉字的个数.

假设 $$Z$$ 为一个汉字的集合, $$M$$ 为一个编码的集合, $$p:Z\rightarrow [0,1]$$ 为汉字到某文本状态下单字频率的映射.

用编码和字频对汉字排序, 使汉字 $$z_{ij}$$ 是编码为 $$m_i$$ 的第 $$j$$ 个汉字, $$i \in I$$, $$j \in J_i$$, 且满足 $$a\geq b$$ 时, $$f(z_{ia})\geq f(z_{ib})$$.

那么,静态重码数可以表达为：

$$N_{s} = \mid \{z_{ia}, z_{ib}  \text{ if } M(z_{ia}) = M(z_{ib}) \text{ for all } a,b \in J_i \text{ and } i \in I \}.$$

对于此指标的计算,较为简单.但为了运行的效率考虑,我们可以使用 numpy 包.

```python
import numpy as np
import typing
import numpy.typing as npt
```

本文其他代码都使用以上引用.

```python
def get_static_dup_rate(
    char: npt.NDArray[np.dtype("<U1")],
    code: npt.NDArray[np.dtype("<U4")],
    charset: typing.Sequence,
) -> int:
    """计算某个字集内的静态重码数

    Args:
        char (npt.NDArray[np.dtype): 元素为汉字.
        code (npt.NDArray[np.dtype): 元素为编码.
            宇浩输入法编码不超过四位,所以编码的格式是 4 个 Unicode 组成的字符串.
        charset (typing.Sequence): 字集.元素为汉字.比如通规汉字或 GBK.

    Returns:
        int: 静态重码数:
    """
    idx_char_in_scope = np.isin(char, charset)
    _, dup_counts = np.unique(code[idx_char_in_scope], return_counts=True)
    return dup_counts[dup_counts > 1].sum()
```

### 字频加权选重率

字频加权选重率,又可以称为「动态选重率」,可以表达为:

$$N_{d} = \sum\limits_{i \in I, j \in J_i/\{1\}} p(z_{ij}).$$

```python
def get_dynamic_dup_rate(
    code: npt.NDArray[np.dtype("<U4")],
    freq: npt.NDArray,
    idx_sorted_freq: npt.NDArray[np.dtype("i")],
) -> float:
    """计算字频加权选重率(动态重码率)

    Args:
        code (npt.NDArray[np.dtype): 元素为汉字对应的编码.
            宇浩输入法编码不超过四位,所以编码的格式是 4 个 Unicode 组成的字符串.
        freq (npt.NDArray): 元素为汉字对应的字频.
        idx_sorted_freq (npt.NDArray[np.dtype): 根据字频进行降序排列的索引.
            一般的: idx_sorted_freq = np.argsort(-freq)
            因为这一项操作只需要进行一次,故而不需要放入函数中循环.

    Returns:
        float: 字频加权选重率.
    """
    # 字频降序后的编码和字频列表
    code = code[idx_sorted_freq]
    freq = freq[idx_sorted_freq]
    # 得到第一个非重复的编码的索引
    _, idx_unique_freq = np.unique(code, return_index=True)
    # 生成一个掩码层,将重复的编码筛出
    duplicated_mask = np.full(freq.shape, True)
    duplicated_mask[idx_unique_freq] = False
    # 重复的编码,就是需要选重的字
    # 将这些重复的编码所对应的字频进行求和
    return freq[duplicated_mask].sum()
```

