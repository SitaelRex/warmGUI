local PATH = (...):gsub('%.[^%.]+$', '')

local mediator = require(PATH .. "/mediator")

--uiApiController
local controllersList = {
    configurationController = require(PATH .. "/configurationController"),
    spawnController = require(PATH .. "/spawnController"),
    inputController = require(PATH .. "/inputController"),
    callbackController = require(PATH .. "/callbackController"),
    collisionController = require(PATH .. "/collisionController"),
    sceneController = require(PATH .. "/sceneController"),
    presentationController = require(PATH .. "/presentationController"),
    uiApiController = require(PATH .. "/uiApiController")
}

for controllerName, controller in pairs(controllersList) do
    controller:setMediator(mediator)
    controller:configureSubscriptions()
end

local send = function(self, topic, data)
    mediator:send(topic, data)
end

local getPresentation = function(self)
    return controllersList.presentationController:getPresentation()
end

local controllers = {}

controllers.send = send
controllers.getPresentation = getPresentation

return controllers
