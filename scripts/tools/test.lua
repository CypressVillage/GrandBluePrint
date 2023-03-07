function eval(equation, variables)
    if(type(equation) == "string") then
        local eval = loadstring("return "..equation);
        if(type(eval) == "function") then
            setfenv(eval, variables or {});
            return eval();
        end
    end
end
local str = "function aa() return 22 end"

local d = assert(loadstring(str))()

print(aa())--240