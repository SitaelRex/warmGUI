local PATH = (...):gsub('%/[^%/]+$', '')
local ROOT = PATH:gsub('%/[^%/]+$', ''):gsub('%/[^%/]+$', '')
local abstractController = require(PATH .. "/abstractController")

local uiApiController = abstractController()

local uiApiService = require(ROOT .. "/services/inputService")
local inputCords = { x = 0, y = 0 }
local overlapped = nil
local uiApi = {}
local integrateUiApi = function(data)
    for k, v in pairs(data) do
        uiApi[k] = v
    end
end

local initApi = function()
    uiApiController:send("uiApi", uiApi)
end

local setInputCords = function(data)
    inputCords.x = data.x
    inputCords.y = data.y
end

local setOverlapped = function(data)
    overlapped = data
end

uiApi.getInputCords = function(self)
    return inputCords
end

uiApi.getOverlapped = function(self)
    return overlapped
end

--local integrateUiApi = function(data)
--    uiApiService:integrateUiApi(data)
--end
uiApiController.subscriptions["uiApiOverlapped"] = setOverlapped
uiApiController.subscriptions["uiApiInputCords"] = setInputCords
uiApiController.subscriptions["integrateUiApi"] = integrateUiApi
uiApiController.subscriptions["uiApiInit"] = initApi


return uiApiController
