---@class 幻化: Serve
local S = Serve("幻化")


function S:Main(mountId)
    -- 根据等级判断坐骑是否激活
    local now = self.player:gethumvar(VarCfg.U_All_Mount_star)
    if not now or now == 0 then
        self.player:SendMsg9("还没有激活坐骑")
        return
    end
    local mountInfo, mountModel = self:GetMountInfo()
    mountId = tonumber(mountId)
    -- 创建主体框架
    self:CreateUI():MountViewBg()

    -- -- 渲染侧边拦
    -- for i, cfg in ipairs(mountInfo) do
    --     local id = 'mount_' .. i
    -- -- 侧边栏
    --     self.UI:AddUI{
    --         "<Img|id=",id,"|children=",id,"_iconbg,",id,"_name,",id,"_lv,",id,"_cur|percentwidth=100|img=ui://fulidating/xialaneirong",cfg.ID == ls_id and 'di' or f{'kuang', "|link=@灵宠,",cfg.ID},">",
    --         "<Img|id=",id,"_iconbg|children=",id,"_icon|img=ui://fulidating/000",data.lv and 2 or 1,"|a=4|percenty=50|x=40>",
    --         "<Img|id=",id,"_icon|img=ui://Mount/",cfg.Pet_Icon,"|show=4|Scale=0.5|grey=",data.lv and 0 or 1,">",
    --         "<Text|id=",id,"_name|outline=1|text=",cfg.Pet_Name,"|size=20|y=8|x=75|color=",data.lv and 251 or 10,">",
    --         "<Text|id=",id,"_lv|outline=1|text=",lv,"|size=20|y=45|x=75|color=",data.lv and 251 or 10,">",
    --     }
    -- end

    self.UI:AddUI{
    -- 主容器 id=app不可以修改
    "<Layout|id=app|fullCenter=1|children=bImg,rightInfo,uselesname,mountModel,testL>",
    "<Img|id=bImg|bg=1|i=ui://Mount/zqbg|percentheight=100|percentwidth=100|show=4>",
    }
    self.UI:Show()
end



return S