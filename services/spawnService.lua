local PATH = (...):gsub('%/[^%/]+$', '')
local ROOT = PATH:gsub('%/[^%/]+$', ''):gsub('%/[^%/]+$', '')

local uiElement = require(ROOT .. "/wrappers/uiElement")
local builder
local elementTypes = {}
local spawnService = {}

local spawn = function(elementTable)
    --print(1)
    --local buildable = builder(uiElement)
    --for moduleName, moduleTable in pairs(elementTable.modules) do
    --    if elementTable.elementType then
    --        buildable = elementTypes[elementTable.elementType](buildable)
    --    end
    --    for paramName, paramValue in pairs(moduleTable) do
    --        buildable = buildable[moduleName](buildable, paramName, paramValue)
    --    end
    --end
    --local result = buildable:complete()
    local builderFactory = function()
        return builder(uiElement)
    end

    local results = elementTable(builderFactory):complete()
    -- print(result.hierarchy)
    return results
end

local spawnScene = function(self, data)
    local scene = data.scene
    -- data.initFunc(builder(uiElement))
    local spawned = {}
    for index, elementTable in pairs(scene.elements) do
        local spawnResult = spawn(elementTable)
        for i = 1, #spawnResult do
            -- spawnResult[i]:onCreate()
            spawned[#spawned + 1] = spawnResult[i]
            --print(spawnResult[i].content)
        end
    end
    return spawned
end

local newSpawned = {}

local getNewSpawned = function(self)
    return newSpawned
end

local clearNewSpawned = function(self)
    newSpawned = {}
end

local handleIntegration = function()
    local uiApiIntegration = {}


    for k, v in pairs(uiElement.integrateApiUI) do
        uiApiIntegration[k] = v
    end



    uiApiIntegration.spawn = function(self, elementTable, targetName)
        -- print(targetName)
        local results = spawn(elementTable)
        local spawned = {}
        for i = 1, #results do
            -- spawnResult[i]:onCreate()

            spawned[#spawned + 1] = results[i]
            -- print(results[i].content.w)
            --print(spawnResult[i].content)
        end

        local target = self:getByIdentity(targetName)
        -- print(target)
        if target then
            spawned[1].parent = target
        end


        -- print(results)
        -- callback(spawned, true)
        newSpawned = spawned
    end

    uiApiIntegration.detach = function(self, targetName)
        local target = self:getByIdentity(targetName)
        if target then
            target:detach()
        end
    end

    uiApiIntegration.attach = function(self, currentName, targetName)
        local current = self:getByIdentity(currentName)
        local target = self:getByIdentity(targetName)
        --print(targetName)
        current:detach()
        target:attach(current)
        -- current.parent = target
    end

    --end

    --print(uiApiIntegration.spawn)

    return uiApiIntegration
end



local getUiApiIntegration = function(self)
    return handleIntegration()
end

local defineBuilder = function(self, configuredBuilder)
    builder = configuredBuilder
end



local defElementTypes = function(self, types)
    for typeName, typeIncompletedBuilder in pairs(types) do
        elementTypes[typeName] = typeIncompletedBuilder
    end
end

spawnService.defineBuilder = defineBuilder
spawnService.spawnScene = spawnScene
spawnService.defElementTypes = defElementTypes
spawnService.getUiApiIntegration = getUiApiIntegration
spawnService.getNewSpawned = getNewSpawned
spawnService.clearNewSpawned = clearNewSpawned

return spawnService
