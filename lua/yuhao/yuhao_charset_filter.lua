--[[
Name: yuhao_charset_filter.lua
名称: 常用繁簡字符過濾腳本
Version: 20240512
Author: 朱宇浩 (forFudan) <dr.yuhao.zhu@outlook.com>
Github: https://github.com/forFudan/
Purpose: 從候選項中過濾出常用繁簡漢字
版權聲明：
專爲宇浩輸入法製作 <https://zhuyuhao.com/yuhao/>
轉載請保留作者名和出處
Creative Commons Attribution-NonCommercial-NoDerivatives 4.0
    International
------------------------------------------------------------------------

介紹:
字符過濾 charaset_filter 在鼠鬚管中不再有效,因爲 librime-charcode 被
    單獨出来作爲插件.
所以我寫了這個 lua 腳本過濾:
    - 常用繁簡漢字 (通用規範漢字 + 國字常用字 + 部分古籍通規字).
    - 通用規範漢字表約 8000 字.
    - 調和大陸繁體標準約 8000 字.
        古籍通規繁體標準 及 調和大陸繁體標準 詳見
        <https://github.com/forFudan/GujiCC>
非 CJK 的字符以及 CJK 中的符号區不會被過濾.

Description:
The charaset_filter is not enabled in the Squirrel as librime-charcode
    was exclused as a standalone plug-in.
So a lua filter would be helpful to filter the frequently used
    characters (GB2312 + 常用國字標準字體表 + other characters).

版本：
20221001: 使用遍歷法寫成.
20230418: 使用集合法重寫代碼,大幅度提升運行效率,不再有卡頓現象.
20240107: 更改判斷邏輯.詞語中只要有一個字符在常用字符集内,則提高詞語
    整體優先級.此前,詞語中的所有字符都必須在常用字符集内纔會優先.
20240407: 只判斷長度爲 1 到 10 的候選項.
20240512: 重構代碼.將核心函數寫入 yuhao_core.lua 文件.將常用字符集寫
    入 yuhao_charset.lua 文件.增加一項判斷: 始終不過濾非 CJK 字符.
    增加常用繁簡字符集和通規字符集.
20240807: 重構並加入常用字前置代碼.
20240819: 前置常用漢字功能只對 CJK 内的漢字生效.
20240820: 前置常用漢字功能只在輸入爲四碼時方纔生效.
20240908: 加入前置極常用繁簡漢字功能.
------------------------------------------------------------------------
]]

local core = require("yuhao.yuhao_core")
local yuhao_charsets = require("yuhao.yuhao_charsets")
local set_of_ubiquitous_chars = core.set_from_str(yuhao_charsets.ubiquitous)
local set_of_common_chars = core.set_from_str(yuhao_charsets.common)
local set_of_tonggui_chars = core.set_from_str(yuhao_charsets.tonggui)
local set_of_harmonic_chars = core.set_from_str(yuhao_charsets.harmonic)

--- 前置器
local function yuhao_charset_prioritizer(input, env, option, charset)
    local switch_on = env.engine.context:get_option(option)
    local chars_of_low_priority = {}
    local length_of_input_is_4 = (string.len(env.engine.context.input) == 4)
    if not length_of_input_is_4 then
        for cand in input:iter() do
            yield(cand)
        end
    end
    if length_of_input_is_4 then
        for cand in input:iter() do
            local is_charset_or_not_cjk = core.string_is_in_set(cand.text, charset)
            -- 二種情況顯示字符: (1) 極常用 (2) 過濾器關閉
            if is_charset_or_not_cjk or not switch_on then
                yield(cand)
            else
                table.insert(chars_of_low_priority, cand)
            end
        end
        -- 非常用字词后置
        for i, cand in ipairs(chars_of_low_priority) do
            yield(cand)
        end
    end
end

--- 前置極常用繁簡漢字
local function yuhao_charset_prioritizer_ubiquitous(input, env)
    yuhao_charset_prioritizer(input, env, "yuhao_charset_prioritizer_ubiquitous", set_of_ubiquitous_chars)
end

--- 前置常用繁簡漢字
local function yuhao_charset_prioritizer_common(input, env)
    yuhao_charset_prioritizer(input, env, "yuhao_charset_prioritizer_common", set_of_common_chars)
end

local function yuhao_charset_filter_common(input, env)
    local switch_on = env.engine.context:get_option("yuhao_charset_filter_common")
    for cand in input:iter() do
        local is_charset_or_not_cjk = core.string_is_in_charset_or_not_in_cjk(cand.text, set_of_common_chars)
        -- 三種情況顯示字符: (1) 常用 (2) 非 CJK (3) 過濾器關閉
        if is_charset_or_not_cjk or not switch_on then
            yield(cand)
        end
    end
end

local function yuhao_charset_filter_tonggui(input, env)
    local switch_on = env.engine.context:get_option("yuhao_charset_filter_tonggui")
    for cand in input:iter() do
        local is_charset_or_not_cjk = core.string_is_in_charset_or_not_in_cjk(cand.text, set_of_tonggui_chars)
        -- 三種情況顯示字符: (1) 常用 (2) 非 CJK (3) 過濾器關閉
        if is_charset_or_not_cjk or not switch_on then
            yield(cand)
        end
    end
end

local function yuhao_charset_filter_harmonic(input, env)
    local switch_on = env.engine.context:get_option("yuhao_charset_filter_harmonic")
    for cand in input:iter() do
        local is_charset_or_not_cjk = core.string_is_in_charset_or_not_in_cjk(cand.text, set_of_harmonic_chars)
        -- 三種情況顯示字符: (1) 常用 (2) 非 CJK (3) 過濾器關閉
        if is_charset_or_not_cjk or not switch_on then
            yield(cand)
        end
    end
end

return {
    yuhao_charset_prioritizer_ubiquitous = yuhao_charset_prioritizer_ubiquitous,
    yuhao_charset_prioritizer_common = yuhao_charset_prioritizer_common,
    yuhao_charset_filter_common = yuhao_charset_filter_common,
    yuhao_charset_filter_tonggui = yuhao_charset_filter_tonggui,
    yuhao_charset_filter_harmonic = yuhao_charset_filter_harmonic,
}
