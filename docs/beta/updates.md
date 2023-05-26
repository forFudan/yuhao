---
title: 发烧区更新日志
layout: default
parent: 发烧测试
nav_order: 1
---

{: .warning }
>本區只用於功能測試和意見收集，不是正式版本，也不完全反映未來發展方向。

<!-- omit in toc -->
# 發燒區更新日誌

## 2023年5月25日

「帶」改拆「一儿一冖巾」，因爲符合筆順。

小碼改變：

- 乃 Va -> Vj 分散雙手
- 龰 Nh -> Nn -> Nd 防止 Nh 單指跨行
- 彡 Ti -> To 讓出碼位給「八」
- 八 Tb -> Td -> Ti 防止 Tb 單指大跨行，分散雙手
- 九 Yj -> Yf 分散雙手，汉字密度 Yj19 Yf11

## 2023年5月23日

增加一個文件夾 [generator](../../beta/generator/)，包含三個用來生成一級、二級、三級簡碼字詞的文件。如果發現任何 bug，可以直接提出 issue 或者 push commits。

## 2023年5月22日

四重註解中，詞語編碼用大小寫來區分大小碼。

加入「功能開關一鍵配置」文件：

- yuhao.custom.yaml
- yuhao_tradition.custom.yaml
- yuhao_tradition_tw.custom.yaml

删除「四豎」字根，因爲只在全字集中被使用了一次。

## 2023年5月21日

RIME 增加拼音註解。現總共爲四重註解。

小碼改變：

- 凵 Xa -> Xe -> Xg 韻母「丱」，防止大跨行

## 2023年5月20日

增加測試版方案的[在線字根練習](../../beta/practice/practice.html)。

小碼改變：

- 其 Dq -> Dj 聲母，減少小拇指負擔
- 凵 Xa -> Xe 韻母

## 2023年5月19日

增加近四千個臺灣字形兼容拆分，調整臺灣方案簡碼。凡臺灣繁體詞語，都使用臺灣字形編碼。比如「起來=走己來」`DBDl` 和「起=走巳來」`DCDl` 兼收。

在線拆分系統現也增加臺灣拆分一欄。

小碼改變：

- 氵 Iv -> Iu -> Ic 分散雙手
- 艹 So -> Sa -> Sj 韻母，防止 Sa 無名指小拇指連擊
- 乂 Wa -> Wl 分散雙手

## 2023年5月18日

小碼改變：

- 扌 As -> Ao 韻母，防止 As 無名指小拇指連擊
- 壬 Er -> En 韻母，分散雙手，汉字密度 Er22 En14
- 士 Hh -> Hf 分散雙手
- 户 Ih -> Ie 分散雙手
- 水 Kh -> Kv 韻母 u 轉 v，汉字密度 Kv7 Kh13
- 冂 Kg -> Kf， 同 「匚」Gf小碼一致
- 目 Mu -> Mk -> Mf，增加双手互击。
- 虎 Mh -> Mu 韻母，汉字密度 Mh20 Mu6
- 巾 Mv -> Mj -> Mv
- 王 Gv -> Gw -> Gn，增加双手互击，汉字密度 Gw25 Gn7
- 龰 Nh -> Nn， 防止 Mh 單指跨行，汉字密度 Nh 13 Nn 5
- 之 Pc -> Pe，改善手感
- 𠂇 Sv -> Ss -> So 「左」韻母。
- 巛 Vh -> Vc，聲母，同 「川」Qc 小碼一致，汉字密度 Vc3 Vh11

增加一個自定義碼表：yuhao.private.dict.yaml，優先級高於官方詞庫。原自定義碼表 yuhao.private.dict.yaml 優先級低於官方詞庫。
