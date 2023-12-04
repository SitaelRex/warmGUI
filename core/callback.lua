local callback = {}

local createCallback = function(self, params)
    local result = {}
    result.callbacks = {}
    result.params = {}
    result.renderCallback = nil
    setmetatable(result, {
        __index = function(callbackModule, callbackName)
            return callbackModule.callbacks[callbackName] and function(self, ...)
                return callbackModule.callbacks[callbackName](self, callbackModule.params[callbackName] or {}, ...)
            end or nil
        end
    })
    return result
end

callback.defCallback = function(self, callbackName, func, params)
    self.callbacks[callbackName] = func
    self.params[callbackName] = params
end

callback.defRenderCallback = function(self, func, params)
    self.renderCallback = function(entityself, ...) return func(entityself, params or {}, ...) end
end

setmetatable(callback, { __call = createCallback })
return callback
