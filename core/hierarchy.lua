local hierarchy = {}

local defineHierarchy = function(self, params)
    print(self, params)
    local result = {}
    result.builder = self
    print(self)
    result.parent = nil
    result.childs = {}

    return result
end

hierarchy.insert = function(self, buildable)
    self.builder.buildQueue[#self.builder.buildQueue + 1] = buildable
    --print(buildable.childs)
    --self.childs[#self.childs + 1] = buildable
    --child.hierarchy.parent = self
end

setmetatable(hierarchy, { __call = defineHierarchy })
return hierarchy
