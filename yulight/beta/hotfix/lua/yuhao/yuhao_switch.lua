-- 作者：王牌餅乾
-- https://github.com/lost-melody/
-- 转载请保留作者名
-- Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International
---------------------------------------

local yuhao_switch_proc = {} -- 開關管理-processor
local yuhao_switch_tr   = {} -- 開關管理-translator

-- ######## DEFINITION ########

local kRejected = 0 -- 拒: 不作響應, 由操作系統做默認處理
local kAccepted = 1 -- 收: 由rime響應該按鍵
local kNoop     = 2 -- 無: 請下一個processor繼續看

-- 宏類型枚舉
local macro_types = {
    tip    = "tip",
    switch = "switch",
    radio  = "radio",
    shell  = "shell",
    eval   = "eval",
}

-- 候選序號標記
local index_indicators = {"¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹", "⁰"}

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

-- 設置開關狀態, 並更新保存的配置值
local function set_option(env, ctx, option_name, value)
    ctx:set_option(option_name, value)
    if env.switcher then
        -- 在支持的情況下, 更新保存的開關狀態
        local swt = env.switcher
        if swt:is_auto_save(option_name) and swt.user_config ~= nil then
            swt.user_config:set_bool("var/option/" .. option_name, value)
        end
    end
end

local _unix_supported
-- 是否支持 Unix 命令
local function unix_supported()
    if _unix_supported == nil then
        local res
        _unix_supported, res = pcall(io.popen, "sleep 0")
        if _unix_supported and res then
            res:close()
        end
    end
    return _unix_supported
end

-- 下文的 new_tip, new_switch, new_radio 等是目前已實現的宏類型
-- 其返回類型統一定義爲:
-- {
--   type = "string",
--   name = "string",
--   display = function(self, ctx) ... end -> string
--   trigger = function(self, ctx) ... end
-- }
-- 其中:
-- type 字段僅起到標識作用
-- name 字段亦非必須
-- display() 爲該宏在候選欄中顯示的效果, 通常 name 非空時直接返回 name 的值
-- trigger() 爲該宏被選中時, 上屏的文本内容, 返回空卽不上屏

---提示語或快捷短語
---顯示爲 name, 上屏爲 text
---@param name string
local function new_tip(name, text)
    local tip = {
        type = macro_types.tip,
        name = name,
        text = text,
    }
    function tip:display(ctx)
        return #self.name ~= 0 and self.name or ""
    end

    function tip:trigger(env, ctx)
        if #text ~= 0 then
            env.engine:commit_text(text)
        end
        ctx:clear()
    end

    return tip
end

---開關
---顯示 name 開關當前的狀態, 並在選中切換狀態
---states 分别指定開關狀態爲 開 和 關 時的顯示效果
---@param name string
---@param states table
local function new_switch(name, states)
    local switch = {
        type = macro_types.switch,
        name = name,
        states = states,
    }
    function switch:display(ctx)
        local state = ""
        local current_value = ctx:get_option(self.name)
        if current_value then
            state = self.states[2]
        else
            state = self.states[1]
        end
        return state
    end

    function switch:trigger(env, ctx)
        local current_value = ctx:get_option(self.name)
        if current_value ~= nil then
            set_option(env, ctx, self.name, not current_value)
        end
    end

    return switch
end

