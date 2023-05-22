-- 将要被返回的過濾器對象
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

-- 讀取 schema.yaml 開關設置:
local option_name = "embeded_cands"
local embeded_cands = nil

function embeded_cands_filter.init(env)
    local handler = function(ctx, name)
        -- 通知回調, 當改變選項值時更新暫存的值
        if name == option_name then
            embeded_cands = ctx:get_option(name)
            if embeded_cands == nil then
                -- 當選項不存在時默認爲啟用狀態
                embeded_cands = true
            end
        end
    end
    -- 初始化爲選項實際值, 如果設置了 reset, 則會再次觸發 handler
    handler(env.engine.context, option_name)
    -- 注册通知回調
    env.engine.context.option_update_notifier:connect(handler)
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
    local page_cands = {}
    -- 暫存索引, 首選和預編輯文本
    local index, first_cand, preedit = 0, nil, ""

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
            first_cand = cand:get_genuine()
        end

        -- 修改首選的預编輯文本, 這会作爲内嵌編碼顯示到輸入處
        if index == 1 then
            -- 首選和編碼
            -- 這裏的if块可以直接改成一個 preedit = preedit..cand.text
            if string.len(cand.text) <= string.len("四個漢字") then
                -- 四字以内, "漢字code"
                preedit = cand.text..first_cand.preedit
            else
                -- 四字以上, "code四字以上詞"
                preedit = first_cand.preedit..cand.text
            end
        elseif index <= page_size then
            -- 當前頁余下候選項, 形如 "2.漢字"
            -- 組合顯示爲 "首選code 2.次選 3.三選 ..."
            preedit = preedit.." "..tostring(index).."."..cand.text
        end

        -- 如果候選有提示且不以 "~" 開頭(补全提示), 識别爲反查提示
        if string.len(cand.comment) ~= 0 and string.sub(cand.comment, 1, 1) ~= "~" then
            if index == 1 then
                -- 首選後額外增加一空格, 以将輸入編碼與反查分隔
                preedit = preedit.." "
            end
            preedit = preedit..cand.comment
        end
        -- 存入首選
        table.insert(page_cands, cand)

        -- 遍歷完一頁候選後, 刷新預編輯文本
        if index == page_size then
            first_cand.preedit = preedit
            -- 将暫存的一頁候選批次送出
            for _, c in ipairs(page_cands) do
                yield(c)
            end
            -- 清空暫存
            first_cand, preedit = nil, ""
            page_cands = {}
        end

        -- 當前候選處理完畢, 查詢下一個
        next = iter(obj)

        -- 如果當前暫存候選不足page_size但没有更多候選, 則需要刷新預編輯並送出
        if not next and index < page_size then
            first_cand.preedit = preedit
            -- 将暫存的前三候選批次送出
            for _, c in ipairs(page_cands) do
                yield(c)
            end
            -- 清空暫存
            first_cand, preedit = nil, ""
            page_cands = {}
        end

        -- 下一頁, index歸零
        index = index % page_size
    end
end

function embeded_cands_filter.fini(env)
end

return embeded_cands_filter
