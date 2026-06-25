-- Copyright (c) 2026 IliaKakos2000. Licensed under the MIT License.
local m = {}
local animation = {}
animation.__index = animation

function animation:connectToObject(object)
    if object and object.type == "imageSheet" then
        self.object = object
        self:reset()
    else
        self.object = nil
    end
end

function animation:setFrame(frameIndex)
    if not self.object or not self.object.tabPos then return end

    local absoluteFrame = (self.startFrame - 1) + (frameIndex - 1)

    local currentX = self.object.tabPos.x + absoluteFrame * (self.stepX or 0)
    local currentY = self.object.tabPos.y + absoluteFrame * (self.stepY or 0)

    self.object.quad = love.graphics.newQuad(
        currentX,
        currentY,
        self.object.tabPos.width,
        self.object.tabPos.height,
        self.object.image:getDimensions()
    )
end

function animation:play(delay, numOfIter)
    if not self.object then return end
    
    self:stop()
    self.isPlaying = true
    local currentFrame = 1

    local iterations = (numOfIter and numOfIter > 0) and numOfIter or -1
    
    self.animationTimer = timer.performWithDelay(delay, function(e)
        if not self.isPlaying then return end

        self:setFrame(currentFrame)
        currentFrame = currentFrame + 1

        if currentFrame > self.numOfFrames then
            currentFrame = 1
        end
    end, iterations) 
end

function animation:stop()
    self.isPlaying = false
    if self.animationTimer then
        self.animationTimer:cancel()
        self.animationTimer = nil
    end
end

function animation:reset()
    self:setFrame(1)
end

function animation:new(numOfFrames, startFrame, stepX, stepY)
    local this = {
        numOfFrames = numOfFrames or 1,
        startFrame = startFrame or 1,
        stepX = stepX or 0,
        stepY = stepY or 0,
        isPlaying = false,
        object = nil,
        animationTimer = nil
    }

    return setmetatable(this, animation)
end

m.createAnimation = function(numOfFrames, startFrame, stepX, stepY)
    return animation:new(numOfFrames, startFrame, stepX, stepY)
end

return m
