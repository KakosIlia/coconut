display.setBackgroundColor("#56c9dd")

local circle = display.circle(0,0,20)
circle:setColor("#ec4747")
circle:setPhysBody('dynamic')

local ground = display.rect(0,-200,500,20)
ground:setPhysBody('static')
ground:setAngle(20)
ground:setColor("#72fd7d")