local callbackService = {}

local elementLinks = {} --ссылки на объекты и их колбеки


local currentHover = nil
local currentTransparentHovers = nil
local collisionTree = nil
local cachedHover = nil
local cachedPress = nil
local overlapped = nil
local dragged = nil
local currentFocus = nil

local uiApi = {}
local getUIApi = function()
    return uiApi
end

local elements = {
}

local eventHandleMode = {
}

local handleAll = function(data)
    for k, element in pairs(elements[data.eventName]) do
        element.callback(element.element, getUIApi())
    end
end

local handleUnhovered = function(data)
    for k, element in pairs(elements[data.eventName]) do
        if element.element ~= currentHover then
            element.callback(element.element, getUIApi())
        end
    end
end

local handleHovered = function(data)
    for k, element in pairs(elements[data.eventName]) do
        if element.element == currentHover then
            element.callback(element.element, getUIApi())
        end
    end
end
local cachePos = {}
local handleHoveredCacheHover = function(data)
    cachedHover = currentHover
    if cachedHover ~= "emptyData" then
        cachePos.x = currentHover.content.x
        cachePos.y = currentHover.content.y
        for k, element in pairs(elements[data.eventName]) do
            if element.element == cachedHover then
                element.callback(element.element, getUIApi())
            end
        end
    end
end
local handleHoveredCachedHover = function(data)
    --if cachedHover == nil then error("!") end
    for k, element in pairs(elements[data.eventName]) do
        if element.element == cachedHover then
            dragged = element.element
            element.callback(element.element, getUIApi())
            if element.element.content.x ~= cachePos.x or element.element.content.y ~= cachePos.y then
                -- ломаем нажатие, чтобы драг не просчитывался как нажатие
                -- если объект уже был смещен драгом
                cachedPress = "Error"
            end
        end
    end
end
local handleHoveredUncacheHover = function(data)
    dragged = nil
    --  if cachedHover then
    for k, element in pairs(elements[data.eventName]) do
        if element.element == cachedHover then
            element.callback(element.element, getUIApi())
            cachedHover = nil
        end
    end
    overlapped = nil
end

local handleHoveredCachePress = function(data)
    cachedPress = not cachedPress and currentHover or cachedPress
    if cachedPress ~= currentHover then cachedPress = "Error" end

    for k, element in pairs(elements[data.eventName]) do
        if element.element == currentHover then
            element.callback(element.element, getUIApi())
        end
    end
end

local handleHoveredCachePressCheck = function(data)
    if cachedPress ~= "Error" then
        for k, element in pairs(elements[data.eventName]) do
            if element.element == currentHover then
                if cachedPress ~= "Error" then
                    cachedPress = "Error"
                    element.callback(element.element, getUIApi())
                end
            end
        end
    end
    cachedPress = nil
end

local handleParamList = function(data)
    local list = data.list or {}
    for k, element in pairs(elements[data.eventName]) do
        if list[element.element] then
            element.callback(element.element, getUIApi())
        end
    end
end

local handleTransparent = function(data)
    for k, element in pairs(elements[data.eventName]) do
        if currentTransparentHovers and currentTransparentHovers[element.element] then
            element.callback(element.element, getUIApi())
        end
    end
end


