-- Name: yuhao_auto_select.lua
-- 名稱: 自動選擇候選項
-- Version: 20240510
-- Author: 譚淞宸 <https://github.com/tansongchen>
-- Purpose: 對於過長的整句輸入,當字數超過一定數量時,下一擊自動選擇第二候選項.
--          這個插件可使得第一候選項的字數不超過8.
-- 版權聲明：
-- 專爲宇浩輸入法製作 <https://yuhao.forfudan.com>
-- 轉載請保留作者名和出處
-- Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International
-- 版本：
-- 20240510: 當字數超過一定數量時,下一擊自動選擇第二候選項.
---------------------------------------

local this = {}

function this.init(env)
end

local number_of_chars_to_display = 8
local kNoop = 2

---@param key_event KeyEvent
---@param env Env
function this.func(key_event, env)
    local context = env.engine.context
    -- 只接受单个字母键
    if key_event:release() or key_event:alt() or key_event:ctrl() or key_event:shift() or key_event:caps() then
        return kNoop
    end
    if key_event.keycode < ('a'):byte() or key_event.keycode > ('z'):byte() then
        return kNoop
    end
    -- 取出输入中当前正在翻译的一部分
    local segment = context.composition:toSegmentation():back();
    if not segment then
        return kNoop
    end
    local first_candidate = segment:get_candidate_at(0)
    local second_candidate = segment:get_candidate_at(1)
    if not first_candidate or not second_candidate then
        return kNoop
    end
    if utf8.len(first_candidate.text) < number_of_chars_to_display then
        return kNoop
    end
    env.engine:process_key(KeyEvent('2'))
    return kNoop
end

return this
