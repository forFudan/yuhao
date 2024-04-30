-- Name: yuhao_autocompletion_filter.lua
-- 名稱: 輸入預測開關
-- Version: 20230901
-- Author: forFudan 朱宇浩 <dr.yuhao.zhu@outlook.com>
-- Github: https://github.com/forFudan/
-- Purpose: 通過開關打開或關閉輸入預測，從而不需要修改 schema.yaml
-- 版權聲明：
-- 專爲宇浩輸入法製作 <https://zhuyuhao.com/yuhao/>
-- 轉載請保留作者名和出處
-- Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International
---------------------------------------

local function filter(input, env)
    local fil = env.engine.context:get_option("yuhao_autocompletion_filter")
    for cand in input:iter() do
        if fil and (cand.type == "completion") then
            return
        else
            yield(cand)
        end
    end
end

return { func = filter }