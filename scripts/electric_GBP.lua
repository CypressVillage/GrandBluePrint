--[[
    在这里定义一个电路系统。。。
]]--

local _G = GLOBAL
-- local WORLD_MAX_RANGE = 9999 -- 为了寻找全图的电源

local id = 0 -- 分配系统的全局ID，表的索引从1开始
local ELECTRIC_SYS_WIRES_GUID = {} -- 用于注册过程中保存已注册的导线
_G.ELECTRIC_SYS = {} -- 电路系统的GUID保存在这里，每个系统格式见emptySys

local emptySys = {
    powers = {},
    consumers = {},
    wires = {}
} -- 不要使用！Lua对表是引用传递！

-- 用于建立电源和用电器的Action关系
local function LINK_ACTIONS_BY_ID(id)
    
end

-- 找到电线相连接的部分，只用于电线，返回的是物体
_G.getLinkedThings = function(obj) dbg('getLinkedThings')
    if not obj:HasTag('wire') then dbg('不是电线') end

    local linkThings = {
        wires = {
            up = nil,
            down = nil,
            left = nil,
            right = nil,
        },
        powers = {},
        consumers = {},
    }
    local x, y, z = obj:GetPosition():Get()
    dbg('position:x='..tostring(x)..', z='..tostring(z))
    -- 找电线
    local neighbors = TheSim:FindEntities(x,0,z, 1, {'wire'})
    for key, neighbor in pairs(neighbors) do
        -- 旁边的物体坐标
        local nx, ny, nz = neighbor:GetPosition():Get()
        -- 排除自己
        if neighbor.GUID ~= obj.GUID then
            local dx, dz = nx-x, nz-z
            if dx == 1 and dz == 0 then
                linkThings.wires.down = neighbor
            elseif dx == -1 and dz == 0 then
                linkThings.wires.up = neighbor
            elseif dx == 0 and dz == 1 then
                linkThings.wires.right = neighbor
            elseif dx == 0 and dz == -1 then
                linkThings.wires.left = neighbor
            end
        end
    end
    -- 找用电器和电源
    local neighbors = TheSim:FindEntities(x,0,z, 1.5, {'power'})
    for key, neighbor in pairs(neighbors) do dbg('找电源，找到了'..tostring(neighbor.GUID))
        table.insert(linkThings.powers, neighbor)
    end
    local neighbors = TheSim:FindEntities(x,0,z, 1.5, {'consumer'})
    for key, neighbor in pairs(neighbors) do
        table.insert(linkThings.consumers, neighbor)
    end

    return linkThings
end

-- 返回物体所在系统的ID，返回0代表没有注册，同样只用于电线
local function getIDfromSys(obj)
    dbg('>>getIDfromSys')
    local rtnID = 0
    for id, sys in pairs(ELECTRIC_SYS) do
        if findIndex(obj.GUID, sys.powers) ~= 0
        or findIndex(obj.GUID, sys.wires) ~= 0
        or findIndex(obj.GUID, sys.consumers) ~= 0 then
            dbg('the id is '..tostring(id)..'<<getIDfromSys')
            return id
        end
    end
    dbg('<<getIDfromSys')
    return rtnID
end

-- 获取一个物体周围连接的所有系统，返回这些系统的ID，只看电线
local function getLinkMutiSys(node)
    dbg('>>获取连接了几个系统')
    local rtnID = {}
    local neighbors = getLinkedThings(node).wires
    if neighbors ~= nil then
        for _, neighbor in pairs(neighbors) do
            local nid = getIDfromSys(neighbor)
            if nid ~= 0 and findIndex(nid, rtnID) == 0 then
                table.insert(rtnID, nid)
            end
        end
    end
    dbg('连接的系统个数：'..tostring(getTableSize(rtnID)))
    dbg('<<获取连接了几个系统')
    return rtnID
end

-- 删除一个电路系统，为了一丢丢的可读性牺牲一丢丢的性能
local function delSysByID(id)
    ELECTRIC_SYS[id] = nil
end

-- 将几个电路系统合并成一个，返回新系统的ID
local function mergeSysByID(ids) dbg('mergeSysByID')
    local newSys = {
        wires = {},
        powers = {},
        consumers = {},
    }
    
    -- 复制完就删除
    for _, id in pairs(ids) do dbg('合并系统id：'..tostring(id))
        for _, item in pairs(ELECTRIC_SYS[id].powers) do
            table.insert(newSys.powers, item)
        end
        for _, item in pairs(ELECTRIC_SYS[id].wires) do
            table.insert(newSys.wires, item)
        end
        for _, item in pairs(ELECTRIC_SYS[id].consumers) do
            table.insert(newSys.consumers, item)
        end
        delSysByID(id)
    end
    
    -- 默认就占第一个吧，空出来的俺就不管了
    ELECTRIC_SYS[ids[1]] = newSys
    dbg('将新系统存到'..tostring(ids[1]))
    
    return ids[1]
