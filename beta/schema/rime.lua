-- rime.lua

-- 宇浩输入法
yuhao_char_filter = require("yuhao/yuhao_char_filter")
yuhao_char_first = yuhao_char_filter.yuhao_char_first
yuhao_char_only = yuhao_char_filter.yuhao_char_only
yuhao_single_char_only_for_full_code = require("yuhao/yuhao_single_char_only_for_full_code")
yuhao_postpone_full_code = require("yuhao/yuhao_postpone_full_code")
yuhao_helper = require("yuhao/yuhao_helper")
local temp = require("yuhao/yuhao_chaifen")
yuhao_chaifen = temp.filter
yuhao_chaifen_processor = temp.processor
yuhao_embeded_cands = require("yuhao.yuhao_embeded_cands")
