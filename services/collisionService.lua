local collisionService = {}

local sceneInterpretation = {}
local currentCollision = nil
local transparentCollision = nil
local collisionTree = nil

local sceneStateUpdate = function(self, data)
    sceneInterpretation = data
end

local checkCollision = function(element, x, y)
    local content = element.content
    return element.collision.checkCollision and (element.collision.predicate(x, y, content) and element) or nil

    -- (x >= element.content.x and x <= element.content.x + element.content.w and
    --   y >= element.content.y and y <= element.content.y + element.content.h) and element or nil
end

local handleElement


handleElement = function(element, result, x, y, transparentCollision, check)
    local childResult = nil

    --  local ncheck = check
    -- local cachedResult = nil

    local elementCollisionAccept = checkCollision(element, x, y)
    -- local cachedChildResult
    --print(x, y, elementCollisionAccept)
    if elementCollisionAccept then
        local childsList = {}

        local check = check
        --cachedChildResult = nil


        for _, child in pairs(element.childs) do -- обратный порядок проверки коллизии
            table.insert(childsList, 1, child)
        end

        for _, child in pairs(childsList) do
            -- local ncheck = check and (childResult and false or true) --and
            --   print(ncheck)
            if childResult then
                check = false
            end
            local res = handleElement(child, result, x, y, transparentCollision, check)
            if not childResult then
                childResult = res
            end
        end

        table.insert(collisionTree, 1, element)
    end

    result = childResult or elementCollisionAccept
    if childResult and elementCollisionAccept and check then
        transparentCollision[element] = true
    end
    return result
end

local collisionUpdate = function(self, checkCords)
    collisionTree = {}
    transparentCollision = {}
    local x, y = checkCords.x, checkCords.y
    local resultCollision

    local childsList = {}
    for _, child in pairs(sceneInterpretation) do -- обратный порядок проверки коллизии
        table.insert(childsList, 1, child)
    end

    for _, element in pairs(childsList) do
        local check = resultCollision and false or true
        local result = handleElement(element, newCollision, x, y, transparentCollision, check)
        if not resultCollision then
            local newCollision = nil
            local newCollision = result
            -- local newCollision = handleElement(element, newCollision, x, y, transparentCollision)

            if newCollision and not resultCollision then
                resultCollision = newCollision
            end
        end
    end
    currentCollision = resultCollision or nil
    -- print(#transparentCollision)
end

--возвращает найденную коллизию
local getCollision = function()
    -- print("collision", currentCollision)
    return { current = currentCollision, transparent = transparentCollision, tree = collisionTree }
end

collisionService.sceneStateUpdate = sceneStateUpdate
collisionService.collisionUpdate = collisionUpdate
collisionService.getCollision = getCollision

return collisionService
