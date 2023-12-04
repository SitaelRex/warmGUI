local content = {}

local createContent = function(self, params)
    local result = {}
    -- local params = params or {}
    --базовые параметры элемента
    result.x = 0
    result.y = 0
    result.w = 0
    result.h = 0

    result.relevantX = nil
    result.relevantY = nil
    result.relevantW = nil
    result.relevantH = nil
    result.fill = false
    result.layer = 1
    result.baseLayerIndex = nil -- индекс до перемещение в топ

    --произвольные параметры извне, не обрабатываемые функционалом этого объекта
    --for parameterName, parameterValue in pairs(params) do
    --    result[parameterName] = parameterValue
    --end

    return result
end


--integration methods
content.set = function(self, param, value)
    self[param] = value
end

content.setRelevant = function(self, param, value)
    if param == "x" then
        self.relevantX = value
    end
    if param == "y" then
        self.relevantY = value
    end
    if param == "w" then
        self.relevantW = value
    end
    if param == "h" then
        self.relevantH = value
    end
end

content.setFillMode = function(self, value)
    self.fill = value
end

setmetatable(content, { __call = createContent })
return content
