local uiElement = {}

local identityStorage = {}

local dumpIdentity = function()
    local i = 0
    for k, v in pairs(identityStorage) do
        i = i + 1
    end
    -- print(i)
end

local destroyByIdentity = function(self, identity)
    if identityStorage[identity] then
        identityStorage[identity]:destroy()
    end

    -- print("destroy by id")
end

local getByIdentity = function(self, identity)
    return identityStorage[identity]
end

local onCreate = function(self)
    self:setIdentity(self.identity.name)
    self:setCords({ x = self.content.x, y = self.content.y })
    self:setSize({ w = self.content.w, h = self.content.h })
end

local destroy = function()
    --определяется в sceneService
end

local onDestroy = function(self)
    --print(2)
    identityStorage[self.identity.name] = nil

    --  dumpIdentity()
    -- destroyCallback(self)
end

local setSize = function(self, size)
    self.content.w = size.w
    self.content.h = size.h
    -----------------------------------------------------
    if self.parent then
        if self.content.relevantW and self.content.relevantW ~= nil then
            local xDiff = self.content.x - self.parent.content.x

            if self.content.relevantW > 1 then
                self.content.w = self.content.relevantW
            elseif self.content.relevantW < 0 then
                self.content.w = (self.parent.content.w + self.content.relevantW) - xDiff
            elseif self.content.relevantW >= 0.1 then
                self.content.w = self.parent.content.w * self.content.relevantW
            end
        end

        if self.content.relevantH and self.content.relevantH ~= nil then
            local yDiff = self.content.y - self.parent.content.y
            -- self.content.h = (self.parent.content.h + self.content.relevantH) - yDiff
            if self.content.relevantH > 1 then
                self.content.h = self.content.relevantH
            elseif self.content.relevantH < 0 then
                self.content.h = (self.parent.content.h + self.content.relevantH) - yDiff
            elseif self.content.relevantH >= 0.1 then
                self.content.h = self.parent.content.h * self.content.relevantH
            end
        end
    end

    --if self.content.fill == true and self.parent then
    --    local xDiff = self.content.x - self.parent.content.x
    --    local yDiff = self.content.y - self.parent.content.y

    --    local selfW = self.content.w
    --    local parentW = self.parent.content.w
    --    self.content.w = selfW < parentW and selfW or parentW - xDiff


    --    local selfH = self.content.h
    --    local parentH = self.parent.content.h
    --    self.content.h = selfH < parentH and selfH or parentH - yDiff
    --end



    if self.childs then --relevant handle
        for _, child in pairs(self.childs) do
            local x = nil
            local y = nil

            --if child.content.relevantW then
            --  child.content.w = child.parent.content.w + child.content.relevantW
            -- end

            if child.content.relevantX then
                --local modeX = child.content.relevantX > 1

                if child.content.relevantX > 1 then
                    x = self.content.x + child.content.relevantX
                elseif child.content.relevantX >= 0 then
                    x = self.content.x + self.content.w * child.content.relevantX
                else
                    x = self.content.x + self.content.w +
                        child.content.relevantX
                end
                --x = modeX and self.content.x + child.content.relevantX or
                --    self.content.x + self.content.w +
                --    child.content.relevantX
            end

            if child.content.relevantY then
                if child.content.relevantY > 1 then
                    y = self.content.y + child.content.relevantY
                elseif child.content.relevantY >= 0 then
                    y = self.content.y + self.content.h * child.content.relevantY
                else
                    y = self.content.y + self.content.h +
                        child.content.relevantY
                end
                --local modeY = child.content.relevantY >= 0
                --y = modeY and self.content.y + child.content.relevantY or
                --    self.content.y + self.content.h +
                --    child.content.relevantY
            end

            --    if x ~= 0 or y ~= 0 then
            child:setCords({ x = x or child.content.x, y = y or child.content.y })
            --  end
            child:setSize({ w = child.content.w, h = child.content.h })
            --         { x = x, y = y })
            -- if x ~= 0 or y ~= 0 then
            --     child:setCords({ x = 0, y = 0 },
            --         { x = x, y = y })
            --     -- else
            --     -- child:setCords({ x = child.content.x, y = child.content.y })
            -- end
        end
    end
end

local setCords = function(self, cords, cachedCords)
    local cachedCords = cachedCords or {
        x = cords.x - self.content.x,
        y = cords.y - self.content.y
    }


    self.content.x = self.content.x + (cachedCords.x)
    self.content.y = self.content.y + (cachedCords.y)

    if #self.childs > 0 then
        for _, child in pairs(self.childs) do
            --   print(3, child)
            child:setCords(cords, cachedCords)
        end
    end
end

local setIdentity = function(self, identity)
    self.identity.name = identity
    identityStorage[identity] = self
end

local convertToPresentation = function(self)
    --   return { content = self.content or {}, variables = self.variables or {} }
end

local createUiElement = function(self)
    local result = {}

    result.parent = nil
    result.childs = {}
    result.sceneIndex = nil

    result.onCreate = onCreate
    result.onDestroy = onDestroy
    result.destroy = destroy

    result.setCords = setCords
    result.setSize = setSize

    result.setIdentity = setIdentity
    result.convertToPresentation = convertToPresentation
    return result
end

uiElement.integrateApiUI = { getByIdentity = getByIdentity, destroy = destroyByIdentity }

setmetatable(uiElement, { __call = createUiElement })

return uiElement
