--[[ Name: yuhao_autocompletion_filter_conditional.lua
名稱: 輸入預測條件開啓
Version: 20240527
Author: forFudan 朱宇浩 <dr.yuhao.zhu@outlook.com>
Github: https://github.com/forFudan/
Purpose: 當編碼長度小於等於四時,關閉輸入預測.
版權聲明：
專爲宇浩輸入法製作 <https://shurufa.app>
轉載請保留作者名和出處
Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International
---------------------------------------
]]

local core = require("yuhao.yuhao_core")

local function filter(input, env)
    local length_of_input = string.len(env.engine.context.input)
    if length_of_input <= 4 then
        for cand in input:iter() do
            if (cand.type == "completion") then
                return
            else
                yield(cand)
            end
        end
    else
        for cand in input:iter() do
            yield(cand)
        end
    end
end

return { func = filter }
