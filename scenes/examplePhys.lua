display.setBackgroundColor("#56c9dd")

local circle = display.circle(0,0,20)
circle:setColor("#ec4747")
circle:setPhysBody('dynamic')

local ground = display.rect(0,-100,500,20)
ground:setPhysBody('static')
ground:setAngle(20)
ground:setColor("#3ed64b")

local image = display.image('love.png',window.width/2,window.height/2,100,100)
image.anchorX = -1
image.anchorY = -1