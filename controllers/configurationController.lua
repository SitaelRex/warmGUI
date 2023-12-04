local PATH = (...):gsub('%/[^%/]+$', '')
local ROOT = PATH:gsub('%/[^%/]+$', ''):gsub('%/[^%/]+$', '')
local abstractController = require(PATH .. "/abstractController")

local configurationController = abstractController()


local configurationService = require(ROOT .. "/services/configurationService")


local callbackConfiguration = {}

local callbackConfigResponseHandle = function(data)
    callbackConfiguration = data
end


local handleConfig = function(config)
    configurationController:send("callbackConfigRequest")
    --configurationController:send("callbackConfigurate", callbackConfiguration)


    local callbacksList = {}
    for k, v in pairs(callbackConfiguration) do
        callbacksList[k] = k
    end

    config.callbacks = callbacksList

    configurationService:setBuilder(configurationService:configureBuilder(config.extensionModules))
    configurationController:send("configuredBuilder", configurationService:getBuilder())
    configurationController:send("elementTypesSpawn", config.elementTypes)
    configurationController:send("sceneSpawn", config)
end

configurationController.subscriptions["config"] = handleConfig
configurationController.subscriptions["callbackConfigResponse"] = callbackConfigResponseHandle
--configurationController.subscriptions["integrateUiApi"] = integrateUiApi

return configurationController
