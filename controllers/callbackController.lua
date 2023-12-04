local PATH = (...):gsub('%/[^%/]+$', '')
local ROOT = PATH:gsub('%/[^%/]+$', ''):gsub('%/[^%/]+$', '')
local abstractController = require(PATH .. "/abstractController")

local callbackController = abstractController()

local callbackService = require(ROOT .. "/services/callbackService")

local configRequestHandle = function()
    local config = callbackService:getCallbackConfig()
    callbackController:send("callbackConfigResponse", config)
end
local configurate = function(data)
    --  callbackService:configureCallbacks(data)
end
callbackController.subscriptions["callbackConfigRequest"] = configRequestHandle
--callbackController.subscriptions["callbackConfigurate"] = configurate
callbackController.subscriptions["uiApi"] = callbackService.handleUiApi
callbackController.subscriptions["callbackHandle"] = callbackService.handleCallback
callbackController.subscriptions["insertIntoCallbacks"] = callbackService.listenElement
callbackController.subscriptions["removeFromCallbacks"] = callbackService.removeFromListen
callbackController.subscriptions["updateHover"] = function(data)
    callbackService.updateHover(data)
    callbackController:send("uiApiOverlapped", callbackService.getOverlapped())
end

return callbackController