end

-- 图的遍历，同样只用于电线
local function dfs(node, id)
    local linkednodes = getLinkedThings(node)
    -- 防止遍历回去
    if findIndex(node.GUID, ELECTRIC_SYS[id].wires) ~= 0 then
        return
    end
    -- 注册并遍历
    table.insert(ELECTRIC_SYS[id].wires, node.GUID)
    if linkednodes.powers then
        for _, power in pairs(linkednodes.powers) do
            dbg('电源：'..tostring(power.GUID))
            if findIndex(power.GUID, ELECTRIC_SYS[id].powers) == 0 then
                table.insert(ELECTRIC_SYS[id].powers, power.GUID)
            end
        end
    end
    if linkednodes.consumers then
        for _, consumer in pairs(linkednodes.consumers) do
            if findIndex(consumer.GUID, ELECTRIC_SYS[id].consumers) == 0 then
                table.insert(ELECTRIC_SYS[id].consumers, consumer.GUID)
            end
        end
    end
    -- 遍历
    local nodestag = { 'left', 'right', 'up', 'down' }
    local nodes = linkednodes.wires
    for _, v in nodestag do
        if nodes[v] ~= nil then
            dfs(nodes[v], id)
        end
    end
end

-- 以导线为单位注册全局的电路系统
local function RegistEleSystembyWire(wire)
    dbg('>>注册新电路')
    -- 如果电源已经被注册过，那么跳过
    if findIndex(wire.GUID, ELECTRIC_SYS_WIRES_GUID) ~= 0 then
        dbg('导线被注册了，不再注册')
        return
    else
        table.insert(ELECTRIC_SYS_WIRES_GUID, wire.GUID)
        id = id + 1
        dbg('注册一个新电路，id为'..tostring(id))
        ELECTRIC_SYS[id] = {
            id = id,
            wires = {wire.GUID},
            powers = {},
            consumers = {}
        }
        dfs(wire, id)
    end
    
    dbg('<<注册新电路完成')
    
end

-- 当有新电路加入后，执行注册或者合并
-- 这里的电路系统是连接上就放到一块了，所以简单，至于信号线。。。
_G.RefreshElectricSys = function(obj) dbg('>>开始更新电路，id为'..tostring(obj.GUID))
    if obj:HasTag('wire') then
        local linkedSysID = getLinkMutiSys(obj)
        -- 把连接的系统全部合并
        if getTableSize(linkedSysID) ~= 0 then dbg('找到了'..tostring(getTableSize(linkedSysID))..'个连接的系统')
            local newSysID = mergeSysByID(linkedSysID)

            table.insert(ELECTRIC_SYS[newSysID].wires, obj.GUID) -- 别忘了把自己注册进去
            local links = getLinkedThings(obj)
            if links.powers then
                for _, v in pairs(links.powers) do
                    table.insert(ELECTRIC_SYS[newSysID].powers, v)
                end
            end
            if links.consumers then
                for _, v in pairs(links.consumers) do
                    table.insert(ELECTRIC_SYS[newSysID].consumers, v)
                end
            end
            dbg(ShowTable(ELECTRIC_SYS))
            LINK_ACTIONS_BY_ID(id)
        else dbg('没有找到系统')
            RegistEleSystembyWire(obj)
        end
    end
    
    dbg('更新电路完成')

end

-- 删除电路后的函数，是inst:remove()的升级版
_G.RemoveObjFromSys = function(inst)
    local sysID = getIDfromSys(inst)
    if sysID ~= 0 then
        local wiresID = ELECTRIC_SYS[sysID].wires

        for _, v in ipairs(wiresID) do
            table.remove(ELECTRIC_SYS_WIRES_GUID, findIndex(v, ELECTRIC_SYS_WIRES_GUID))
        end
        delSysByID(sysID)

        inst:Remove()

        for _, id in pairs(wiresID) do
            if Ents[id] ~= nil then
                _G.RefreshElectricSys(Ents[id])
            end
        end
    end
end

-- 显示全局电路信息
_G.listElectricSysInfo = function()
    dbg('开始寻找全局电路')
    for k, v in pairs(ELECTRIC_SYS) do
        local str = '电路'..tostring(k)..':\n'
        str = str..'电源:'
        for kk, vv in pairs(v.powers) do
            str = str..tostring(vv)..','
        end
        str = str..'\n导线:'
        for kk, vv in pairs(v.wires) do
            str = str..tostring(vv)..','
        end
        str = str..'\n用电器:'
        for kk, vv in pairs(v.consumers) do
            str = str..tostring(vv)..','
        end
        dbg(str)
    end
    dbg('全局电路寻找完毕')
end
