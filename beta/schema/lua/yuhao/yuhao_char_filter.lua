-- Name: yuhao_char_filter.lua
-- 名称: 常用繁簡字符過濾或前置
-- Version: 20240107
-- Author: 朱宇浩 (forFudan) <dr.yuhao.zhu@outlook.com>
-- Github: https://github.com/forFudan/
-- Purpose: 從候選項中過濾出常用繁簡漢字
-- 版權聲明：
-- 專爲宇浩輸入法製作 <https://yuhao.forfudan.com>
-- 轉載請保留作者名和出處
-- Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International
---------------------------------------
--
-- 介紹:
-- 字符過濾 charaset_filter 在鼠鬚管中不再有效,因爲 librime-charcode 被單獨出来作爲插件.
-- 所以我寫了這箇 lua 腳本過濾常用繁簡體字 (通规一二級 + 國字常用字 + 部分古籍通规字).
-- 爲了允许標點符号，我把它们加入了字符集中.
-- 用户可以在 str 變量加入自己想包括的字符.
--
-- 功能:
-- (1) yuhao_char_only: 過濾常用字符,且不顯示其他字符.
-- (2) yuhao_char_first: 将常用字符前置. 原因:在某些形碼碼表中,全碼單字(生僻)會優先於全碼詞語(常用),開啓後可將全碼詞調整到生僻字前面.
--
-- Description:
-- The charaset_filter is not enabled in the Squirrel as librime-charcode was exclused as a standalone plug-in.
-- So a lua filter would be helpful to filter the frequently used characters (GB2312 + 常用國字標準字體表 + other characters).
--
-- 使用方法:
-- (1) 需要將此 lua 文件放在 lua 文件夾下
-- (2) 需要在 rime.lua 中添加以下代碼激活本腳本:
-- yuhao_char_filter = require("yuhao_char_filter")
-- yuhao_char_first = yuhao_char_filter.yuhao_char_first
-- yuhao_char_only = yuhao_char_filter.yuhao_char_only
-- (3) 需要在 switches 添加狀態:
-- - options: [yuhao_char_only, yuhao_char_first, utf8]
-- states: [常用字過濾, 常用字前置, UTF-8]
-- reset: 1
-- (4) 需要在 engine/filters 添加:
-- - lua_filter@yuhao_char_first
-- - lua_filter@yuhao_char_only
--
-- 版本：
-- 20221001: 使用遍歷法寫成.
-- 20230418: 使用集合法重寫代碼,大幅度提升運行效率,不再有卡頓現象.
-- 20240107: 更改判斷邏輯.詞語中只要有一個字符在常用字符集内,則提高詞語的整體優先級.
--           此前,詞語中的所有字符都必須在常用字符集内纔會優先.
-- 20240407: 只判斷長度爲 1 到 10 的候選項.

---------------------------

