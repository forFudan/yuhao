-- 將要被返回的過濾器對象
local embeded_cands_filter = {}

--[[
# xxx.schema.yaml
switches:
  - name: embeded_cands
    states: [ 普通, 嵌入 ]
    reset: 1
engine:
  filters:
    - lua_filter@*smyh.embeded_cands
key_binder:
  bindings:
    - { when: always, accept: "Control+Shift+E", toggle: embeded_cands }
--]]

-- 候選序號標記
local index_indicators = {"¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹", "⁰"}

-- 首選/非首選格式定義
-- seq: 候選序號; code: 編碼; 候選: 候選文本; comment: 候選提示
local first_format = "[候選code]comment"
local next_format = "seq候選comment"
local separator = ""

-- 讀取 schema.yaml 開關設置:
local option_name = "embeded_cands"
local embeded_cands = nil

function embeded_cands_filter.init(env)
    local handler = function(ctx, name)
        -- 通知回調, 當改變選項值時更新暫存的值
        if name == option_name then
            embeded_cands = ctx:get_option(name)
            if embeded_cands == nil then
                -- 當選項不存在時默認爲啓用狀態
                embeded_cands = true
            end
        end
    end
    -- 初始化爲選項實際值, 如果設置了 reset, 則會再次觸發 handler
    handler(env.engine.context, option_name)
    -- 注册通知回調
    env.engine.context.option_update_notifier:connect(handler)
end

-- 渲染提示, 因爲提示經常有可能爲空, 抽取爲函數更昜操作
local function render_comment(comment)
    if string.match(comment, "^[ ~]") then
        -- 丟棄以空格和"~"開頭的提示串, 這通常是補全提示
        comment = ""
    elseif string.len(comment) ~= 0 then
        comment = "["..comment.."]"
    end
    return comment
end

-- 渲染單個候選項
local function render_cand(seq, code, text, comment)
    local cand = ""
    -- 選擇渲染格式
    if seq == 1 then
        cand = first_format
    else
        cand = next_format
    end
    -- 渲染提示串
    comment = render_comment(comment)
    cand = string.gsub(cand, "seq", index_indicators[seq])
    cand = string.gsub(cand, "code", code)
    cand = string.gsub(cand, "候選", text)
    cand = string.gsub(cand, "comment", comment)
    return cand
end

-- 過濾器
function embeded_cands_filter.func(input, env)
    if not embeded_cands then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end

    -- 要顯示的候選數量
    local page_size = env.engine.schema.page_size
    -- 暫存當前頁候選, 然后批次送出
    local page_cands, page_rendered = {}, {}
    -- 暫存索引, 首選和預編輯文本
    local index, first_cand, preedit = 0, nil, ""

    local function refresh_preedit()
        first_cand.preedit = table.concat(page_rendered, separator)
        -- 將暫存的一頁候選批次送出
        for _, c in ipairs(page_cands) do
            yield(c)
        end
        -- 清空暫存
        first_cand, preedit = nil, ""
        page_cands, page_rendered = {}, {}
    end

    -- 迭代器
    local iter, obj = input:iter()
    -- 迭代由翻譯器輸入的候選列表
    local next = iter(obj)
    while next do
        -- 頁索引自增, 滿足 1 <= index <= page_size
        index = index + 1
        -- 當前遍歷候選項
        local cand = next

        if index == 1 then
            -- 把首選捉出來
            first_cand = cand
        end

        -- 修改首選的預编輯文本, 這会作爲内嵌編碼顯示到輸入處
        preedit = render_cand(index, first_cand.preedit, cand.text, cand.comment)

        -- 存入候選
        table.insert(page_cands, cand)
        table.insert(page_rendered, preedit)

        -- 遍歷完一頁候選後, 刷新預編輯文本
        if index == page_size then
            refresh_preedit()
        end

        -- 當前候選處理完畢, 查詢下一個
        next = iter(obj)

        -- 如果當前暫存候選不足page_size但没有更多候選, 則需要刷新預編輯並送出
        if not next and index < page_size then
            refresh_preedit()
        end

        -- 下一頁, index歸零
        index = index % page_size
    end
end

function embeded_cands_filter.fini(env)
end

return embeded_cands_filter
