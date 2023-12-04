local builder = {}

-- инстансы билдера обращаются в это конфигурируемое хранилище
local builderFunctions = {}
local moduleFunctionDictionary = {}
local moduleInstances = {}

local insert = function(self, buildable)
    self.buildQueue[#self.buildQueue + 1] = buildable
    return self
end

local complete = function(self)
    local results = {}
    self:defCallback("onCreateB", self.buildableElement.onCreate)
    --self:defCallback("onDestroyB", self.buildableElement.onDestroy)
    results[#results + 1] = self.buildableElement
    for i = 1, #self.buildQueue do
        local completeResult = self.buildQueue[i]:complete()
        completeResult[1].parent = results[1]
        for j = 1, #completeResult do
            results[#results + 1] = completeResult[j]
        end
    end
    return results
end

local builderFunctionsSearch = function(t, k)
    return builderFunctions[k] or builderFunctions[moduleFunctionDictionary[k]]
end

local create = function(self, buildableElement)
    local result = {}
    result.buildQueue = {} --для обработки в обратном порядке
    result.buildableElement = buildableElement()
    for k, v in pairs(moduleInstances) do
        --print(k, v)
        result.buildableElement[k] = v()
        -- v(self, result.buildableElement)
    end
    setmetatable(result, { __index = builderFunctionsSearch })
    return result
end

local outOfUsesNumber = function()
    error("function 'builder.getInstanceFunctions' may be called only one time per builder instance in configuration")
end

local getInstanceConfig = function(self)
    --одноразовая функция для конфигурации
    builder.getInstanceFunctions = outOfUsesNumber
    return builderFunctions, moduleFunctionDictionary
end

local setModuleTemplates = function(self, modules)
    moduleInstances = modules
end

--builderFunctions.insert = insert
builderFunctions.complete = complete
builderFunctions.insert = insert

builder.setModuleTemplates = setModuleTemplates
builder.getInstanceConfig = getInstanceConfig
setmetatable(builder, { __call = create })

return builder
