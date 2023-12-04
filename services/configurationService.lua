local PATH = (...):gsub('%/[^%/]+$', '')
local ROOT = PATH:gsub('%/[^%/]+$', ''):gsub('%/[^%/]+$', '')

local builder
--local coreModules

local configurationService = {}

local builderTemplate = require(ROOT .. "/wrappers/builder")
local modules = {
    callback = require(ROOT .. "/core/callback"),
    content = require(ROOT .. "/core/content"),
    --flag = require(ROOT .. "/core/flag"),
    identity = require(ROOT .. "/core/identity"),
    variables = require(ROOT .. "/core/variables"),
    collision = require(ROOT .. "/core/collision")
    --stateMachine = require(ROOT .. "/core/stateMachine"),
}

local handleExtensions = function(extensionModules)
    if type(extensionModules) == "table" then
        for modName, mod in pairs(extensionModules) do
            modules[modName] = mod
        end
    end
end


local configureBuilder = function(serviceSelf, extensionModules)
    local result = builderTemplate
    local builderFunctions, moduleFunctionDictionary = builderTemplate:getInstanceConfig()

    -- handleExtensions(extensionModules)

    local moduleInstances = {}


    for moduleName, moduleTemplate in pairs(modules) do
        moduleInstances[moduleName] = moduleTemplate
        if type(moduleTemplate) == "table" then
            for funcName, func in pairs(moduleTemplate) do
                local configuredfunc = function(self, ...)
                    func(self.buildableElement[moduleName], ...)
                    return self
                end
                builderFunctions[funcName] = configuredfunc
                moduleFunctionDictionary[moduleName] = funcName
            end
        end
    end

    result:setModuleTemplates(moduleInstances)

    result.tag = "builder"
    return result
end

local setBuilder = function(self, configuredbuilder)
    assert(configuredbuilder.tag == "builder", "builder must have tag 'builder'")
    builder = configuredbuilder
end

local getBuilder = function(self)
    return builder
end

configurationService.setBuilder = setBuilder
configurationService.getBuilder = getBuilder
configurationService.configureBuilder = configureBuilder
return configurationService
