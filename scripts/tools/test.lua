if loadstring == nil then
    loadstring = load
end

-- function eval(equation, variables)
--     if(type(equation) == "string") then
--         local eval = loadstring("return "..equation);
--         if(type(eval) == "function") then
--             setfenv(eval, variables or {});
--             return eval();
--         end
--     end
-- end

local str = [[
function aa() 
    return 22
end

if aa() == 22 then
    print(23)
end

function bb()
    print(233)
end

function cc()
    print(2333)
end

]]
-- for key, value in pairs(_G) do
--     print(key, value)
-- end
local fn = loadstring(str, 'teee', "bt", _G)
fn()

aa()
bb()
cc()

file = io.open('fname.txt', 'a')
file:write(str)

-- for key, value in pairs(_G) do
--     a = 1
--     print(key, value)
-- end