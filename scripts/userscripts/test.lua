function try(block)

    -- get the try function
    local try = block[1]
    assert(try)

    -- get catch and finally functions
    local catch = block.catch
    local finally = block.finally

    -- try to call it
    local ok, errors = pcall(try)
    if not ok then
        -- run the catch function
        if catch then
            catch(errors)
        end
    end

    -- run the finally function
    if finally then
        finally(ok, errors)
    end

    -- ok?
    if ok then
        return errors
    end
end

-- try{
--     function()
--         print("try")
--         error("error")
--     end,
--     catch = function(errors)
--         print("catch", errors)
--     end,
--     finally = function(ok, errors)
--         print("finally", ok, errors)
--     end
-- }

print(package.path)
local path = 'test2'
local ff = require(path)
-- ff.GBPtest()

-- GBPtest()