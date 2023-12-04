local variables = {}

local set = function(self, varname, varvalue)
    self.storage[varname] = varvalue
end

local get = function(self, varname)
    return self.storage[varname]
end

local defineVariables = function(self)
    local result = {}
    result.storage = {}
    result.get = get
    result.set = set
    return result
end

variables.variable = function(self, varname, varStartValue)
    --print(varname, varStartValue)
    self:set(varname, varStartValue)
end

setmetatable(variables, { __call = defineVariables })

return variables