local str =
"一乙二十丁厂七卜八人入儿匕几九刁了刀力乃又三干于亏工土士才下寸大丈与万上小口山巾千乞川亿个夕久么勺凡丸及广亡门丫义之尸己已巳弓子卫也女刃飞习叉马乡丰王开井天夫元无云专丐扎艺木五支厅不犬太区历歹友尤匹车巨牙屯戈比互切瓦止少曰日中贝冈内水见午牛手气毛壬升夭长仁什片仆化仇币仍仅斤爪反介父从仑今凶分乏公仓月氏勿欠风丹匀乌勾凤六文亢方火为斗忆计订户认冗讥心尺引丑巴孔队办以允予邓劝双书幻玉刊未末示击打巧正扑卉扒功扔去甘世艾古节本术可丙左厉石右布夯戊龙平灭轧东卡北占凸卢业旧帅归旦目且叶甲申叮电号田由只叭史央兄叽叼叫叩叨另叹冉皿凹囚四生矢失乍禾丘付仗代仙们仪白仔他斥瓜乎丛令用甩印尔乐句匆册卯犯外处冬鸟务包饥主市立冯玄闪兰半汁汇头汉宁穴它讨写让礼训议必讯记永司尼民弗弘出辽奶奴召加皮边孕发圣对台矛纠母幼丝邦式迂刑戎动扛寺吉扣考托老巩圾执扩扫地场扬耳芋共芒亚芝朽朴机权过臣吏再协西压厌戌在百有存而页匠夸夺灰达列死成夹夷轨邪尧划迈毕至此贞师尘尖劣光当早吁吐吓虫曲团吕同吊吃因吸吗吆屿屹岁帆回岂则刚网肉年朱先丢廷舌竹迁乔迄伟传乒乓休伍伏优臼伐延仲件任伤价伦份华仰仿伙伪自伊血向似后行舟全会杀合兆企众爷伞创肌肋朵杂危旬旨旭负匈名各多争色壮冲妆冰庄庆亦刘齐交衣次产决亥充妄闭问闯羊并关米灯州汗污江汛池汝汤忙兴宇守宅字安讲讳军讶许讹论讼农讽设访诀寻那迅尽导异弛孙阵阳收阶阴防奸如妇妃好她妈戏羽观欢买红驮纤驯约级纪驰纫巡寿弄麦玖玛形进戒吞远违韧运扶抚坛技坏抠扰扼拒找批址扯走抄贡汞坝攻赤折抓扳抡扮抢孝坎均抑抛投坟坑抗坊抖护壳志块扭声把报拟却抒劫芙芜苇芽花芹芥芬苍芳严芦芯劳克芭苏杆杠杜材村杖杏杉巫极李杨求甫匣更束吾豆两酉丽医辰励否还尬歼来连轩步卤坚肖旱盯呈时吴助县里呆吱吠呕园旷围呀吨足邮男困吵串员呐听吟吩呛吻吹呜吭吧邑吼囤别吮岖岗帐财针钉牡告我乱利秃秀私每兵估体何佐佑但伸佃作伯伶佣低你住位伴身皂伺佛囱近彻役返余希坐谷妥含邻岔肝肛肚肘肠龟甸免狂犹狈角删条彤卵灸岛刨迎饭饮系言冻状亩况床库庇疗吝应这冷庐序辛弃冶忘闰闲间闷判兑灶灿灼弟汪沐沛汰沥沙汽沃沦汹泛沧没沟沪沈沉沁怀忧忱快完宋宏牢究穷灾良证启评补初社祀识诈诉罕诊词译君灵即层屁尿尾迟局改张忌际陆阿陈阻附坠妓妙妖姊妨妒努忍劲矣鸡纬驱纯纱纲纳驳纵纷纸纹纺驴纽奉玩环武青责现玫表规抹卦坷坯拓拢拔坪拣坦担坤押抽拐拖者拍顶拆拎拥抵拘势抱拄垃拉拦幸拌拧拂拙招坡披拨择抬拇拗其取茉苦昔苛若茂苹苗英苟苑苞范直茁茄茎苔茅枉林枝杯枢柜枚析板松枪枫构杭杰述枕丧或画卧事刺枣雨卖郁矾矿码厕奈奔奇奋态欧殴垄妻轰顷转斩轮软到非叔歧肯齿些卓虎虏肾贤尚旺具味果昆国哎咕昌呵畅明易咙昂迪典固忠呻咒咋咐呼鸣咏呢咄咖岸岩帖罗帜帕岭凯败账贩贬购贮图钓制知迭氛垂牧物乖刮秆和季委秉佳侍岳供使例侠侥版侄侦侣侧凭侨佩货侈依卑的迫质欣征往爬彼径所舍金刹命肴斧爸采觅受乳贪念贫忿肤肺肢肿胀朋股肮肪肥服胁周昏鱼兔狐忽狗狞备饰饱饲变京享庞店夜庙府底疟疙疚剂卒郊庚废净盲放刻育氓闸闹郑券卷单炬炒炊炕炎炉沫浅法泄沽河沾泪沮油泊沿泡注泣泞泻泌泳泥沸沼波泼泽治怔怯怖性怕怜怪怡学宝宗定宠宜审宙官空帘宛实试郎诗肩房诚衬衫视祈话诞诡询该详建肃录隶帚屉居届刷屈弧弥弦承孟陋陌孤陕降函限妹姑姐姓妮始姆迢驾叁参艰线练组绅细驶织驹终驻绊驼绍绎经贯契贰奏春帮玷珍玲珊玻毒型拭挂封持拷拱项垮挎城挟挠政赴赵挡拽哉挺括垢拴拾挑垛指垫挣挤拼挖按挥挪拯某甚荆茸革茬荐巷带草茧茵茶荒茫荡荣荤荧故胡荫荔南药标栈柑枯柄栋相查柏栅柳柱柿栏柠树勃要柬咸威歪研砖厘厚砌砂泵砚砍面耐耍牵鸥残殃轴轻鸦皆韭背战点虐临览竖省削尝昧盹是盼眨哇哄哑显冒映星昨咧昭畏趴胃贵界虹虾蚁思蚂虽品咽骂勋哗咱响哈哆咬咳咪哪哟炭峡罚贱贴贻骨幽钙钝钞钟钢钠钥钦钧钩钮卸缸拜看矩毡氢怎牲选适秒香种秋科重复竿段便俩贷顺修俏保促俄俐侮俭俗俘信皇泉鬼侵禹侯追俊盾待徊衍律很须叙剑逃食盆胚胧胆胜胞胖脉胎勉狭狮独狰狡狱狠贸怨急饵饶蚀饺饼峦弯将奖哀亭亮度迹庭疮疯疫疤咨姿亲音帝施闺闻闽阀阁差养美姜叛送类迷籽娄前首逆兹总炼炸烁炮炫烂剃洼洁洪洒柒浇浊洞测洗活派洽染洛浏济洋洲浑浓津恃恒恢恍恬恤恰恼恨举觉宣宦室宫宪突穿窃客诫冠诬语扁袄祖神祝祠误诱诲说诵垦退既屋昼屏屎费陡逊眉孩陨除险院娃姥姨姻娇姚娜怒架贺盈勇怠癸蚤柔垒绑绒结绕骄绘给绚骆络绝绞骇统耕耘耗耙艳泰秦珠班素匿蚕顽盏匪捞栽捕埂捂振载赶起盐捎捍捏埋捉捆捐损袁捌都哲逝捡挫换挽挚热恐捣壶捅埃挨耻耿耽聂恭莽莱莲莫莉荷获晋恶莹莺真框梆桂桔栖档桐株桥桦栓桃格桩校核样根索哥速逗栗贾酌配翅辱唇夏砸砰砾础破原套逐烈殊殉顾轿较顿毙致柴桌虑监紧党逞晒眠晓哮唠鸭晃哺晌剔晕蚌畔蚣蚊蚪蚓哨哩圃哭哦恩鸯唤唁哼唧啊唉唆罢峭峨峰圆峻贼贿赂赃钱钳钻钾铁铃铅缺氧氨特牺造乘敌秤租积秧秩称秘透笔笑笋债借值倚俺倾倒倘俱倡候赁俯倍倦健臭射躬息倔徒徐殷舰舱般航途拿耸爹舀爱豺豹颁颂翁胰脆脂胸胳脏脐胶脑脓逛狸狼卿逢鸵留鸳皱饿馁凌凄恋桨浆衰衷高郭席准座症病疾斋疹疼疲脊效离紊唐瓷资凉站剖竞部旁旅畜阅羞羔瓶拳粉料益兼烤烘烦烧烛烟烙递涛浙涝浦酒涉消涡浩海涂浴浮涣涤流润涧涕浪浸涨烫涩涌悖悟悄悍悔悯悦害宽家宵宴宾窍窄容宰案请朗诸诺读扇诽袜袖袍被祥课冥谁调冤谅谆谈谊剥恳展剧屑弱陵祟陶陷陪娱娟恕娥娘通能难预桑绢绣验继骏球琐理琉琅捧堵措描域捺掩捷排焉掉捶赦堆推埠掀授捻教掏掐掠掂培接掷控探据掘掺职基聆勘聊娶著菱勒黄菲萌萝菌萎菜萄菊菩萍菠萤营乾萧萨菇械彬梦婪梗梧梢梅检梳梯桶梭救曹副票酝酗厢戚硅硕奢盔爽聋袭盛匾雪辅辆颅虚彪雀堂常眶匙晨睁眯眼悬野啪啦曼晦晚啄啡距趾啃跃略蚯蛀蛇唬累鄂唱患啰唾唯啤啥啸崖崎崭逻崔帷崩崇崛婴圈铐铛铝铜铭铲银矫甜秸梨犁秽移笨笼笛笙符第敏做袋悠偿偶偎偷您售停偏躯兜假衅徘徙得衔盘舶船舵斜盒鸽敛悉欲彩领脚脖脯豚脸脱象够逸猜猪猎猫凰猖猛祭馅馆凑减毫烹庶麻庵痊痒痕廊康庸鹿盗章竟商族旋望率阎阐着羚盖眷粘粗粒断剪兽焊焕清添鸿淋涯淹渠渐淑淌混淮淆渊淫渔淘淳液淤淡淀深涮涵婆梁渗情惜惭悼惧惕惟惊惦悴惋惨惯寇寅寄寂宿窒窑密谋谍谎谐袱祷祸谓谚谜逮敢尉屠弹隋堕随蛋隅隆隐婚婶婉颇颈绩绪续骑绰绳维绵绷绸综绽绿缀巢琴琳琢琼斑替揍款堪塔搭堰揩越趁趋超揽堤提博揭喜彭揣插揪搜煮援搀裁搁搓搂搅壹握搔揉斯期欺联葫散惹葬募葛董葡敬葱蒋蒂落韩朝辜葵棒棱棋椰植森焚椅椒棵棍椎棉棚棕棺榔椭惠惑逼粟棘酣酥厨厦硬硝确硫雁殖裂雄颊雳暂雅翘辈悲紫凿辉敞棠赏掌晴睐暑最晰量鼎喷喳晶喇遇喊遏晾景畴践跋跌跑跛遗蛙蛛蜓蜒蛤喝鹃喂喘喉喻啼喧嵌幅帽赋赌赎赐赔黑铸铺链销锁锄锅锈锋锌锐甥掰短智氮毯氯鹅剩稍程稀税筐等筑策筛筒筏答筋筝傲傅牌堡集焦傍储皓皖粤奥街惩御循艇舒逾番释禽腊脾腋腔腕鲁猩猬猾猴惫然馈馋装蛮就敦斌痘痢痪痛童竣阔善翔羡普粪尊奠道遂曾焰港滞湖湘渣渤渺湿温渴溃溅滑湃渝湾渡游滋渲溉愤慌惰愕愣惶愧愉慨割寒富寓窜窝窖窗窘遍雇裕裤裙禅禄谢谣谤谦犀属屡强粥疏隔隙隘媒絮嫂媚婿登缅缆缉缎缓缔缕骗编骚缘瑟鹉瑞瑰瑙魂肆摄摸填搏塌鼓摆携搬摇搞塘摊聘斟蒜勤靴靶鹊蓝墓幕蓬蓄蒲蓉蒙蒸献椿禁楚楷榄想槐榆楼概赖酪酬感碍碘碑碎碰碗碌尴雷零雾雹辐辑输督频龄鉴睛睹睦瞄睫睡睬嗜鄙嗦愚暖盟歇暗暇照畸跨跷跳跺跪路跤跟遣蜈蜗蛾蜂蜕嗅嗡嗓署置罪罩蜀幌错锚锡锣锤锥锦键锯锰矮辞稚稠颓愁筹签简筷毁舅鼠催傻像躲魁衙微愈遥腻腰腥腮腹腺鹏腾腿鲍猿颖触解煞雏馍馏酱禀痹廓痴痰廉靖新韵意誊粮数煎塑慈煤煌满漠滇源滤滥滔溪溜漓滚溢溯滨溶溺粱滩慎誉塞寞窥窟寝谨褂裸福谬群殿辟障媳嫉嫌嫁叠缚缝缠缤剿静碧璃赘熬墙墟嘉摧赫截誓境摘摔撇聚慕暮摹蔓蔑蔡蔗蔽蔼熙蔚兢模槛榴榜榨榕歌遭酵酷酿酸碟碱碳磁愿需辖辗雌裳颗瞅墅嗽踊蜻蜡蝇蜘蝉嘛嘀赚锹锻镀舞舔稳熏箕算箩管箫舆僚僧鼻魄魅貌膜膊膀鲜疑孵馒裹敲豪膏遮腐瘩瘟瘦辣彰竭端旗精粹歉弊熄熔煽潇漆漱漂漫滴漾演漏慢慷寨赛寡察蜜寥谭肇褐褪谱隧嫩翠熊凳骡缩慧撵撕撒撩趣趟撑撮撬播擒墩撞撤增撰聪鞋鞍蕉蕊蔬蕴横槽樱橡樟橄敷豌飘醋醇醉磕磊磅碾震霄霉瞒题暴瞎嘻嘶嘲嘹影踢踏踩踪蝶蝴蝠蝎蝌蝗蝙嘿嘱幢墨镇镐镑靠稽稻黎稿稼箱篓箭篇僵躺僻德艘膝膛鲤鲫熟摩褒瘪瘤瘫凛颜毅糊遵憋潜澎潮潭鲨澳潘澈澜澄懂憔懊憎额翩褥谴鹤憨慰劈履豫缭撼擂操擅燕蕾薯薛薇擎薪薄颠翰噩橱橙橘整融瓢醒霍霎辙冀餐嘴踱蹄蹂蟆螃器噪鹦赠默黔镜赞穆篮篡篷篱儒邀衡膨雕鲸磨瘾瘸凝辨辩糙糖糕燃濒澡激懒憾懈窿壁避缰缴戴擦藉鞠藏藐檬檐檀礁磷霜霞瞭瞧瞬瞳瞩瞪曙蹋蹈螺蟋蟀嚎赡穗魏簧簇繁徽爵朦臊鳄癌辫赢糟糠燥懦豁臀臂翼骤藕鞭藤覆瞻蹦嚣镰翻鳍鹰瀑襟璧戳孽警蘑藻攀曝蹲蹭蹬巅簸簿蟹颤靡癣瓣羹鳖爆疆鬓壤馨耀躁蠕嚼嚷巍籍鳞魔糯灌譬蠢霸露霹躏黯髓赣囊镶瓤罐矗乂乜兀弋孑孓幺亓韦廿丏卅仄厄仃仉仂兮刈爻卞闩讣尹夬爿毋邗邛艽艿札叵匝丕匜劢卟叱叻仨仕仟仡仫仞卮氐犰刍邝邙汀讦讧讪讫尻阡尕弁驭匡耒玎玑邢圩圬圭扦圪圳圹扪圮圯芊芍芄芨芑芎芗亘厍夼戍尥乩旯曳岌屺凼囡钇缶氘氖牝伎伛伢佤仵伥伧伉伫囟汆刖夙旮刎犷犸舛凫邬饧汕汔汐汲汜汊忖忏讴讵祁讷聿艮厾阱阮阪丞妁牟纡纣纥纨玕玙抟抔圻坂坍坞抃抉㧐芫邯芸芾苈苣芷芮苋芼苌苁芩芪芡芟苄苎苡杌杓杞杈忑孛邴邳矶奁豕忒欤轫迓邶忐卣邺旰呋呒呓呔呖呃旸吡町虬呗吽吣吲帏岐岈岘岑岚兕囵囫钊钋钌迕氙氚牤佞邱攸佚佝佟佗伽彷佘佥孚豸坌肟邸奂劬狄狁鸠邹饨饩饪饫饬亨庑庋疔疖肓闱闳闵羌炀沣沅沔沤沌沏沚汩汨沂汾沨汴汶沆沩泐怃怄忡忤忾怅忻忪怆忭忸诂诃诅诋诌诏诒孜陇陀陂陉妍妩妪妣妊妗妫妞姒妤邵劭刭甬邰纭纰纴纶纾玮玡玭玠玢玥玦盂忝匦坩抨拤坫拈垆抻劼拃拊坼坻㧟坨坭抿坳耶苷苯苤茏苫苜苴苒苘茌苻苓茚茆茑茓茔茕茀苕枥枇杪杳枧杵枨枞枋杻杷杼矸砀刳奄瓯殁郏轭郅鸢盱昊昙杲昃咂呸昕昀旻昉炅咔畀虮咀呷黾呱呤咚咆咛呶呣呦咝岢岿岬岫帙岣峁刿迥岷剀帔峄沓囹罔钍钎钏钒钕钗邾迮牦竺迤佶佬佰侑侉臾岱侗侃侏侩佻佾侪佼佯侬帛阜侔徂刽郄怂籴瓮戗肼䏝肽肱肫剁迩郇狙狎狍狒咎炙枭饯饴冽冼庖疠疝疡兖妾劾炜𬉼炖炘炝炔泔沭泷泸泱泅泗泠泺泖泫泮沱泯泓泾怙怵怦怛怏怍㤘怩怫怿宕穹宓诓诔诖诘戾诙戽郓衩祆祎祉祇诛诜诟诠诣诤诧诨诩戕孢亟陔妲妯姗帑弩孥驽虱迦迨绀绁绂驷驸绉绌驿骀甾珏珐珂珑玳珀顸珉珈拮垭挝垣挞垤赳贲垱垌郝垧垓挦垠茜荚荑贳荜莒茼茴茱莛荞茯荏荇荃荟荀茗荠茭茨垩荥荦荨荩剋荪茹荬荮柰栉柯柘栊柩枰栌柙枵柚枳柞柝栀柢栎枸柈柁枷柽剌酊郦甭砗砘砒斫砭砜奎耷虺殂殇殄殆轱轲轳轶轸虿毖觇尜哐眄眍𠳐郢眇眊眈禺哂咴曷昴昱昵咦哓哔畎毗呲胄畋畈虼虻盅咣哕剐郧咻囿咿哌哙哚咯咩咤哝哏哞峙峣罘帧峒峤峋峥贶钚钛钡钣钤钨钫钯氡氟牯郜秕秭竽笈笃俦俨俅俪叟垡牮俣俚皈俑俟逅徇徉舢俞郗俎郤爰郛瓴胨胪胛胂胙胍胗胝朐胫鸨匍狨狯飑狩狲訇逄昝饷饸饹胤孪娈弈奕庥疬疣疥疭庠竑彦飒闼闾闿阂羑迸籼酋炳炻炽炯烀炷烃洱洹洧洌浃洇洄洙涎洎洫浍洮洵浒浔浕洳恸恓恹恫恺恻恂恪恽宥扃衲衽衿袂祛祜祓祚诮祗祢诰诳鸩昶郡咫弭牁胥陛陟娅姮娆姝姣姘姹怼羿炱矜绔骁骅绗绛骈耖挈珥珙顼珰珩珧珣珞琤珲敖恚埔埕埘埙埚挹耆耄埒捋贽垸捃盍荸莆莳莴莪莠莓莜莅荼莩荽莸荻莘莎莞莨鸪莼栲栳郴桓桡桎桢桤梃栝桕桁桧桅栟桉栩逑逋彧鬲豇酐逦厝孬砝砹砺砧砷砟砼砥砣剞砻轼轾辂鸫趸龀鸬虔逍眬唛晟眩眙哧哽唔晁晏鸮趵趿畛蚨蚜蚍蚋蚬蚝蚧唢圄唣唏盎唑崂崃罡罟峪觊赅钰钲钴钵钹钺钽钼钿铀铂铄铆铈铉铊铋铌铍䥽铎氩氤氦毪舐秣秫盉笄笕笊笏笆俸倩俵偌俳俶倬倏恁倭倪俾倜隼隽倌倥臬皋郫倨衄颀徕舫釜奚衾胯胱胴胭脍胼朕脒胺鸱玺鸲狷猁狳猃狺逖桀袅饽凇栾挛亳疳疴疸疽痈疱痂痉衮凋颃恣旆旄旃阃阄訚阆恙粑朔郸烜烨烩烊剡郯烬涑浯涞涟娑涅涠浞涓浥涔浜浠浣浚悚悭悝悒悌悛宸窈剜诹冢诼袒袢祯诿谀谂谄谇屐屙陬勐奘牂蚩陲姬娠娌娉娲娩娴娣娓婀畚逡绠骊绡骋绥绦绨骎邕鸶彗耜焘舂琏琇麸揶埴埯捯掳掴埸埵赧埤捭逵埝堋堍掬鸷掖捽掊堉掸捩掮悫埭埽掇掼聃菁萁菘堇萘萋菽菖萜萸萑棻菔菟萏萃菏菹菪菅菀萦菰菡梵梿梏觋桴桷梓棁桫棂啬郾匮敕豉鄄酞酚戛硎硭硒硖硗硐硇硌鸸瓠匏厩龚殒殓殍赉雩辄堑眭眦啧晡晤眺眵眸圊喏喵啉勖晞唵晗冕啭畦趺啮跄蚶蛄蛎蛆蚰蛊圉蚱蛉蛏蚴啁啕唿啐唼唷啖啵啶啷唳唰啜帻崚崦帼崮崤崆赇赈赊铑铒铗铙铟铠铡铢铣铤铧铨铩铪铫铬铮铯铰铱铳铵铷氪牾鸹秾逶笺筇笸笪笮笠笥笤笳笾笞偾偃偕偈傀偬偻皑皎鸻徜舸舻舴舷龛翎脬脘脲匐猗猡猞猝斛猕馗馃馄鸾孰庹庾痔痍疵翊旌旎袤阇阈阉阊阋阍阏羟粝粕敝焐烯焓烽焖烷焗渍渚淇淅淞渎涿淖挲淠涸渑淦淝淬涪淙涫渌淄惬悻悱惝惘悸惆惚惇惮窕谌谏扈皲谑裆袷裉谒谔谕谖谗谙谛谝逯郿隈粜隍隗婧婊婕娼婢婵胬袈翌恿欸绫骐绮绯绱骒绲骓绶绺绻绾骖缁耠琫琵琶琪瑛琦琥琨靓琰琮琯琬琛琚辇鼋揳堞搽揸揠堙趄揖颉塄揿耋揄蛩蛰塆摒揆掾聒葑葚靰靸葳葺葸萼葆葩葶蒌萱戟葭楮棼椟棹椤棰赍椋椁椪棣椐鹁覃酤酢酡鹂厥殚殛雯雱辊辋椠辍辎斐睄睑睇睃戢喋嗒喃喱喹晷喈跖跗跞跚跎跏跆蛱蛲蛭蛳蛐蛔蛞蛴蛟蛘喁喟啾嗖喑嗟喽嗞喀喔喙嵘嵖崴遄詈嵎崽嵬嵛嵯嵝嵫幄嵋赕铻铼铿锃锂锆锇锉锏锑锒锔锕掣矬氰毳毽犊犄犋鹄犍嵇黍稃稂筚筵筌傣傈舄牍傥傧遑傩遁徨媭畲弑颌翕釉鹆舜貂腈腌腓腆腴腑腚腱鱿鲀鲂颍猢猹猥飓觞觚猱颎飧馇馊亵脔裒痣痨痦痞痤痫痧赓竦瓿啻颏鹇阑阒阕粞遒孳焯焜焙焱鹈湛渫湮湎湜渭湍湫溲湟溆湲湔湉渥湄滁愠惺愦惴愀愎愔喾寐谟扉裢裎裥祾祺谠幂谡谥谧遐孱弼巽骘媪媛婷巯翚皴婺骛缂缃缄彘缇缈缌缑缒缗飨耢瑚瑁瑜瑗瑄瑕遨骜韫髡塬鄢趔趑摅摁蜇搋搪搐搛搠摈彀毂搦搡蓁戡蓍鄞靳蓐蓦鹋蒽蓓蓖蓊蒯蓟蓑蒿蒺蓠蒟蒡蒹蒴蒗蓥颐楔楠楂楝楫楸椴槌楯皙榈槎榉楦楣楹椽裘剽甄酮酰酯酩蜃碛碓硼碉碚碇碜鹌辏龃龅訾粲虞睚嗪韪嗷嗉睨睢雎睥嘟嗑嗫嗬嗔嗝戥嗄煦暄遢暌跬跶跸跐跣跹跻蛸蜊蜍蜉蜣畹蛹嗣嗯嗥嗲嗳嗌嗍嗨嗐嗤嗵罨嵊嵩嵴骰锗锛锜锝锞锟锢锨锩锭锱雉氲犏歃稞稗稔筠筢筮筲筱牒煲敫徭愆艄觎毹貊貅貉颔腠腩腼腭腧塍媵詹鲅鲆鲇鲈稣鲋鲐肄鹐飕觥遛馐鹑亶瘃痱痼痿瘐瘁瘆麂裔歆旒雍阖阗阙羧豢粳猷煳煜煨煅煊煸煺滟溱溘漭滢溥溧溽裟溻溷滗滫溴滏滃滦溏滂滓溟滪愫慑慊鲎骞窦窠窣裱褚裨裾裰禊谩谪媾嫫媲嫒嫔媸缙缜缛辔骝缟缡缢缣骟耥璈瑶瑭獒觏慝嫠韬叆髦摽墁撂摞撄翥踅摭墉墒榖綦蔫蔷靺靼鞅靿甍蔸蔟蔺戬蕖蔻蓿斡鹕蓼榛榧榻榫榭槔榱槁槟槠榷僰酽酶酹厮碡碴碣碲磋臧豨殡霆霁辕蜚裴翡龇龈睿䁖睽嘞嘈嘌嘁嘎暧暝踌踉蜞蜥蜮蝈蜴蜱蜩蜷蜿螂蜢嘘嘡鹗嘣嘤嘚嗾嘧罴罱幔嶂幛赙罂骷骶鹘锲锴锶锷锸锵镁镂犒箐箦箧箍箸箬箅箪箔箜箢箓毓僖儆僳僭劁僮魃魆睾艋鄱膈膑鲑鲔鲚鲛鲟獐觫雒夤馑銮塾麽瘌瘊瘘瘙廖韶旖膂阚鄯鲞粿粼粽糁槊鹚熘熥潢漕滹漯漶潋潴漪漉漳漩澉潍慵搴窨寤綮谮褡褙褓褛褊谯谰谲暨屣鹛嫣嫱嫖嫦嫚嫘嫡鼐翟瞀鹜骠缥缦缧缨骢缪缫耦耧瑾璜璀璎璁璋璇奭髯髫撷撅赭撸鋆撙撺墀聩觐鞑蕙鞒蕈蕨蕤蕞蕺瞢蕃蕲赜槿樯槭樗樘樊槲醌醅靥魇餍磔磙霈辘龉龊觑瞌瞋瞑嘭噎噶颙暹噘踔踝踟踒踬踮踯踺踞蝽蝾蝻蝰蝮螋蝓蝣蝼噗嘬颚噍噢噙噜噌噔颛幞幡嶙嶝骺骼骸镊镉镌镍镏镒镓镔稷箴篑篁篌篆牖儋徵磐虢鹞膘滕鲠鲡鲢鲣鲥鲧鲩獗獠觯馓馔麾廛瘛瘼瘢瘠齑羯羰𥻗遴糌糍糅熜熵熠澍澌潸潦潲鋈潟潼潺憬憧寮窳谳褴褟褫谵熨屦嬉勰戮蝥缬缮缯骣畿耩耨耪璞璟靛璠璘聱螯髻髭髹擀熹甏擞縠磬颞蕻鞘颟薤薨檠薏薮薜薅樾橛橇樵檎橹樽樨橼墼橐翮醛醐醍醚磲赝飙殪霖霏霓錾辚臻遽氅瞟瞠瞰嚄嚆噤暾蹀踹踵踽蹉蹁螨蟒螈螅螭螠螟噱噬噫噻噼罹圜䦃镖镗镘镚镛镝镞镠氇氆憩穑篝篥篦篪篙盥劓翱魉魈徼歙膳膦膙鲮鲱鲲鲳鲴鲵鲷鲻獴獭獬邂鹧廨赟瘰廪瘿瘵瘴癃瘳斓麇麈嬴壅羲糗瞥甑燎燠燔燧濑濉潞澧澹澥澶濂褰寰窸褶禧嬖犟隰嬗颡缱缲缳璨璩璐璪螫擤壕觳罄擢薹鞡鞬薷薰藓藁檄檩懋醢翳礅磴鹩龋龌豳壑黻嚏嚅蹑蹒蹊蟥螬螵疃螳蟑嚓羁罽罾嶷黜黝髁髀镡镢镣镦镧镩镪镫罅黏簌篾篼簖簋鼢黛儡鹪鼾皤魍龠繇貘邈貔臌膻臆臃鲼鲽鳀鳃鳅鳇鳊螽燮鹫襄糜縻膺癍麋懑濡濮濞濠濯蹇謇邃襁檗擘孺隳嬷蟊鹬鍪鏊鳌鬈鬃瞽鞯鞨鞫鞧鞣藜藠藩醪蹙礓燹餮瞿曛颢曜躇蹚鹭蟛蟪蟠蟮鹮黠黟髅髂镬镭镯馥簟簪鼬雠艟鳎鳏鳐癞癔癜癖糨蹩鎏懵彝邋鬏攉攒鞲鞴藿蘧蘅麓醮醯酃霪霭霨黼嚯蹰蹶蹽蹼蹴蹾蹿蠖蠓蟾蠊黢髋髌镲籀籁齁魑艨鳓鳔鳕鳗鳙麒鏖羸㸆瀚瀣瀛襦谶襞骥缵瓒攘蘩蘖醴霰酆矍曦躅鼍巉黩黥黪镳镴黧纂璺鼯臜鳜鳝鳟獾孀骧瓘鼙醺礴颦曩鳢癫麝夔爝灏禳鐾羼蠡耱懿蘸鹳霾氍饕躐髑镵穰饔鬻鬟趱攫攥颧躜鼹癯麟蠲蠹躞衢鑫灞襻纛鬣攮囔馕戆爨齉亍尢彳卬殳𠙶毌邘戋圢氕伋仝冮氿汈氾忉宄𬣙讱扞圲圫芏芃朳朸𨙸邨吒吖屼屾辿钆仳伣伈癿甪邠犴冱邡闫𬇕汋䜣讻𬣞孖𬘓纩玒玓玘玚刬𫭟坜坉扽𫭢坋扺㧑毐芰芣苊苉芘芴芠𫇭芤杕杙杄杧杩尪尨轪𫐄坒芈旴旵呙㕮岍𫵷岠岜呇冏觃岙伾㑇伭佖伲佁飏狃闶汧汫𣲘𣲗沄沘𬇙汭㳇沇忮忳忺𬣡祃诇邲诎诐屃𫸩岊阽䢺阼妧妘𨚕纮驲𫘜纻𬘘𫘝纼玤玞玱玟邽邿坥坰坬坽弆耵䢼𦭜茋苧苾苠枅㭎枘枍矼矻匼𬨂𬀩𬀪旿昇昄昒昈咉咇咍岵岽岨岞峂㟃囷𬬩钐钔钖牥佴垈侁侹佸佺隹㑊侂佽侘郈舠郐郃攽肭肸肷狉狝饳忞於炌炆泙沺泂泜泃泇怊峃穸祋祊𫍣𬣳𬩽鸤弢弨陑𬮿陎𬯀卺乸妭姈𫰛迳叕𬳵驵𬳶䌹驺𫠊绋绐砉耔㛃玶珇珅𬍛珋玹珌玿韨垚垯垙垲埏垍耇鿍垎垴垟垞挓垵垏拶荖荁荙荛茈茽荄茺𬜬荓茳𦰡茛荭㭕柷柃柊枹栐柖郚剅䴓迺厖砆砑砄耏奓䶮轵轷轹轺昺𪾢昽盷咡咺昳昣哒昤昫昡咥昪虷虸哃峘耑峛𪨰峗峧帡钘𫓧钜𬬮𬬱𬬭钪钬钭矧秬俫舁俜俙俍垕衎舣弇侴鸧䏡胠𦙶胈胩胣朏飐訄饻庤疢炣炟㶲洭洘洓洿㳚泚浈浉洸洑洢洈洚洺洨浐㳘洴洣恔宬窀扂袆祏祐祕叚陧陞娀姞姱姤姶姽枲绖骃𬘡𬳽𬘩𫄧彖骉恝珪珛珹琊玼珖𪟝珽珦珫珒𬍤珢珕珝𫭼埗垾垺埆垿埌埇莰茝𬜯鄀莶莝䓖莙栻桠𬂩桄梠栴梴栒酎酏𫠆砵砠砫砬硁恧翃郪𨐈辀辁𬌗剕赀哢晅晊唝哳哱冔晔晐晖畖蚄蚆𫑡帱崁峿𪨶崄帨崀赆𬬸钷𬬻𬬹𬬿𬭁眚甡笫倻倴脩倮倕倞𫢸倓倧衃虒舭舯舥瓞鬯鸰脎朓胲虓鱽狴峱狻眢𫗧勍痄疰痃竘羖羓桊敉烠烔烶烻𬊈涍浡浭浬涄涢涐浰浟浛浼浲涘悈悃悢𬒈宧窅窊窎扅扆袪袗袯祧隺堲疍𨺙陴烝砮㛚哿翀翂剟𬳿𫄨绤骍𬘫䂮琎珸珵琄琈琀珺掭堎堐埼掎埫堌晢𫮃掞埪壸㙍聍菝萚菥莿䓫勚䓬萆菂菍菼萣䓨菉䓛梼梽桲梾桯梣梌桹敔厣硔鿎硙硚硊硍勔䴕龁逴唪啫翈㫰晙畤𬱖趼跂蛃蚲𬟽蚺啴䎃崧崟崞崒崌崡铏𫓯𫟹铕𫟼铖铘铚铞铥铴牻牿稆笱笯偰偡鸺偭偲偁㿠鄅偓徛衒舳舲鸼悆鄃瓻䝙脶脞脟䏲鱾猇猊猄觖𠅤庱庼庳痓䴔竫堃阌羝羕焆烺焌淏𬇹淟淜淴淯湴涴𬍡㥄惛惔悰惙寁逭𬤇𫍯袼裈祲𬤊𫍲谞艴弸弶𬯎隃婞娵婼媖婳婍婌婫婤婘婠𬘬𬘭𬴂𫘦绹𫟅𬘯骕𫘧絜珷琲琡琟琔琭堾堼揕㙘堧喆堨塅堠絷𪣻𡎚葜惎萳葙靬葴蒇蒈鄚蒉蓇萩蒐葰葎鄑蒎葖蒄萹棤棽棫椓椑𬃊鹀椆棓棬棪椀楗𬷕甦酦觌奡皕硪欹詟𫐐辌棐龂𬹼黹牚睎晫晪晱𧿹蛑畯斝喤崶嵁𫶇崾嵅崿嵚翙𫖮圌圐赑淼赒鿏铹𬭊铽𨱇𫓶锊锍锎𬭎锓犇颋稌筀筘筜筥筅傃傉翛傒傕舾畬𫖯脿腘䐃腙腒𬱟鲃猰𫛭猯㺄馉凓鄗𫷷廋廆鄌粢遆旐𬮱焞𬊤欻𣸣溚溁湝渰湓㴔渟溠渼溇湣湑溞愐愃敩甯棨扊裣祼婻媆媞㛹媓媂媄毵矞𬴃𫘨缊缐骙瑃瑓瑅瑆䴖瑖瑝瑔瑀𤧛瑳瑂嶅瑑遘髢塥堽赪摛塝搒搌蒱蒨蓏蔀蓢蓂蒻蓣椹楪榃榅楒楞楩榇椸楙歅𬪩碃碏𬒔碈䃅硿鄠辒𬨎𫐓龆觜䣘暕鹍𫫇㬊暅跱蜐蜎嵲赗骱锖𫓹锘锳锧锪𬭚锫锬𬭛稑稙䅟𬕂筻筼筶筦筤傺鹎僇艅艉谼貆腽腨腯鲉鲊鲌䲟𬶋𬶍鲏雊猺飔觟𦝼馌裛廒瘀瘅鄘鹒鄜麀鄣阘𫔶煁煃煴煋煟煓滠溍溹滆滉溦溵漷滧滘滍愭慥慆塱𫌀裼禋禔禘禒谫鹔𫖳愍嫄媱戤勠戣𫘪𫘬缞耤瑧𫞩瑨瑱瑷瑢斠摏墕墈墐墘摴銎𡐓墚撖𪤗靽鞁蔌蔈蓰蔹蔊嘏榰榑槚𣗋槜榍疐𬸘酺酾酲酴碶䃎𬒗碨𥔲碹碥劂𫚖䴗夥瞍鹖㬎跽蜾幖嶍圙𨱏锺锼锽𬭤锾锿镃镄镅馝鹙箨箖劄僬僦僔僎槃㙦鲒鲕𫚕鲖鲗鲘鲙𬶐𬶏𩽾夐獍飗𬸚凘廑廙瘗瘥瘕鲝鄫熇漹漖潆漤潩漼漴㽏漈漋漻慬窬窭㮾𬤝褕禛禚隩嫕嫭嫜嫪𬙂㻬麹璆漦叇墣墦墡劐薁蕰蔃鼒槱鹝磏磉殣慭霅暵暲暶踦踣䗖蝘蝲蝤噇噂噀罶嶲嶓㠇嶟嶒镆镈镋镎𬭩镕稹儇皞皛䴘艎艏鹟𩾃鲦鲪鲬橥觭鹠鹡糇糈翦鹢鹣熛潖潵㵐澂澛瑬潽潾潏憭憕𬸣戭褯禤𫍽嫽遹𬴊璥璲璒憙擐鄹薳鞔黇𬞟蕗薢蕹橞橑橦醑觱磡𥕢磜豮𫟦𬺈𫠜鹾虤暿曌曈㬚蹅踶䗛螗疁㠓幪𪩘嶦𬭬𨱑𬭯馞穄篚篯簉鼽衠盦螣縢鲭鲯鲰鲺鲹𫗴亸癀瘭𬸦羱糒燋熻燊燚燏濩濋澪澽澴澭澼憷憺懔黉嬛鹨翯𫄷璱𤩽璬璮髽擿薿薸檑櫆檞醨繄磹磻瞫瞵蹐蟏㘎𬭳镤𬭶𫔍镥镨𬭸𨱔𬭼𫔎矰穙穜穟簕簃簏儦魋斶艚𬸪谿䲠𬶟鲾𬶠鲿鳁鳂鳈鳉獯䗪馘襕襚𬶨螱甓嬬嬥𦈡𫄸瓀釐鬶爇鞳鞮𬟁藟藦藨鹲檫黡礞礌𥖨蹢蹜蟫䗴嚚髃镮镱酂馧簠簝簰鼫鼩皦臑䲢鳑鳒鹱鹯癗𦒍旞翷冁䎖瀔瀍瀌襜䴙𬙊嚭㰀鬷醭蹯蠋翾鳘儳儴鼗𬶭𩾌鳚鳛麑麖蠃彟嬿鬒蘘欂醵颥甗𨟠巇酅髎犨𬶮𨭉㸌爔瀱瀹瀼瀵襫孅骦𬙋耰𤫉瓖鬘趯𬺓罍鼱鳠鳡鳣爟爚灈韂糵蘼礵鹴躔皭龢鳤亹籥鼷𫚭玃醾齇觿蠼後丟並亂亙亞伕佇佔來併侖俠侶係倣倖倆們倀個倫倉偺偽偉偵側傢備傑傖傘傭債傳僅傾傷傯僥僕僑僱億儀價儂儈儉儘儔儐優償儲儷儼兇兌兒兗內兩冊冑凍凜凱別刪剎則剛剝剴創剷劃劇劉劍劑勁務動勞勝勛勦勢勵勸勻匯匱區協卹卻厭厲參叢吋呎吳呂吶員啞問唸啣喪單喲喚喬嗎嗇嗚嗆嘗嘔嘆嘍嘖嘮嘩噓噴嘯嘰噹噸噥噯嚀嚐嚇嚕嚮嚥嚨嚶嚴囁囀囂囈囉囌囑囪國圍園圓團圖堅堊執堯場報塗塚塭塊塢塵墊塹墳墜墮墾壇壓壙壘壞壟壢壩壯壺壽夠夢夾奐奧奪奩奮妝姍妳姪姦娛婁婦媽媼嫗嫻嬋嫵嬌嬝嬰嬪嬤嬸孫學孿宮寧實寢寬審寫寵寶專將尋對導尷屆屍屜屢層屬岡峽島崢崑崙嵐嶄嶇嶼嶺嶽巔巒巖帥師帶帳幀幣幗幟幫幹幾庫廁廂廈廢廚廟廝廣廠龐廬廳弒弔張強彆彈彌彎彙彥彫彿徑從復徬徹恆恥悅悽悵惡悶愜惻惱愛慄慍愾愴慇態慣慟慚慘慶慮憂慼慫慾憐憫憚憤憲憑憊懍憶應懇懣懲懷懶懸懺懼懾戀戰戲戶拋拚挾捲捱掃掛捫掄掙採捨揀揮換揚搾損搶搖搗摟摺摑摯撲撈撐撥撓撫撚擁擋撻據擄擇撿擔擊擠擰擬擱擴擲擾攆擺擻攏攔攙攝攜攤攣攪攬敗啟敘敵數斂斃斬斷時晉晝暉暈暢暫曆曉曖曠書勗會朧朮東柵枴桿梱棄梔條梟棗棟棧棲業極楊楨楓榮槓構槍樣槨樁樞標樓槳樂樅樸樺橫樹橢橋機檔檢檜櫛檳櫃檻檸櫂櫥櫝櫚櫓櫻欄權欖欽歐歟歡歲歷歸歿殘殤殮殯殲殺殼毀毆氣氫氳汙決沖沒況洶涇涼淺淵淒淚淪淨湧湊減渦湯測渾渙溝滅溼溫準滄滾漬漢滿滯漸漲漣滬漁滲滌漿潑潔澆潛潰潤澗澱濃澤濁濘濱濟濛濤濫澀濬瀉瀋濾瀆濺瀏瀟瀨瀝瀕瀾瀰灑灘灣灤災為烏無煙煩煉煬煥熱熾燉燐燒燈燙燜燄營燦燭燬燴燻爍爐爛爭爺爾牆牘牠牴牽犖犛犢犧狀狹狽猓猙猶獅獄獎獨獰獲獷獵獸獺獻玀玨珮現琍琺瑯琿瑤瑣瑪瑩璣環璦璽瓊瓏甌甕產甽畝畢異畫當疇疊疋痙痲痺瘧瘍瘋瘉瘓瘡癆療癘癒癢癥癩癮癬癱癲發皚皰皺盃盜盞盡監盤盧盪眾睏睞睪睜瞇瞞矇矓矚矯矽硃硯碩確碼磚磺磯礎礙礦礪礬礫祿禎禍禦禪禮禱萬禿稈稅稜稟種稱穀積穎穌穡穢穫穩窪窩窯窮窺竄竅竇竊競筆筍節箋箝箏範簑築篤篛篩簍簫簞簣簡簾簽簷籌籃籐籠籟籤籬籮籲粵糞糢糧糸糾紂紅紀紉紇約紡紗紋純紐紕級紜納紙紛絆絃統紮紹紼絀細紳組終絞結絨絕絲絡給絢經絹綑綁綏綻綰綜綽綾綠緊綴網綱綺綢綿綵綸維緒緇締練緯緻緘緬緝編緣線緞緩綞縊縑縈縛縣縮績繆縷縲繃縫總縱繅織繕繞繚繡繫繭繹繩繪辮繽繼纏續纓纖纜缽罈罰罵罷羅羈羋義羨羶習翹聖聞聲聰聯聳職聶聾聽肅脅脈脣脫腎脹腸腳腫腦膠膚膩膿膽臉膾臍臏臘臚臟臥臨臺與興舉舊舨艙艦艱芻荊茲莢莖莊菸華菴萊葷葦葉萵蓆蒞蓋蓀蒼蓮蔭蔣蔔蔥蕩蕭蕪薑薔薩藍藝藪藥藹藺蘆蘋蘇蘊蘗蘭蘚蘿處虛虜號虧蚵蛻蝕蝦蝸蝨螞螢螻蟈蟯蟬蟲蟻蠅蠍蠔蠣蠟蠱蠶蠻術衛衝袞補裝裡裊製複褲褻褸襠襖襤襪襲襯見覓規視親覦覬覲覺覽觀觴觸計訂訃記訐討訌訕訊託訓訖訪訝訣訥許設訟訛註詠評詞証詁詔詛詐詆訴診詫該詳試詩詰誇詼詣誠話誅詭詢詮詬誦誌語誣認誡誤說誥誨誘誑誼諒談諄誕請諸課諉諂調誰論諍諦諺諫諱謀諜諧諮諾謁謂諷諭謎謗謙講謊謠謝謄謨謹謬譁譜識證譚譎譏議譯譴護譽讀變讓讒讖讚豈豎豐豔豬貍貓貝貞負財貢販責貫貨貪貧貯貼貳貽賁費賀貴買貶貿貸賊資賈賄貲賃賂賅賓賑賒賠賞賦賤賬賭賢賣賜質賴賺賽購贅贈贊贏贍贓贖贗贛趙趕趨跡跼踫踐踴蹣蹤蹺躉躂躊躍躑躡躪軀車軋軍軌軒軔軛軟軻軸軼較載軾輊輔輒輕輓輝輛輟輩輦輪輜輻輯輸轄輾轂轅輿轉轍轔轎轟轡辦辭辯農迆迴這連逕週進運遊達違過遠遜遙遞適遷選遲遼遺還邁邇邊邐邏郵鄉鄒鄰鄭鄧醃醣醞醜醫醬釀釁釋釘針釗釵釦釣釧鈔鈣鈕鈉鈞鈍鈐鈷鉗鈸鈽鉀鈾鉛鉋鉤鉑鈴鉸銬銀銅銘銖鉻銓銜鋅銻銷鋪鋤鋁銳銼鋒錠錶鋸錳錯錢鋼錫錄錚錐錦鍍鎂錨鍵鍊鍥鍋錘鍾鍬鍛鍰鎔鎊鎖鎢鎳鎮鏡鏑鏟鏃鏈鏜鏝鏢鏍鏘鏤鏗鐘鐃鏽鐮鐳鐵鐺鐸鐲鑄鑑鑒鑣鑠鑲鑰鑽鑾鑼鑿長門閂閃閉閔閏開閑間閒閘閡閨閩閣閥閤閭閱閻闊闋闌闈闆闔闖闐關闡闢陣陝陳陸陰隊階陽隕際隨險隱隴隸隻雋雖雜雙雛雞離難雲電霑霧霽靂靈靄靜靦靨鞏鞦韃韁韆韋韌韓韜韻響頁頂頃項順須預頑頓頊頒頌頗領頡頰頸頻頷頭頹頤顆額顏題顎顓類願顛顧顫顯顰顱風颯颱颳颶颺颼飄飛飢飪飯飩飲飭飼飴飽飾餃餅餌餉養餓餒餘館餞餛餡餵餾餿餽饅饒饑饜饞馬馮馭馳馱馴駁駝駐駟駛駑駕駒駙駭駢駱騁駿騎騖騙騫騰騷驅驃驀騾驕驚驛驗驟驢驥驪骯髏髒體髮鬆鬍鬚鬢鬥鬧鬨鬱魘魚魷魯鮑鮮鮫鮪鯊鯉鯽鯨鯧鰓鰍鰭鰥鱉鰱鰾鰻鱔鱗鱖鱷鱸鳥鳩鳴鳶鳳鴆鴉鴕鴣鴦鴨鴒鴛鴻鴿鵑鵝鵠鶉鵡鵲鵪鵬鶯鶴鷂鷓鷗鷥鷹鷺鸚鸞鹹鹼鹽麗麥麩麴麵麼黃點黨黴黷鼇鼕鼴齊齋齒齟齣齡齜齦齬齪齷齲龍龔龜裏佈濕堿縴輥崗烴繳樑吪蹟墻艷滸勳鷊饋嚦銨鹵曇撾鄆銹摻曬澇鰲噠冪薦燾熒氈羥蕕饁訶鏵飀憓戔鈦鋰嚙氬鋇巰鮒錮喓捄鉬戩褘誹鍔闓頲詒閹魴謚洩轆餚舖闕嗶淩軹檽銑縐愷攢樀鎌鎬贄魛灝髖劊溮翬蹠彊曨檯癟剄懨揌簦諢罃薊鉅漚鍺鍘鐐廄銫憖灩瑋鉦鑊塈寔酈嗩澮燁脛雰鴇澦磧薌釩餑瀘絳纍貰鎵鑷饃齎砩鯕唄僨卌撟滎賡鉚滀濰莧蕎鈺鰣搳潷瑒轢頎晛癭蒔蝟襌鄺釔鯪鷲嘜玁糶紈憮摳纔薺轤鐠餔齶剚幠湋潓綌緋驤淶燼碫縹釙鉞櫟紝謳鄲闞頜鱒熤礡釷鋯鍶鎧韞饌鯰僂愬瓚碔緱蟿鋏鑕钁凊塽揅撣癙禨襏蹌郟鈁銥銣鞿鯔鸕殫汏煒緲縞翽荳蘄詎謾鈀鉍鑞隄鯗鱧鳧鶻俁俛厔嵒燿盩禕纘覷訑訢諛謅鈹鎘駸鳲鴝掱攄榤綷綹緙謐謫贐鄴錕隤鵷鶵奼峴怹梩浹碁○歎峇飆诶〇𪨊揹㨃玅㑚屌裋聴玗説爲顔喫衆牀絶産駡緑奬躱槪麪録閲覈誒痠啓癡竈薈孃讞艶鋭箇僞柺糉滷綉嬡螄㞞侷剮襬鉢巘壎暘鵰龕圇謡躋擡蟶諏贇儕蓽斕顴皁躥墶嬈繮廡衊頽鶩饈縟謔縗絝噁鎚堝繾閆綣殞衹朶垜挅㛆𧻞刴跥𨦃桗𥿰卽旣喞漑灧捝敚涚懡攷擼俬栢屄冇糺縵鈿韙鸝譭鐫苪筳㠯魎尛搥砲鮭鼂肏粧嫺綫滙峯頴羣鱻驫咲雫乭丼仮辻冖讠礻匚纟廴囗辶冂丷凵龰扌罒刂丌丂宀丄𠂤厶丶艹𧘇卩乚夂丅阝彡钅咼僉巛疒𬺰攴𠂇犭丿衤黽氵亻彐饣丱丨乀ㄅㄆㄇㄈㄉㄊㄋㄌㄍㄎㄏㄐㄑㄒㄓㄔㄕㄖㄗㄘㄙㄚㄛㄜㄝㄞㄟㄠㄡㄢㄣㄤㄥㄦㄧㄨㄩㄪㄫㄬㄭ぀ぁあぃいぅうぇえぉおかがきぎくぐけげこごさざしじすずせぜそぞただちぢっつづてでとどなにぬねのはばぱひびぴふぶぷへべぺほぼぽまみむめもゃやゅゆょよらりるれろゎわゐゑをんゔゕゖ゗゘゙゚゛゜ゝゞゟ゠ァアィイゥウェエォオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂッツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモャヤュユョヨラリルレロヮワヰヱヲンヴヵヶヷヸヹヺ・ーヽヾヿABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789　‐‑‒–—―‖‗‘’‚‛“”„‟†‡•‣․‥…‧ ‰‱′″‴‵‶‷‸‹›※‼‽‾‿⁀⁁⁂⁃⁄⁅⁆⁇⁈⁉⁊⁋⁌⁍⁎⁏⁐⁑⁒⁓⁔⁕⁖⁗⁘⁙⁚⁛⁜⁝⁞、。〃〄々〆〈〉《》「」『』【】〒〓〔〕〖〗〘〙〚〛〜〝〞〟〠〡〢〣〤〥〦〧〨〩〪〭〮〯〫〬〰〱〲〳〴〵〶〷〸〹〺〻〼□！？：；，§×· ,.?!:;'[]{}<>/()@#$%^&*-_+=€ÄÖÜäöü~¡¢£¤¥¨ª«¬°±²³µ¶º»¿ÀÁÂÃÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕØÙÚÛÝÞßàáâãåæçèéêëìíîïðñòóôõ÷øùúûýþÿĀāĂăĄćĈċčĎđĒēĔėĘĚěĜĞġģĤħĩĪīĭĮİıĲĳĴķĸĺĻļĽĿŀłŃņŇŉŋŌōŎőŒœŔŖŘŚŝŞŠţťŦũŪūŭŮűŲŴŶŸŹŻżžſƀƁƃƄƆƇƉƊƌƍƎƏƐƑƒƓƔƕƖƗƘƚƛƜƝƞƟơƣƥƦƩƫƬƮƯƱƲƳƵƷƸƺǍǎǏǐǑǒǓǔǕǖǗǘǙǚǛǜǝǞǧǩǪǭǮǰǱǲǳǵǸǻǼǾȀȃȄȆȇȈȋȍȎȑȒȔȖșțɑɔəɛɡɴɹɻʁʃʄʅʆʇʈʉʊʋʌʍʎʏʐʑʒʓʙʚʛʜʝʞʟʠʣʤʥʦʧʨʩʮʯΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩαβγδεζηθικλμνξοπρςστυφχϘϙϜϝẐẑ  ≠①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳⑴⑵⑶⑷⑸⑹⑺⑻⑼⑽⑾⑿⒀⒁⒂⒃⒄⒅⒆⒇ⒶⒷⒸⒹⒺⒻⒼⒽⒾⒿⓀⓁⓂⓃⓄⓅⓆⓇⓈⓉⓊⓋⓌⓍⓎⓏⓐⓑⓒⓓⓔⓕⓖⓗⓘⓙⓚⓛⓜⓝⓞⓟⓠⓡⓢⓣⓤⓥⓦⓧⓨⓩ⓪⓫⓬⓭⓮⓯⓰⓱⓲⓳⓴⓵⓶⓷⓸⓹⓺⓻⓼⓽⓾⓿✅❌❓⿰⿱⿲⿳⿴⿵⿶⿷⿸⿹⿺⿻〽ㄮ㉑㉒㉓㉔㉕㉖㉗㉘㉙㉚㉛㉜㉝㉞㉟㊀㊁㊂㊃㊄㊅㊆㊇㊈㊉㊊㊋㊌㊍㊎㊏㊐㊑㊒㊓㊔㊕㊖㊗㊘㊙㊚㊛㊜㊝㊞㊟㊠㊡㊢㊣㊤㊥㊦㊧㊨㊩㊪㊫㊬㊭㊮㊯㊰㊱㊲㊳㊴㊵㊶㊷㊸㊹㊺㊻㊼㊽㊾㊿㋀㋁㋂㋃㋄㋅㋆㋇㋈㋉㋊㋋㋐㋑㋒㋓㋔㋕㋖㋗㋘㋙㋚㋛㋜㋝㋞㋟㋠㋡㋢㋣㋤㋥㋦㋧㋨㋩㋪㋫㋬㋭㋮㋯㋰㋱㋲㋳㋴㋵㋶㋷㋸㋹㋺㋻㋼㋽㋾㋿㍱㍲㍳㍴㍵㍶㎀㎁㎂㎄㎅㎇㎈㎉㎊㎋㎌㎍㎐㎑㎓㎔㎕㎗㎘㎙㎚㎛㎝㎠㎢㎤㎥㎦㎩㎪㎬㎰㎱㎲㎴㎵㎶㎸㎺㎻㎼㎾㏀㏁㏂㏃㏄㏅㏆㏇㏈㏉㏊㏋㏌㏍㏏㏗㏘㏙㏚㏛㏜㏝㏾䷀䷁䷂䷃䷄䷅䷆䷇䷈䷉䷊䷋䷌䷍䷎䷏䷐䷑䷒䷓䷔䷕䷖䷗䷘䷙䷚䷛䷜䷝䷞䷟䷠䷡䷢䷣䷤䷥䷦䷧䷨䷩䷪䷫䷬䷭䷮䷯䷰䷱䷲䷳䷴䷵䷶䷷䷸䷹䷺䷻䷼䷽䷾䷿︰︱︳︴︵︶︷︸︹︺︻︼︽︾︿﹀﹁﹂﹃﹄﹉﹊﹋﹌﹍﹎﹏＂＃＄％＆（）＊＋－．／＜＝＞＠ＫＯ［＼］＾＿｀｛｜｝～￠￡￢￣￤￥￩￪￫￬￭😀😁😂😃😄😅😆😇😈😉😋😍😎😏😐😑😒😓😗😘😙😚😞😠😡😢😥😬😭😱😴😷😻😼🙂🙄🙅🙆🙈🙉🙊🙋🙌🙏"

