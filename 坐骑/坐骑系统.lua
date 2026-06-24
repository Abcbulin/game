---@class 坐骑系统: Serve
local S = Serve("坐骑系统")


-- 获取幻化信息
local mountModel = require_ex('QuestDiary/game_config/cfgcsv/MountHuanhua')
local mountInfo = {}

-- 更新坐骑增加属性
-- 坐骑升级升阶幻化属性
-- 幻化更新模型
-- 坐骑幻化buff
-- 坐骑激活
-- 收回激活幻化坐骑
-- 设置坐骑属性
-- 坐骑升级升阶

-- 获取子目录
local page_list,page_map
S:Event()
function S:onLoad()
    page_list = S:GetServeList('page')
    page_map = {}
    for _, v in ipairs(page_list) do
        v.ShowName = v.__NAME
        page_map[v.ShowName] = v
    end
end


--     "<Img|x=155|y=36|w=1050|bg=1|show=0|reset=1|i=ui://Custom/npc_img_1|move=0|loadDelay=1>",
--     "<Img|x=155|y=83|w=1050|h=620|i=ui://Mount/zqbg>",
--     "<Button|x=1163|y=36|ni=ui://Custom/btn_close_3|link=@exit>",
--     "<Text|x=645|y=46|t=坐骑|c=255|s=20>"

-- 基础框架
function UI:MountViewBg(page)
    page = page or self.__NAME
    local ids = {}
    for i, v in ipairs(page_list) do
        local uiid = 'menu_' .. i
        ids[#ids+1] = uiid
        local y = (i-1) * 95 + 45   -- 改为纵向排列，如灵宠
        local active = v.__NAME == page
        self:AddUI{
            "<Button|id=",uiid,"|children=",uiid,"_str|ay=0.5|y=",y,"|nimg=ui://fulidating/lv-youceanniu", active and '' or '-an', '|link=@',v.__NAME,">",
            "<Text|id=",uiid,"_str|show=4|text=",v.__NAME,"|width=0|outline=1|color=",active and 255 or 10 ,"|size=24|offset=-12#12>"
        }
        self:SetWinCache(v.__NAME)
    end
    self:AddUI{
        "<Layout|children=bg,",c(ids),"|percentx=100|offset=-10|y=80>",
    }
    if self.player:isPC() then
        self:AddScript"FGUI:setScale(WIN, 0.8, 0.8)"
    end
    self:LingChongZB_PushWinCache()
    self:AddCloseLayout()
    self:CreateBG2(nil, nil, '坐骑', nil)   -- 用标准背景替换手动创建的背景
    self:Win_FadeIn()
end

function S:Main()
    self.player:Call(page_list[1].__NAME)
end


S:Event()
function S:onMountLevelUp()
    return GameEvent and GameEvent.push and GameEvent.push('onMountLevel', self.player.obj, self.player:gethumvar(VarCfg.U_All_Mount_star))
end
S:Event()
function S:ToggleMount()
    -- 调用上下马逻辑 + 刷新按钮
    self.player:Call("上下马:UpDownHorse")
end

-- 以下获取幻化模块所需信息
-- 获取基础信息
function Serve:GetMountInfo(id)
    if id then return mountModel[id] end
    return mountInfo, mountModel
end

function Serve:GetMountData(id)
    local data = self.player.Var["幻化数据-" .. id]
    if type(data.id) ~= "number" then
        data.id = tonumber(data.id)
        data:Save()
    end
    return data
end

return S