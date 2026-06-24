---@class 坐骑: Serve
local S = Serve("坐骑")


-- 升级阶数
local levelStep = {
    [0] = "零阶","一阶","二阶","三阶","四阶","五阶","六阶","七阶","八阶"
}
-- 升级属性加成
local mountlist = require("Envir/QuestDiary/game_config/cfgcsv/Mount.lua")

-- 默认模型展示
-- 升级按钮
-- 属性展示,属性添加更新
-- 坐骑出战或休息
-- 幻化属性只加成一次，可累加
-- 所有幻化共享一组强化数据
-- 幻化升阶增加属性 一倍
-- 幻化技能不可叠加
-- 升级属性加成
-- 110015 坐骑总属性
-- 110016 坐骑幻化总属性

-- 获取坐骑属性信息
local function parseAttr(mountlist,level)
    local attr = {}
    local cfg = mountlist[level].ClassID or {}
    for k,v in ipairs(cfg) do
        attr[#attr+1] = v[1]..'#'..v[2]
    end
    return f(attr, '&')
end

-- 坐骑当前等级
-- VarCfg.U_All_Mount_star
-- 使用该属性进行升级操作
-- Mount列表获取升级物品消耗以及属性变化

function S:Main()
    -- 获取坐骑当前等级
    local now = self.player:gethumvar(VarCfg.U_All_Mount_star)
    print("当前等级是=======================",type(now),now)
    -- 添加UI界面
    self:CreateUI():MountViewBg()
    self.UI:AddUI{
        -- 主容器 id=app不可以修改
        "<Layout|id=app|fullCenter=1|children=bImg,rightInfo,uselesname,mountModel,testL>",
        "<Img|id=bImg|bg=1|i=ui://Mount/zqbg|percentheight=100|percentwidth=100|show=4>",
        -- 占位符
        "<UIModel|id=testL|percentx=37|percenty=80||job=2|bodyID=31011|headID=1024|faceID=1104|rWeaponID=56037|rotY=10>",
        -- 模型
        -- "<UILegoModel|id=mountModel|a=4|percentx=50|percenty=80|legoid=",mountlist.Model,">",
        -- 右侧信息栏
        "<Layout|id=rightInfo|children=attr1,attr2,levelup|percentheight=100|width=300|ax=1|percentx=100|offset=15>",
        -- 当前属性和下一级属性
        "<Layout|id=attr1|percentwidth=100|percentheight=42|children=_attr1>",
        "<Layout|id=attr2|percentwidth=100|percentheight=42|children=_attr2|percenty=50|offset=0#-65>",
        -- 激活&升级按钮
        "<Layout|id=levelup|children=btn1,itemcost|percentwidth=100|percentheight=16|ay=0|percenty=93>",
        "<Layout|id=itemcost|children=active|percentx=50|percenty=60>",
    }
    self:Ride()
    self:BuildContent()
    self.UI:Show()
end
-- 动态内容构建
function S:BuildContent()
    local now = self.player:gethumvar(VarCfg.U_All_Mount_star)
    self:StarChange(now)
    local hasStar = now and now > 0
    self.UI:AddUI{
    -- 顶部属性名称
    "<Text|id=uselesname|percentx=32|y=30|c=255|t=乌龙驹|s=34>",
    -- "<Button|id=btn|a=4|percentx=38|percenty=93|text=",(mountStatus == 1) and "休息" or "出战","|color=255|nimg=ui://A_EquipDuanZao/tybtn1|outline=1|link=@坐骑:Recall>"
    }
    -- 按钮 + 材料消耗
    if now == #mountlist then
         self.UI:AddUI{
            "<Button|id=btn1|a=4|percentx=50|percenty=100|color=255|text=已满级|nimg=ui://A_EquipDuanZao/tybtn1|outline=1>",
        }
    elseif hasStar and now < #mountlist then 
        -- 升级
        self.UI:AddUI{
            "<Button|id=btn1|a=4|percentx=50|percenty=100|color=255|text=升级|nimg=ui://A_EquipDuanZao/tybtn1|outline=1|link=@坐骑:LevelUp>",
        }:CostItem('active', mountlist[now].Cost[1], mountlist[now].Cost[2])
        self:CreateAttrPanel('_attr2', "下级属性", parseAttr(mountlist, now + 1))
    else
        -- 未激活则激活
        self.UI:AddUI{
            "<Button|id=btn1|a=4|percentx=50|percenty=100|color=255|text=激活|nimg=ui://A_EquipDuanZao/tybtn1|outline=1|link=@坐骑:Active>",
        }:CostItem('active', mountlist[0].Cost[1], mountlist[0].Cost[2])
        self:CreateAttrPanel('_attr2', "下级属性", parseAttr(mountlist, now + 1))
    end
    -- 更新属性,或者显示基础属性
    self:CreateAttrPanel('_attr1', hasStar and "当前属性" or '基础属性', parseAttr(mountlist, now))
end
function S:Ride()
    -- 上下马状态
    local mountStatus = self.player:HorseState()
    if mountStatus == 1 then
        self.UI:AddUI{
            "<Button|id=btn|a=4|percentx=38|percenty=93|text=休息|color=255|nimg=ui://A_EquipDuanZao/tybtn1|outline=1|link=@坐骑:Recall>"
        }
    else
        self.UI:AddUI{
            "<Button|id=btn|a=4|percentx=38|percenty=93|text=出战|color=255|nimg=ui://A_EquipDuanZao/tybtn1|outline=1|link=@坐骑:Recall>"
        }
    end
end
--升级
function S:LevelUp()
    local now = self.player:gethumvar(VarCfg.U_All_Mount_star)
    if now == 0 then return self:Active() end        -- 未激活走激活
    local next = now + 1
    if next > #mountlist then return end
    local costs = mountlist[now].Cost
    local itemId, num = tonumber(costs[1]), tonumber(costs[2])
    if not self.player:CheckBagItemCount(itemId, num) then
        return self.player:SendMsg9("材料不足！")
    end
    self.player:Take(itemId, num)
    -- 写新等级属性
    local classIds = mountlist[next].ClassID
    for i = 1, #classIds do
        self.player:setbuffabil(110015, tonumber(classIds[i][1]), "=", tonumber(classIds[i][2]))
    end
    self.player:sethumvar(VarCfg.U_All_Mount_star, next)
    local mountBaseId = mountlist[next].Model
    if self.player:gethumvar(VarCfg.U_Mount_IS_HH) == 0 then
        self.player:changeappear(5, mountBaseId)
        self.player:sethumvar(VarCfg.U_Mount_Take_Id, mountBaseId)
    end
    self.player:sethumvar(VarCfg.U_Mount_Base_ID, mountBaseId)

    self.player:SendMsg9("升级成功！")
    self.player:Call(S.__NAME)
    self:Trigger("onMountLevelUp")
end

-- 激活
function S:Active()
    local now = self.player:gethumvar(VarCfg.U_All_Mount_star)
    if now ~= 0 then return end                     -- 已激活
    local costs = mountlist[0] and mountlist[0].Cost  -- mountlist[0] = 激活消耗行
    local itemId, num = tonumber(costs[1]), tonumber(costs[2])
    if not self.player:CheckBagItemCount(itemId, num) then
        return self.player:SendMsg9("激活材料不足！")
    end
    self.player:Take(itemId, num)
    -- 初始化坐骑数据（对应 mountMain 50-54行）
    self.player:sethumvar(VarCfg.T_MountHuanHua, tbl2json({}))
    self.player:sethumvar(VarCfg.U_All_Mount_star, 1)
    self.player:sethumvar(VarCfg.U_Mount_IS_SET, 1)
    -- 写一阶属性到 110015
    local classIds = mountlist[1].ClassID
    for i = 1, #classIds do
        self.player:setbuffabil(110015, tonumber(classIds[i][1]), "=", tonumber(classIds[i][2]))
    end
    -- 更新模型外观
    local mountBaseId = mountlist[1].Model
    self.player:changeappear(5, mountBaseId)
    self.player:sethumvar(VarCfg.U_Mount_Take_Id, mountBaseId)
    self.player:sethumvar(VarCfg.U_Mount_Base_ID, mountBaseId)
    self.player:SendMsg9("激活成功！")
    self.player:Call(S.__NAME)
    self:Trigger("onMountLevelUp")
end

-- 升级后星星图标和阶数变化
function S:StarChange(level)
    local starids = {}
    local range = ''
    if level == #mountlist then
        range = levelStep[8]
    elseif level == 0 then
        range = '未激活'
    else
        range = levelStep[level and math.floor(level/10) or ''] or '未激活'
    end
    self.UI:AddUI{
        "<Text|id=rangeId|outline=1|text=",range,"|size=20|percentheight=100|width=20|offset=-18|y=40|color=",level and 251 or 10,">",
    }
    for i = 1, 10 do
        local id = 'star' .. i
        starids[#starids+1] = id
        self.UI:AddUI{
            "<Layout|id=",id,"|children=",id,"_d,",id,"_a|width=40|height=40>",
            "<Img|id=",id,"_d|children=",id,"_a|img=ui://lingchong/xingdi|show=4>",
        }
        if level and level%10 >= i or level>0 and level%10==0 then
            self.UI:AddUI{
                "<Img|id=",id,"_a|children=",id,"_a|img=ui://lingchong/xingliang|show=4>",
            }
        end
    end
    self.UI:AddUI{
        "<Layout|id=step|children=redImg|percentx=14|y=60|width=52|height=130>",
        "<Img|id=redImg|children=rangeId|bg=1|i=ui://Mount/jsbg|offset=-5>",
        "<ListView|id=xList|children=",c(starids),"|width=",#starids*40,"|height=40|cantouch=0|direction=2|ax=0.5|percentx=40|y=138>",
    }
end

-- 添加侧边属性面板
function S:CreateAttrPanel(id, title, attr)
    if attr then 
        self.UI:GetTitleUI(id.."_title", title, "percentx=50|y=25") 
        -- print("======================================")
        -- print(id,title,type(attr),attr)
        -- print("======================================")
        local ids = {}
        for i, v in ipairs(Util:AttrParse(attr)) do
            local uid = id .. 'attr_' .. i
            ids[#ids+1] = uid
            local name = v.attName
            if #name == 4 then
                name = name:sub(1, 2) .. "　" .. name:sub(3)
            end
            -- 属性方面信息
            self.UI:AddUI{
                "<",i%2>0 and 'Layout' or 'Img|img=ui://Mount/属性文字底',"|percentwidth=100|id=",uid,"|height=30|children=",uid,"_attName,",uid,"_attVal>",
                "<Text|outline=1|id=",uid,"_attName|text=",name,"：|x=30|ay=0.5|percenty=50|size=18|color=255>",
                "<Text|outline=1|id=",uid,"_attVal|text=",v.attVal,"|offset=-30|ax=1|percentx=100|ay=0.5|percenty=50|size=18|color=255>",
            }
        end
        self.UI:AddUI{
            "<ListView|id=",id,"_list|fullCenter=1|children=",c(ids),"|sizeDiff=0#-20|cantouch=0>"
        }
    end
    self.UI:AddUI{
        "<Layout|id=",id,"|children=",id,"_title,",id,"_lay|fullCenter=1>",
        "<Img|id=",id,"_lay|children=",id,"_list|img=ui://Mount/sxbg|ax=0.5|percentx=50|percentwidth=85|percentheight=100|sizeDiff=0#-50|y=45>",
    }
end

-- 乘骑
function S:Recall()
    local mountId = self.player:gethumvar(VarCfg.U_Mount_Take_Id)
    self.player:changeappear(5,mountId)
    self.player:updownhorser()
    local baseSpeed = self.player:scriptabil(9)
    if self.player:horsestate() == 0 then
        self.player:setscriptabilvalue(9, "=", baseSpeed-5000)
    else
        self.player:setscriptabilvalue(9, "=", baseSpeed+5000) 
    end
    self.player:sethumvar(VarCfg.U_Mount_Status,selp.player:horsestate())
    self:Ride()
end


return S