function setfromstr(str)
    local t = {}
    for p, c in utf8.codes(str) do
        t[utf8.char(c)] = true
    end
    return t
end

local charset = setfromstr(str)

-- function issubset(candidate, charset)
--     for el, _ in pairs(candidate) do
--         if not charset[el] then
--             return false
--         end
--     end
--     return true
-- end

function isintersected(candidate, charset)
    local count = 0
    for el, _ in pairs(candidate) do
        count = count + 1
    end
    if ((count < 1) or (count > 10)) then
        return true
    end
    for el, _ in pairs(candidate) do
        if charset[el] then
            return true
        end
    end
    return false
end

local function yuhao_char_first(input, env)
    local b = env.engine.context:get_option("yuhao_char_first")
    local l = {}
    for cand in input:iter() do
        local candidate = setfromstr(cand.text)
        -- if (not b or issubset(candidate, charset)) then
        if (not b or isintersected(candidate, charset)) then
            yield(cand)
        else
            table.insert(l, cand)
        end
    end
    -- 非常用字词后置
    for i, cand in ipairs(l) do
        yield(cand)
    end
end

local function yuhao_char_only(input, env)
    local b = env.engine.context:get_option("yuhao_char_only")
    for cand in input:iter() do
        local candidate = setfromstr(cand.text)
        -- if (not b or issubset(candidate, charset)) then
        if (not b or isintersected(candidate, charset)) then
            yield(cand)
        end
    end
end

return { yuhao_char_first = yuhao_char_first, yuhao_char_only = yuhao_char_only }
