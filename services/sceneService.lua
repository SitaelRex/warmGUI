local sceneService = {}

local scene = {}

local elementsRegistry = {}

local callbackInvokers = {}

local recursiveGetDestroyed

recursiveGetDestroyed = function(element, result)
    -- if element.childs then
    -- result[#result + 1] = element
    table.insert(result, 1, element)
    for k, v in pairs(element.childs) do
        recursiveGetDestroyed(v, result)
        --result[#result + 1] = v
    end
    -- end
end

local detached = {}
local getNewDetached = function()
    return detached
end

local defineSelfDistruct = function(registryId)
    local element = elementsRegistry[registryId].element

    elementsRegistry[registryId].element.destroy = function(self)
        local result = {}
        recursiveGetDestroyed(element, result)
        for i = 1, #result do
            table.insert(detached, result[i].parent)
            callbackInvokers:get("onDestroy")(result[i])
            result[i]:onDestroy()
            result[i]:callbackDestroy()
        end
    end

    elementsRegistry[registryId].element.callbackDestroy = function(self, list)
        if elementsRegistry[registryId] then
            local target = elementsRegistry[registryId].target
            local index = elementsRegistry[registryId].index


            table.remove(target, index)

            ---- обработка поломки удаления

            local parentPool = element.parent and element.parent.childs or scene
            local childPool = element.childs




            for i = 1, #parentPool do
                local el = parentPool[i]
                --  print("\t", i, #parentPool, elementsRegistry[el.rindex].index)
                --print("\t", i, #parentPool, elementsRegistry[el.rindex].index)
                elementsRegistry[el.rindex].index = i
                --  print("\t", i, #parentPool, elementsRegistry[el.rindex].index)
                -- callbackInvokers:get("onDestroy")(element)
            end


            --table.remove(elementsRegistry, registryId)
            --print(registryId)

            elementsRegistry[registryId] = nil
        end



        -- dumpScene()
    end
end

local defineSelfSetTopLayer = function(registryId)
    elementsRegistry[registryId].element.setTopLayer = function(self)
        local parentPool = self.parent and self.parent.childs or scene

        local baseIndex = nil

        --print("chick in", parentPool, scene)
        for k, element in pairs(parentPool) do
            --print(k, elementsRegistry[element.rindex].index)
            -- print("checkin in scene", element, self)
            baseIndex = element == self and k or baseIndex
        end

        table.remove(parentPool, baseIndex)
        --print(baseIndex)
        ---- обработка поломки удаления
        --print(baseIndex, #parentPool)
        for i = baseIndex, #parentPool do
            local element = parentPool[i]
            elementsRegistry[element.rindex].index = i
        end

        --sceneService:insertToScene(self)
        table.insert(parentPool, self)
        elementsRegistry[registryId].index = #parentPool
    end
end



local defineDetach = function(registryId)
    elementsRegistry[registryId].element.detach = function(self)
        local parent = self.parent
        local parentPool = self.parent and self.parent.childs or scene
        local baseIndex = nil
        for k, element in pairs(parentPool) do
            --print(k, elementsRegistry[element.rindex].index)
            baseIndex = element == self and k or baseIndex
        end

        table.remove(parentPool, baseIndex)
        --print(baseIndex)
        ---- обработка поломки удаления
        for i = baseIndex, #parentPool do
            local element = parentPool[i]
            elementsRegistry[element.rindex].index = i
        end

        --sceneService:insertToScene(self)
        elementsRegistry[registryId].target = scene

        table.insert(scene, self)
        -- print("inserted to scene", scene[#scene], self)
        self.parent = nil
        elementsRegistry[registryId].index = #scene

        table.insert(detached, { source = parent, detached = self })
        --  print("objects in scene", #scene)
    end
end


local attached = {}
local getNewAttached = function()
    return attached
end

local defineAttach = function(registryId)
    elementsRegistry[registryId].element.attach = function(self, attachedElement)
        attachedElement.parent = self
        table.insert(self.childs, attachedElement)

        scene[#scene] = nil
        local newAttachedIndex = #self.childs

        elementsRegistry[attachedElement.rindex].target = self.childs
        elementsRegistry[attachedElement.rindex].index = newAttachedIndex

        table.insert(attached, { source = self, attached = attachedElement })
    end
end

local moved = {}
local getNewMoved = function()
    return moved
end

local defineMove = function(registryId)
    elementsRegistry[registryId].element.moveTo = function(self, cords)
        -- self:setCords(cords)
        self.content.x = cords.x
        self.content.y = cords.y
        table.insert(moved, self)
    end
end

local resized = {}
local getNewResized = function()
    return resized
end

local defineResize = function(registryId)

end



local addToRegistry = function(element, target, targetIdx)
    local registryIndex = #elementsRegistry + 1
    elementsRegistry[registryIndex] = {
        element = element,
        target = target,
        index = targetIdx,
        rindex =
            registryIndex
    }

    element.rindex = registryIndex
    element.scene = scene

    table.insert(target, targetIdx, elementsRegistry[registryIndex].element)
    --target[targetIdx] = elementsRegistry[registryIndex].element
end

local insertToScene = function(self, element)
    --print(555, element)
    if element.parent then
        --print(1)
        element.content.x = element.content.x + element.parent.content.x
        element.content.y = element.content.y + element.parent.content.y

        element.content.layer = element.parent.content.layer + 1
        local childIdx = #element.parent.childs + 1

        element.content.baseLayerIndex = childIdx
        addToRegistry(element, element.parent.childs, childIdx)
    else
        local sceneIndex = #scene + 1


        element.content.baseLayerIndex = sceneIndex
        addToRegistry(element, scene, sceneIndex)
    end
    local id = #elementsRegistry
    defineSelfDistruct(id)
    defineSelfSetTopLayer(id)
    defineDetach(id)
    defineAttach(id)
    defineMove(id)
    defineResize(id)
end

local getScene = function()
    -- dumpScene()

    return scene
end

local setCallbackInvokers = function(self, invokers)
    callbackInvokers = {}
    callbackInvokers.invokers = {}
    callbackInvokers.get = function(self, callbackName)
        return self.invokers[callbackName]
    end
    for k, v in pairs(invokers) do
        callbackInvokers.invokers[k] = v
        --print(k, v)
    end
    --  callbackInvokers = callbackInvokers
end

sceneService.getNewMoved = getNewMoved
sceneService.getNewResized = getNewResized
sceneService.getScene = getScene
sceneService.getNewAttached = getNewAttached
sceneService.getNewDetached = getNewDetached
sceneService.insertToScene = insertToScene
sceneService.setCallbackInvokers = setCallbackInvokers

return sceneService
