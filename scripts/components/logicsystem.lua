LOGIC_TICK = 5 * FRAMES -- 每5帧为一个时钟刻
LOGIC_TICK = 1 -- 每1s更新一次(debug)

local LogicSystem = Class(function (self, inst)
    self.inst = inst
    self._task = nil
    self.LOGIC_GROUP = {} -- 储存所有逻辑组件
end)

--[[
    每个逻辑组件都需要实现Update方法
]]
function LogicSystem:MainLoop()
    print("MainLoop Start")
    for k, v in pairs(self.LOGIC_GROUP) do
        if v.Update then
            v:Update()
        end
    end
    print("MainLoop End")
end

function LogicSystem:StartSimulate()
    self._task = self.inst:DoPeriodicTask(LOGIC_TICK, function()
        self:MainLoop()
    end)
end

function LogicSystem:StopSimulate()
    if self._task then
        self._task:Cancel()
    end
end

return LogicSystem