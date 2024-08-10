
-- 宇浩输入法
yuhao_char_filter = require("yuhao/yuhao_char_filter")
yuhao_char_first = yuhao_char_filter.yuhao_char_first
yuhao_char_only = yuhao_char_filter.yuhao_char_only
yuhao_sc_first = require("yuhao/yuhao_sc_first")
yuhao_tc_first = require("yuhao/yuhao_tc_first")
yuhao_tw_first = require("yuhao/yuhao_tw_first")
yuhao_single_char_only_for_full_code = require("yuhao/yuhao_single_char_only_for_full_code")
yuhao_postpone_full_code = require("yuhao/yuhao_postpone_full_code")
yuhao_autocompletion_filter = require("yuhao/yuhao_autocompletion_filter")
yuhao_helper = require("yuhao/yuhao_helper")
local temp = require("yuhao/yuhao_chaifen")
yuhao_chaifen = temp.filter
yuhao_chaifen_processor = temp.processor