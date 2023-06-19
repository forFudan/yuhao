-- 作者：王牌餅乾
-- https://github.com/lost-melody/
-- 转载请保留作者名
-- Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International
---------------------------------------

local yuhao_switch_proc = {} -- 開關管理-processor
local yuhao_switch_tr   = {} -- 開關管理-translator

-- 導出變量, 可在外部require模块以訪問
local export_vars = {
    is_zhelp = false -- 當前是否在zhelp模式下
}

-- ######## DEFINITION ########

local kRejected = 0 -- 拒: 不作響應, 由操作系統做默認處理
local kAccepted = 1 -- 收: 由rime響應該按鍵
local kNoop     = 2 -- 無: 請下一個processor繼續看

local cSpace  = string.byte(" ") -- 空格鍵
local cReturn = 0xff0d           -- 回車鍵

-- 候選序號標記
local index_indicators = {"¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹", "⁰"}

-- 選項開關列表
local switch_options = {
    -- 這部分是數組區, 寫入所有出現在候選處的開關名
    "ascii_punct", "embeded_cands", "yuhao_single_char_only_for_full_code",
    "traditionalization", "simplification",
    "yuhao_chaifen",
    -- 開關名對應的顯示文本
    ascii_punct = "英符",
    embeded_cands = "嵌入",
    yuhao_single_char_only_for_full_code = "纯单",
    traditionalization = "繁出",
    simplification = "简出",
    -- 單選開關使用嵌套的table描述
    yuhao_chaifen = {
        "yuhao_chaifen.off", "yuhao_chaifen.lv1", "yuhao_chaifen.lv2", "yuhao_chaifen.lv3",
        ["yuhao_chaifen.off"] = "注解关",
        ["yuhao_chaifen.lv1"] = "注解一",
        ["yuhao_chaifen.lv2"] = "注解二",
        ["yuhao_chaifen.lv3"] = "注解三",
    },
}

-- ######## TOOLS ########

-- 返回被選中的候選的索引, 來自 librime-lua/sample 示例
local function select_index(key, env)
    local ch = key.keycode
    local index = -1
    local select_keys = env.engine.schema.select_keys
    if select_keys ~= nil and select_keys ~= "" and not key.ctrl() and ch >= 0x20 and ch < 0x7f then
        local pos = string.find(select_keys, string.char(ch))
        if pos ~= nil then index = pos end
    elseif ch >= 0x30 and ch <= 0x39 then
        index = (ch - 0x30 + 9) % 10
    elseif ch >= 0xffb0 and ch < 0xffb9 then
        index = (ch - 0xffb0 + 9) % 10
    elseif ch == 0x20 then
        index = 0
    end
    return index
end

-- 開關狀態切換
local function toggle_switch(env, ctx, option_name)
    if not option_name then
        return
    end
    local option = switch_options[option_name]
    if type(option) == "string" then
        -- 開關項
        local current_value = ctx:get_option(option_name)
        if current_value ~= nil then
            ctx:set_option(option_name, not current_value)
        end
    elseif type(option) == "table" then
        -- 單選項
        for i, op in ipairs(option) do
            local value = ctx:get_option(op)
            if value then
                -- 關閉當前選項, 開啓下一選項
                ctx:set_option(op, not value)
                ctx:set_option(option[i%#option+1], value)
                break
            end
        end
    end
end

-- 處理開關項調整
local function handle_switch(env, ctx, idx)
    -- 清理預輸入串, 达到調整後複位爲無輸入編碼的效果
    -- ctx:clear()
    toggle_switch(env, ctx, switch_options[idx+1])
    return kAccepted
end

-- 處理開關狀態展示候選
local function handle_switch_display(env, ctx, seg, input)
    local text_list = {}
    for idx, option_name in ipairs(switch_options) do
        local text = ""
        local option = switch_options[option_name]
        if type(option) == "string" then
            -- 開關項, 渲染形如 "■選項¹"
            local current_value = ctx:get_option(option_name)
            if current_value then
                text = text.."■"
            else
                text = text.."□"
            end
            text = text..switch_options[option_name]..index_indicators[idx]
        elseif type(option) == "table" then
            -- 單選項, 渲染形如 "□■□狀態二"
            local state = ""
            for _, op in ipairs(option) do
                local value = ctx:get_option(op)
                if value then
                    text = text.."■"
                    state = option[op]
                else
                    text = text.."□"
                end
            end
            text = text..state..index_indicators[idx]
        end
        table.insert(text_list, text)
    end
    -- 避免選項翻頁, 直接渲染到首選提示中
    local cand = Candidate("switch", seg.start, seg._end, "", table.concat(text_list, " "))
    yield(cand)
end

-- ######## PROCESSOR ########

function yuhao_switch_proc.init(env)
end

function yuhao_switch_proc.func(key_event, env)
    if key_event:release() or key_event:alt() then
        -- 不是我關注的鍵按下事件
        return kNoop
    end

    local ctx = env.engine.context
    if #ctx.input == 0 then
        -- 當前無輸入, 略之
        return kNoop
    end

    local ch = key_event.keycode
    if ctx.input == "zhelp" then
        if ch == 0xff0d then
            ctx:clear()
            return kAccepted
        end
        -- 開關管理
        local idx = select_index(key_event, env)
        if ch == cSpace or ch == cReturn then
            -- 空格或回車退出開關管理模式
            ctx:clear()
            return kAccepted
        elseif idx >= 0 then
            return handle_switch(env, ctx, idx)
        else
            return kNoop
        end
    end

    return kNoop
end

function yuhao_switch_proc.fini(env)
end

-- ######## TRANSLATOR ########

function yuhao_switch_tr.init(env)
end

function yuhao_switch_tr.func(input, seg, env)
    local ctx = env.engine.context
    if input == "zhelp" then
        export_vars.is_zhelp = true
        -- 快捷開關
        handle_switch_display(env, ctx, seg, input)
        return
    else
        export_vars.is_zhelp = false
    end
end

function yuhao_switch_tr.fini(env)
end

-- ######## RETURN ########

return {
    proc = yuhao_switch_proc, -- 開關管理-processor
    tr   = yuhao_switch_tr,   -- 開關管理-translator
    var  = export_vars,       -- 導出本地變量
}
