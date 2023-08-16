--[[
    这里实现一个电子元件的功能
]]
local logicParts = Class(function(self, inst)
    self.inst = inst
    -- self.inst:AddTag("logicgates")
    self.inpins = {}
    self.outpins = {}
    self.logicfn = nil
    
end)

-- 设置引脚
function logicParts:SetPins(pinTable)
    -- self.pins = {
    --     {num = 0, type = in, posx = -1, posz = -1},
    --     {num = 1, type = out, posx = 1, posz = -1},
    --     { ... },
    -- }
    -- self.inpins = {
    --     {num = 0, value = 0},
    -- }
    for key, value in pairs(pinTable) do
        if value.type == "in" then
            self.inpins[value.num] = 0
        elseif value.type == "out" then
            self.outpins[value.num] = 0
        end
    end
    self.pins = pinTable
end

-- 设置逻辑函数
function logicParts:logicfn(...) end

function logicParts:ReadInput()
    
end

-- 读取引脚现在时刻的值
function logicParts:ReadInpin(pinNum)
    -- self.
end

-- 当引脚接入的值发生变化时，重新读取引脚的值，计算逻辑，输出结果
function logicParts:OnInpinChanged(inpinnum)
    -- self:
end