--local recursiveHandle
--
--recursiveHandle        = function(element, allElements, result)
--    for k, child in pairs(element.childs) do
--        -- print("rec")
--        recursiveHandle(child, allElements, result)
--    end
--    if allElements[element] then
--        allElements[element].callback(element.element, getUIApi())
--    end
--    result[#result + 1] = element
--    --element:onDestroy()
--end
--
local handleData       = function(data)
    local element = elementLinks[data.eventName] and elementLinks[data.eventName][data.params] or nil
    if element then
        element.callback(element.element, getUIApi())
    end

    --for k, element in pairs(elements[data.eventName]) do
    --    --  print(element)
    --    if element.element == data.params then
    --        local result = {}
    --
    --        element.callback(element.element, getUIApi())
    --    end
    --end
end

local intersect        = function(t1, t2)
    local a = { x = t1.content.x, x1 = t1.content.x + t1.content.w, y = t1.content.y, y1 = t1.content.y + t1.content.h }
    local b = { x = t2.content.x, x1 = t2.content.x + t2.content.w, y = t2.content.y, y1 = t2.content.y + t2.content.h }
    local s1 = (a.x >= b.x and a.x <= b.x1) or (a.x1 >= b.x and a.x1 <= b.x1)
    local s2 = (a.y >= b.y and a.y <= b.y1) or (a.y1 >= b.y and a.y1 <= b.y1)
    local s3 = (b.x >= a.x and b.x <= a.x1) or (b.x1 >= a.x and b.x1 <= a.x1)
    local s4 = (b.y >= a.y and b.y <= a.y1) or (b.y1 >= a.y and b.y1 <= a.y1)
    return ((s1 and s2) or (s3 and s4)) or ((s1 and s4) or (s3 and s2));
end

local handleOverlap    = function(data)
    if currentHover == dragged and cachedPress and dragged then
        local indexInTree = { idx = 0, element = nil }
        for k, element in pairs(elements[data.eventName]) do
            local idx = 0
            for i = 1, #collisionTree do
                local k = i
                local v = collisionTree[i]
                if v == element.element and intersect(v, dragged) then
                    idx = k
                end

                if indexInTree.idx < idx then
                    indexInTree = { idx = idx, element = element }
                end
            end
        end

        if indexInTree.element then
            indexInTree.element.callback(indexInTree.element.element, getUIApi())
        end

        overlapped = indexInTree.element and indexInTree.element.element or nil
    end
end

local handleNotOverlap = function(data)
    --local element = elementLinks[data.eventName][overlapped]
    --if element then
    --    element.callback(element.element, getUIApi())
    --end
    for k, element in pairs(elements[data.eventName]) do
        if element.element ~= overlapped then
            element.callback(element.element, getUIApi())
        end
    end
end

local handleAttach     = function(data)
    local element = elementLinks[data.eventName][data.params.source]
    if element then
        element.callback(element.element, getUIApi(), data.params.attached)
    end
    --for k, element in pairs(elements[data.eventName]) do
    --    if element.element == data.params.source then
    --        element.callback(element.element, getUIApi(), data.params.attached)
    --    end
    --end
end

local handleDetach     = function(data)
    local element = elementLinks[data.eventName][data.params.source]
    if element then
        element.callback(element.element, getUIApi(), data.params.detached)
    end
    --for k, element in pairs(elements[data.eventName]) do
    --    if element.element == data.params then
    --        element.callback(element.element, getUIApi())
    --    end
    --end
end


local handleMove   = function(data)
    local element = elementLinks[data.eventName][data.params]
    if element then
        element.callback(element.element, getUIApi())
    end
end

local handleResize = function(data)
    local element = elementLinks[data.eventName][data.params]
    if element then
        element.callback(element.element, getUIApi())
    end
end




-----------------------------------------------

local handleCallback = function(data)
    eventHandleMode[data.eventName](data)
end


local listenElement = function(data)
    if data.callback then
        elementLinks[data] = {}
        for callbackName, callbackFunc in pairs(data.callback.callbacks) do
            elementLinks[callbackName] = elementLinks[callbackName] or {}
            local index = #elements[callbackName] + 1
            elements[callbackName] = elements[callbackName] or {}
            elements[callbackName][index] = {
                callback = data.callback[callbackName],
                element = data
            }

            elementLinks[callbackName][data] = elements[callbackName][index]
        end
    end
end

local removeFromListen = function(data)
    if data.callback then
        for callbackName, callbackFunc in pairs(data.callback.callbacks) do
            elementLinks[callbackName][data] = nil
            --  local idx = 0
            for k, v in pairs(elements[callbackName]) do
                local listened = elements[callbackName][k].element
                if listened == data then
                    table.remove(elements[callbackName], k)
                end
            end
        end
    end
end



local handleUiApi = function(api)
    uiApi = api
end

local updateHover = function(data)
    currentHover = data.current
    currentTransparentHovers = data.transparent
    collisionTree = data.tree
end

local callbackConfig = {
    onPress = handleHoveredCachePress,
    onTransparentPress = handleTransparent,
    onRelease = handleHoveredCachePress,
    onClick = handleHoveredCachePressCheck,
    onTransparentClick = handleTransparent,
    onHover = handleHovered,
    onTransparentHover = handleTransparent,
    onNotHover = handleUnhovered,
    onDragStart = handleHoveredCacheHover,
    onDrag = handleHoveredCachedHover,
    onDragEnd = handleHoveredUncacheHover,
    update = handleAll,
    onCreate = handleParamList,
    onCreateB = handleParamList,
    onDestroy = handleData,
    onOverlap = handleOverlap,
    onDestroyB = handleData, -- стандартный
    onNotOverlap = handleNotOverlap,
    onAttach = handleAttach,
    onDetach = handleDetach,
    onMove = handleMove,
    onResize = handleResize,
}

local getCallbackConfig = function(self)
    elements = {}
    eventHandleMode = {}

    for eventName, eventFunc in pairs(callbackConfig) do
        elements[eventName] = {}
        eventHandleMode[eventName] = eventFunc
    end
    return callbackConfig
end

local configureCallbacks = function(self, callbacks)

end

local getOverlapped = function()
    return overlapped
end


callbackService.getCallbackConfig = getCallbackConfig
--callbackService.configureCallbacks = configureCallbacks
callbackService.handleUiApi = handleUiApi
callbackService.handleCallback = handleCallback
callbackService.listenElement = listenElement
callbackService.updateHover = updateHover
callbackService.removeFromListen = removeFromListen
callbackService.getOverlapped = getOverlapped

return callbackService
