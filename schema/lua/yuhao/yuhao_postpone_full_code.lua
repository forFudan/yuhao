-- 名稱: yuhao_postpone_full_code.lua
-- 原作者: Ace-Who <https://github.com/Ace-Who/rime-xuma/>
-- 原代碼介紹：
-- 出现重码时，将全码匹配且有简码的「单字」「适当」后置。
-- 目前的实现方式，原理适用于所有使用规则简码的形码方案。

-- 修改: forFudan
-- 版本: 20230103
-- 修改介紹：
-- 根據宇浩輸入法更新字根列表。

local radstr = "卩𰆊厶马乃爿水氺丱𠂈丩凵䶹屮糹糸幺廴也飛艮⺄乙了𠄏矛乛亅𠃌㇕𠄎𠃍𠃎乁㇅㇍⺕㇇⼅⺂乜㔾⺋⼹彐㇈阝予𠄔子巛习纟力母巜𠃉𠄌𠃑𠃊乚㇞𠃋㇉㇂Γ㇜女小𡭔羽巴刀弓已己又皮巳𠃜コスマ龴癶𫝀⼫尸韋髟镸丁二𠄞𠄟𠄠甫干丂馬十龶𤣩⺩王西覀酉長车大臣匚匸戈弋𫠠七⺬示キヰ㐄𰀁𠥓𡗗扌戊牙至不厂歹而面辰豕㇀一丆石兀兀頁耳革丌其世龷𠂇廾⼶艹卝卌卄卅瓦寸丰工來末三朩𬺰木未車爾夫古尤犬丅士耂土雨⻗走电甲禺申田⼁丨𫩏曰日由早卜齒刂非虍鹵攴上〢龰⺊〣虫止贝黑巾皿𠕁冂冊⼌山罒貝鬥⾻骨見門且𣥂咼冎⺌目囗㗊〇㇣黽丄口𧾷⻊长缶矢钅牛牜攵气生𠂉𠂒丿⼃⺧㇒⺮𥫗凡𠁽風饣𠘧𠘨几欠殳⺈冖𠂊魚夕鱼瓜戶九毛舟千壬𡈼龵手⺁𠂆𧘇𧰨𥝌禾心夭爪鸟彳彡𰀪⼓⺆𱼀勹⺝⺼月乌行用鼻川乂㐅片身𨈐八亻隹自白𠂤鬼臼⾅鳥僉鼠人𠆢𦥑𰃦忄烏比儿匕𠤎犭入⻞⻟食飠𩙿爫𫶧夊⺥⼢夂金釒豸疒广衤鹿麻礻㇏乀丶⼂㇝宀穴衣灬米冫䒑丷ソ丬火為⺶羊亥亦𰁜立音亠方訁言文辛⻍⻎辶户门⺀⺍𠁼氵讠之"

local function init(env)
    local config = env.engine.schema.config
    local code_rvdb = config:get_string('schema_name/code')
    env.code_rvdb = ReverseDb('build/' .. code_rvdb .. '.reverse.bin')
    env.his_inp = config:get_string('history/input')
    env.delimiter = config:get_string('speller/delimiter')
    env.max_index = config:get_int('yuhao_postpone_full_code/lua/max_index')
        or 4
end

local function get_short(codestr)
    local s = ' ' .. codestr
    for code in s:gmatch('%l+') do
        if s:find(' ' .. code .. '%l+') then
            return code
        end
    end
end

local function has_short_and_is_full(cand, env)
    -- completion 和 sentence 类型不属于精确匹配，但要通过 cand:get_genuine() 判
    -- 断，因为 simplifier 会覆盖类型为 simplified。先行判断 type 并非必要，只是
    -- 为了轻微的性能优势。
    local cand_gen = cand:get_genuine()
    if cand_gen.type == 'completion' or cand_gen.type == 'sentence' then
        return false, true
    end
    local input = env.engine.context.input
    local cand_input = input:sub(cand.start + 1, cand._end)
    -- 去掉可能含有的 delimiter。
    cand_input = cand_input:gsub('[' .. env.delimiter .. ']', '')
    -- 字根可能设置了特殊扩展码，不视作全码，不予后置。
    if cand_input:len() > 2 and radstr:find(cand_gen.text, 1, true) then
        return
    end
    -- history_translator 不后置。
    if cand_input == env.his_inp then return end
    local codestr = env.code_rvdb:lookup(cand_gen.text)
    local is_comp = not
        string.find(' ' .. codestr .. ' ', ' ' .. cand_input .. ' ', 1, true)
    local short = not is_comp and get_short(codestr)
    -- 注意排除有简码但是输入的是不规则编码的情况
    return short and cand_input:find('^' .. short .. '%l+'), is_comp
end

local function filter(input, env)
    local context = env.engine.context
    if not context:get_option("yuhao_postpone_full_code") then
        for cand in input:iter() do yield(cand) end
    else
        -- 具体实现不是后置目标候选，而是前置非目标候选
        local dropped_cands = {}
        local done_drop
        local pos = 1
        -- Todo: 计算 pos 时考虑可能存在的重复候选被 uniquifier 合并的情况。
        for cand in input:iter() do
            if done_drop then
                yield(cand)
            else
                -- 后置不越过 env.max_index 和以下几类候选：
                -- 1) 顶功方案使用 script_translator 导致的匹配部分输入的候选，例如输入
                -- otu 且光标在 u 后时会出现编码为 ot 的候选。不过通过填满码表的三码和
                -- 四码的位置，能消除这类候选。2) 顶功方案的造词翻译器允许出现的
                -- completion 类型候选。3) 顶功方案的补空候选——全角空格（ U+3000）。
                local is_bad_script_cand = cand._end < context.caret_pos
                local drop, is_comp = has_short_and_is_full(cand, env)
                if pos >= env.max_index
                    or is_bad_script_cand or is_comp or cand.text == '　' then
                    for i, cand in ipairs(dropped_cands) do yield(cand) end
                    done_drop = true
                    yield(cand)
                    -- 精确匹配的词组不予后置
                elseif not drop or utf8.len(cand.text) > 1 then
                    yield(cand)
                    pos = pos + 1
                else table.insert(dropped_cands, cand)
                end
            end
        end
        for i, cand in ipairs(dropped_cands) do yield(cand) end
    end
end

return { init = init, func = filter }