---單選
---顯示一組 names 開關當前的狀態, 並在選中切換關閉當前開啓項, 並打開下一項
---states 指定各組開關的 name 和當前開啓的開關時的顯示效果
---@param states table
local function new_radio(states)
    local radio = {
        type   = macro_types.radio,
        states = states,
    }
    function radio:display(ctx)
        local state = ""
        for _, op in ipairs(self.states) do
            local value = ctx:get_option(op.name)
            if value then
                state = op.display
                break
            end
        end
        return state
    end

    function radio:trigger(env, ctx)
        for i, op in ipairs(self.states) do
            local value = ctx:get_option(op.name)
            if value then
                -- 關閉當前選項, 開啓下一選項
                set_option(env, ctx, op.name, not value)
                set_option(env, ctx, self.states[i % #self.states + 1].name, value)
                return
            end
        end
        -- 全都没開, 那就開一下第一個吧
        set_option(env, ctx, self.states[1].name, true)
    end

    return radio
end

---Shell 命令, 僅支持 Linux/Mac 系統, 其他平臺可通過下文提供的 eval 宏自行擴展
---name 非空時顯示其值, 爲空则顯示實時的 cmd 執行結果
---cmd 爲待執行的命令内容
---text 爲 true 時, 命令執行結果上屏, 否则僅執行
---@param name string
---@param cmd string
---@param text boolean
local function new_shell(name, cmd, text)
    if not unix_supported() then
        return nil
    end

    local template = "__macrowrapper() { %s ; }; __macrowrapper %s <<<''"
    local function get_fd(args)
        local cmdargs = {}
        for _, arg in ipairs(args) do
            table.insert(cmdargs, '"' .. arg .. '"')
        end
        return io.popen(string.format(template, cmd, table.concat(cmdargs, " ")), 'r')
    end

    local shell = {
        type = macro_types.tip,
        name = name,
        text = text,
    }

    function shell:display(ctx, args)
        return #self.name ~= 0 and self.name or self.text and get_fd(args):read('a')
    end

    function shell:trigger(env, ctx, args)
        local fd = get_fd(args)
        if self.text then
            local t = fd:read('a')
            fd:close()
            if #t ~= 0 then
                env.engine:commit_text(t)
            end
        end
        ctx:clear()
    end

    return shell
end

---Evaluate 宏, 執行給定的 lua 表達式
---name 非空時顯示其值, 否则顯示實時調用結果
---expr 必須 return 一個值, 其類型可以是 string, function 或 table
---返回 function 時, 該 function 接受一個 table 參數, 返回 string
---返回 table 時, 該 table 成員方法 peek 和 eval 接受 self 和 table 參數, 返回 string, 分别指定顯示效果和上屏文本
---@param name string
---@param expr string
local function new_eval(name, expr)
    local f = load(expr)
    if not f then
        return nil
    end

    local eval = {
        type = macro_types.eval,
        name = name,
        expr = f,
    }

    function eval:get_text(args, getter)
        if type(self.expr) == "function" then
            local res = self.expr(args)
            if type(res) == "string" then
                return res
            elseif type(res) == "function" or type(res) == "table" then
                self.expr = res
            else
                return ""
            end
        end

        local res
        if type(self.expr) == "function" then
            res = self.expr(args)
        elseif type(self.expr) == "table" then
            local get_text = self.expr[getter]
            res = type(get_text) == "function" and get_text(self.expr, args) or nil
        end
        return type(res) == "string" and res or ""
    end

    function eval:display(ctx, args)
        if #self.name ~= 0 then
            return self.name
        else
            local _, res = pcall(self.get_text, self, args, "peek")
            return res
        end
    end

    function eval:trigger(env, ctx, args)
        local ok, res = pcall(self.get_text, self, args, "eval")
        if ok and #res ~= 0 then
            env.engine:commit_text(res)
        end
        ctx:clear()
    end

    return eval
end

---@param input string
---@param keylist table
local function get_macro_args(input, keylist)
    local sepset = ""
    for key in pairs(keylist) do
        -- only ascii keys
        sepset = key >= 0x20 and key <= 0x7f and sepset .. string.char(key) or sepset
    end
    -- matches "[^/]"
    local pattern = "[^" .. (#sepset ~= 0 and sepset or " ") .. "]*"
    local args = {}
    -- "echo/hello/world" -> "/hello", "/world"
    for str in string.gmatch(input, "/" .. pattern) do
        table.insert(args, string.sub(str, 2))
    end
    -- "echo/hello/world" -> "echo"
    return string.match(input, pattern) or "", args
end

-- 從方案配置中讀取宏配置
local function parse_conf_macro_list(env)
    local macros = {}
    local macro_map = env.engine.schema.config:get_map(env.name_space .. "/macros")
    -- macros:
    for _, key in ipairs(macro_map and macro_map:keys() or {}) do
        local cands = {}
        local cand_list = macro_map:get(key):get_list() or { size = 0 }
        -- macros/help:
        for i = 0, cand_list.size - 1 do
            local key_map = cand_list:get_at(i):get_map()
            -- macros/help[1]/type:
            local type = key_map and key_map:has_key("type") and key_map:get_value("type"):get_string() or ""
            if type == macro_types.tip then
                -- {type: tip, name: foo}
                if key_map:has_key("name") or key_map:has_key("text") then
                    local name = key_map:has_key("name") and key_map:get_value("name"):get_string() or ""
                    local text = key_map:has_key("text") and key_map:get_value("text"):get_string() or ""
                    table.insert(cands, new_tip(name, text))
                end
            elseif type == macro_types.switch then
                -- {type: switch, name: single_char, states: []}
                if key_map:has_key("name") and key_map:has_key("states") then
                    local name = key_map:get_value("name"):get_string()
                    local states = {}
                    local state_list = key_map:get("states"):get_list() or { size = 0 }
                    for idx = 0, state_list.size - 1 do
                        table.insert(states, state_list:get_value_at(idx):get_string())
                    end
                    if #name ~= 0 and #states > 1 then
                        table.insert(cands, new_switch(name, states))
                    end
                end
            elseif type == macro_types.radio then
                -- {type: radio, names: [], states: []}
                if key_map:has_key("names") and key_map:has_key("states") then
                    local names, states = {}, {}
                    local name_list = key_map:get("names"):get_list() or { size = 0 }
                    for idx = 0, name_list.size - 1 do
                        table.insert(names, name_list:get_value_at(idx):get_string())
                    end
                    local state_list = key_map:get("states"):get_list() or { size = 0 }
                    for idx = 0, state_list.size - 1 do
                        table.insert(states, state_list:get_value_at(idx):get_string())
                    end
                    if #names > 1 and #names == #states then
                        local radio = {}
                        for idx, name in ipairs(names) do
                            if #name ~= 0 and #states[idx] ~= 0 then
                                table.insert(radio, { name = name, display = states[idx] })
                            end
                        end
                        table.insert(cands, new_radio(radio))
                    end
                end
            elseif type == macro_types.shell then
                -- {type: shell, name: foo, cmd: "echo hello"}
                if key_map:has_key("cmd") and (key_map:has_key("name") or key_map:has_key("text")) then
                    local cmd = key_map:get_value("cmd"):get_string()
                    local name = key_map:has_key("name") and key_map:get_value("name"):get_string() or ""
                    local text = key_map:has_key("text") and key_map:get_value("text"):get_bool() or false
                    local hijack = key_map:has_key("hijack") and key_map:get_value("hijack"):get_bool() or false
                    if #cmd ~= 0 and (#name ~= 0 or text) then
                        table.insert(cands, new_shell(name, cmd, text))
                        cands.hijack = cands.hijack or hijack
                    end
                end
            elseif type == macro_types.eval then
                -- {type: eval, name: foo, expr: "os.date()"}
                if key_map:has_key("expr") then
                    local name = key_map:has_key("name") and key_map:get_value("name"):get_string() or ""
                    local expr = key_map:get_value("expr"):get_string()
                    local hijack = key_map:has_key("hijack") and key_map:get_value("hijack"):get_bool() or false
                    if #expr ~= 0 then
                        table.insert(cands, new_eval(name, expr))
                        cands.hijack = cands.hijack or hijack
                    end
                end
            end
        end
        if #cands ~= 0 then
            macros[key] = cands
        end
    end
    return macros
end

-- 從方案配置中讀取功能鍵配置
local function parse_conf_funckeys(env)
    local funckeys = {
        macro = {},
    }
    local keys_map = env.engine.schema.config:get_map(env.name_space .. "/funckeys")
    for _, key in ipairs(keys_map and keys_map:keys() or {}) do
        if funckeys[key] then
            local char_list = keys_map:get(key):get_list() or { size = 0 }
            for i = 0, char_list.size - 1 do
                funckeys[key][char_list:get_value_at(i):get_int() or 0] = true
            end
        end
    end
    return funckeys
end

-- 按命名空間歸類方案配置, 而不是按会話, 以减少内存佔用
local namespaces = {}
function namespaces:init(env)
    -- 讀取配置項
    if not namespaces:config(env) then
        local config = {}
        config.macros = parse_conf_macro_list(env)
        config.funckeys = parse_conf_funckeys(env)
        namespaces:set_config(env, config)
    end
end
function namespaces:set_config(env, config)
    namespaces[env.name_space] = namespaces[env.name_space] or {}
    namespaces[env.name_space].config = config
end
function namespaces:config(env)
    return namespaces[env.name_space] and namespaces[env.name_space].config
end

-- ######## PROCESSOR ########

local function proc_handle_macros(env, ctx, macro, args, idx)
    if macro then
        if macro[idx] then
            macro[idx]:trigger(env, ctx, args)
        end
        return kAccepted
    end
    return kNoop
end

function yuhao_switch_proc.init(env)
    if Switcher then
        env.switcher = Switcher(env.engine)
    end

    -- 讀取配置項
    local ok = pcall(namespaces.init, namespaces, env)
    if not ok then
        local config = {}
        config.macros = {}
        config.funckeys = {}
        namespaces:set_config(env, config)
    end
end

function yuhao_switch_proc.func(key_event, env)
    local ctx = env.engine.context
    if #ctx.input == 0 or key_event:release() or key_event:alt() then
        -- 當前無輸入, 或不是我關注的鍵按下事件, 棄之
        return kNoop
    end

    local ch = key_event.keycode
    local funckeys = namespaces:config(env).funckeys
    if funckeys.macro[string.byte(string.sub(ctx.input, 1, 1))] then
        -- 當前輸入串以 funckeys/macro 定義的鍵集合開頭
        local name, args = get_macro_args(string.sub(ctx.input, 2), namespaces:config(env).funckeys.macro)
        local macro = namespaces:config(env).macros[name]
        if macro then
            if macro.hijack and ch > 0x20 and ch < 0x7f then
                ctx:push_input(string.char(ch))
                return kAccepted
            else
                local idx = select_index(key_event, env)
                if idx >= 0 then
                    return proc_handle_macros(env, ctx, macro, args, idx + 1)
                end
            end
            return kNoop
        end
    end

    return kNoop
end

function yuhao_switch_proc.fini(env)
end

-- ######## TRANSLATOR ########

-- 處理宏
local function tr_handle_macros(env, ctx, seg, input)
    local name, args = get_macro_args(input, namespaces:config(env).funckeys.macro)
    local macro = namespaces:config(env).macros[name]
    if macro then
        local text_list = {}
        for i, m in ipairs(macro) do
            table.insert(text_list, m:display(ctx, args) .. index_indicators[i])
        end
        local cand = Candidate("macro", seg.start, seg._end, "", table.concat(text_list, " "))
        yield(cand)
    end
end

function yuhao_switch_tr.init(env)
    -- 讀取配置項
    local ok = pcall(namespaces.init, namespaces, env)
    if not ok then
        local config = {}
        config.macros = {}
        config.funckeys = {}
        namespaces:set_config(env, config)
    end
end

function yuhao_switch_tr.func(input, seg, env)
    local ctx = env.engine.context
    local funckeys = namespaces:config(env).funckeys
    if funckeys.macro[string.byte(string.sub(ctx.input, 1, 1))] then
        tr_handle_macros(env, ctx, seg, string.sub(input, 2))
        return
    end
end

function yuhao_switch_tr.fini(env)
end

-- ######## RETURN ########

return {
    proc = yuhao_switch_proc, -- 開關管理-processor
    tr   = yuhao_switch_tr,   -- 開關管理-translator
}
