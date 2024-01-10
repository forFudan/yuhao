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

宇浩输入法开发非一日之功,使用了很多 Python (numpy, pandas, porlas...) 程序的辅助决策.这里,谨将部分编程相关的内容予以展示和讨论,以供输入法或数据分析的同好参研,以期共同进步.

本文的写作也不会是一朝一夕,我将逐渐往里面增加内容.

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

本文其他代码都使用本引用.

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

字频加权选重率,有可以称为「动态选重率」,可以表达为:

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
            因为这一项操作只需要进行一次.不需要放入函数中循环.

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

