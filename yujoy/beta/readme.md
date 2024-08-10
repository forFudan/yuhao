# 宇浩·卿雲

## schema

/scheme 中的文件爲 Rime 輸入法各平臺（小狼毫、鼠鬚管）碼表。

複製所有文件至機器上的 /Rime 文件夾。

請在 default.custom.yaml 文件的 patch/schema_list 列表中手動添加本方案名如下：

patch:
  schema_list:
    - schema: yujoy
    - schema: yujoy_sc # 以简化汉字字频设置简码
    - schema: yujoy_tw # 以臺灣傳統漢字字頻設置簡碼
    - schema: yujoy_fluency # 全碼單字無空格連續輸入

重新部署后即可使用。

## custom

/custom 中的文件爲 Rime 輸入法各平臺（小狼毫、鼠鬚管）方案的自定義設定。

## hotfix

/hotfix 中的文件，用於 Android 平臺的「中文輸入法」，以及一些 Rime 内核較老的程序。使用時，直接將文件覆蓋 /schema 下的原文件即可。

## mabiao

/mabiao 中的文件是其他平臺的碼表。
