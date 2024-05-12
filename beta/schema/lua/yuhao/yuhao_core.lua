--[[
Name: yuhao_core.lua
名称: 宇浩輸入法核心函數
Version: 20240512
Author: 朱宇浩 (forFudan) <dr.yuhao.zhu@outlook.com>
Github: https://github.com/forFudan/
Purpose: 宇浩輸入法的 RIME lua 提供核心函數
版權聲明：
專爲宇浩輸入法製作 <https://yuhao.forfudan.com>
轉載請保留作者名和出處
Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International
-------------------------------------
版本：
20230418: 寫成 set_from_str, is_subset.
20240107: 寫成 is_intersected.
20240512: 重構函數, 寫成 len_of_set, string_is_in_set,
    char_is_in_unicode_blocks, string_is_in_unicode_blocks
    string_is_in_charset_or_not_in_cjk
---------------------------
]]

local core = {}

---@param text string
---@return table
-- 將字符串轉化爲 set
function core.set_from_str(text)
    local t = {}
    for p, c in utf8.codes(text) do
        t[utf8.char(c)] = true
    end
    return t
end

---@param set table
---@return integer
-- 計算 set 的元素數目
function core.len_of_set(set)
    local count = 0
    for k, v in pairs(set) do
        count = count + 1
    end
    return count
end

---@param set1 table
---@param set2 table
---@return boolean
-- 判斷第一個 set 是不是第二個 set 的子集
function core.is_subset(set1, set2)
    for k, v in pairs(set1) do
        if not set2[k] then
            return false
        end
    end
    return true
end

---@param text string
---@param set table
---@return boolean
-- 判斷一個字符串的所有字符是不是都在 set 中
function core.string_is_in_set(text, set)
    local set_of_text = core.set_from_str(text)
    return core.is_subset(set_of_text, set)
end

---@param set1 table
---@param set2 table
---@return boolean
-- 判斷第一個 set 中是否包含第二個 set 的元素
function core.is_intersected(set1, set2)
    local len_of_set1 = core.len_of_set(set1)
    -- 首表爲空也算相交
    if len_of_set1 == 0 then
        return true
    end
    for k, v in pairs(set1) do
        if set2[k] then
            return true
        end
    end
    return false
end

core.cjk_blocks = {       -- CJK 區塊(非符號區)
    { 0x4E00, 0x9FFF },   -- 中日韓統一表意文字
    { 0x3400, 0x4DBF },   -- 中日韓統一表意文字擴展區A
    { 0x20000, 0x323AF }, -- 中日韓統一表意文字擴展區B到擴展區H
    { 0x2EBF0, 0x2EE5F }, -- 中日韓統一表意文字擴展區I
    { 0x2E80, 0x2EFF },   -- 中日韓漢字部首補充
    { 0x2F00, 0x2FDF },   -- 康熙部首
    -- 表意文字描述字符 不收
    -- 中日韓符號和標點 不收
    { 0x31C0, 0x31EF }, -- 中日韓筆畫
    -- {0x3200, 0x32FF}, -- 中日韓帶帶圈字符及月份 不收
    -- 中日韓兼容字符 不收
    { 0xF900, 0xFAFF }, -- 中日韓兼容表意文字
    -- 中日韓兼容形式 不收
    -- 帶圈表意文字補充 不收
    { 0x2F800, 0x2FA1F }, -- 中日韓兼容表意文字補充
    { 0xE000, 0xF8FF }    -- 私用區 宇浩字根在此區
}

---@param unicode_of_char integer
---@param unicode_blocks table
---@return boolean
-- 判斷一個字符是不是在一組 Unicode 區位中
function core.char_is_in_unicode_blocks(unicode_of_char, unicode_blocks)
    for i, c in ipairs(unicode_blocks) do
        if (unicode_of_char >= c[1]) and (unicode_of_char <= c[2]) then
            return true
        end
    end
    return false
end

---@param text string
---@param unicode_blocks table
---@return boolean
-- 判斷一個字符串的所有字符是否都在一組 Unicode 區位中
function core.string_is_in_unicode_blocks(text, unicode_blocks)
    for p, unicode_of_char in utf8.codes(text) do
        if not core.char_is_in_unicode_blocks(unicode_of_char, unicode_blocks) then
            return false
        end
    end
    return true
end

---@param text string
---@param charset table
---@return boolean
-- 判斷一個字符串的所有字符都在一個指定集合中,或有一個非 CJK 漢字
function core.string_is_in_charset_or_not_in_cjk(text, charset)
    local is_in_charset = core.string_is_in_set(text, charset)
    local is_in_cjk = core.string_is_in_unicode_blocks(text, core.cjk_blocks)
    return is_in_charset or not is_in_cjk
end

return core
