local containerLockout = {}

containerLockout.funcToPass = {}
containerLockout.funcOrigins = {}

---@param func Function
function containerLockout.addFunction(func)
    if not type(func)=="function" then print("WARN: containerLockout.addFunction: tried to add:"..tostring(func).."("..type(func)..")") end

    local coroutine = getCurrentCoroutine()
    local count = getCallframeTop(coroutine)
    local modID = "unknown source"
    for i= count - 1, 0, -1 do
        local o = getCoroutineCallframeStack(coroutine,i)
        if o ~= nil then
            local s = KahluaUtil.rawTostring2(o)
            if s then
                local modFile = s:match(".* | MOD: (.*)")
                if modFile then modID = modFile end
            end
        end
    end

    table.insert(containerLockout.funcToPass, func)
    table.insert(containerLockout.funcOrigins, modID)
end

---Validates if the mapObject can be interacted with
function containerLockout.canInteract(mapObject, player)
    if not mapObject then return true end

    --Assumed behavior is that you can see/interact with the container
    local canView = true

    for index,func in pairs(containerLockout.funcToPass) do

        local returnedValue = func(mapObject, player)
        if returnedValue==nil then print("WARN: containerLockout.canInteract: "..containerLockout.funcOrigins[index].." added function with no returned value.") end
        if type(returnedValue)~="boolean" then print("WARN: containerLockout.canInteract: "..containerLockout.funcOrigins[index].." added function returning a non-boolean.") end

        --if any functions return false canView must be set to false
        if type(returnedValue)=="boolean" and returnedValue==false then canView = false end
    end

    return canView
end

return containerLockout

--[[
How To Use:

---Define local copy of `containerLockout` using require
local containerLockout = require "containerLockout-shared"

local function func(mapObject, player)
    --add conditions here, for example:
    if player:getModData().blockView == true then return false end
end

containerLockout.addFunction(func)
--]]

