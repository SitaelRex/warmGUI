local PATH = (...):gsub('%/[^%/]+$', '')
local ROOT = PATH:gsub('%/[^%/]+$', ''):gsub('%/[^%/]+$', '')
local abstractController = require(PATH .. "/abstractController")

local inputController = abstractController()

local inputService = require(ROOT .. "/services/inputService")

local case = {
    mousepressed = function(data)
        inputService:registerClick()
        inputController:send("callbackHandle", { eventName = "onPress", params = data.params })
        inputController:send("callbackHandle", { eventName = "onTransparentPress", params = data.params })
    end,
    mousereleased = function(data)
        inputService:registerRelease()
        inputController:send("callbackHandle", { eventName = "onRelease", params = data.params })
        inputController:send("callbackHandle", { eventName = "onClick", params = data.params })
        inputController:send("callbackHandle", { eventName = "onTransparentClick", params = data.params })
    end,
    mousemoved = function(data)
        inputController:send("collisionUpdate", { eventName = "onMouseMove", params = data.params })
        inputController:send("uiApiInputCords", data.params)
    end
}

local caseMt = {
    __index = function(t, k) return function() print("unexpected input case:", k) end end
}

setmetatable(case, caseMt)

local emit = function(data)
    -- print(data.eventName)
    case[data.eventName](data)
end

local update = function()
    inputController:send("callbackHandle", { eventName = "update" })
    inputController:send("callbackHandle", { eventName = "onHover" })
    inputController:send("callbackHandle", { eventName = "onTransparentHover" })
    inputController:send("callbackHandle", { eventName = "onNotHover" })

    inputController:send("callbackHandle", { eventName = "onOverlap" })
    inputController:send("callbackHandle", { eventName = "onNotOverlap" })



    inputService:update()
    local status = inputService:isHold()
    if status then
        inputController:send("callbackHandle", { eventName = status })
    end
end

inputController.subscriptions["input"] = emit
inputController.subscriptions["update"] = update

inputController.emit = emit

return inputController
