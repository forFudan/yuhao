-- yuhao_helper.lua

-- 快捷鍵提示

local function translator(input, seg)
  local table
  if input == 'help' or input == "bang" then
    table = {
      { '只出常用字', 'Ctrl + Shift + O' },
      { '常用字优先', 'Ctrl + Shift + I' },
      { '拆分三重注解', 'Ctrl + Shift + C' },
      { '四码屏蔽词语', 'Ctrl + Shift + D' },
      { '全码后置', 'Ctrl + Shift + H' },
      { '繁体简化', 'Ctrl + Shift + J' },
      { '简体转繁', 'Ctrl + Shift + F' },
      { '宇浩输入法官网', 'https://zhuyuhao.com/yuhao/' },
      { '方案下载', 'https://github.com/forFudan/yuhao' },
      { '上屏注释', 'Ctrl + Shift + Return' },
    }
  else return end
  for k, v in ipairs(table) do
    local cand = Candidate('help', seg.start, seg._end, v[2], ' ' .. v[1])
    cand.preedit = input .. '　〔宇浩帮助〕'
    yield(cand)
  end
end

return translator
