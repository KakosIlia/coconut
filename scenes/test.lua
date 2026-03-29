local b = display.rect(0, window.zeroY, window.width, 40)
b:setPhysBody("static")

local rm = display.circle(200,300,50)
rm:setColor({1,0,0})
rm:setPhysBody('static')
rm.beginContact = function(other)
    other:remove()
end

for i = 1, 100 do
	local a = display.rect(0, 0, 50, 50)
	a:setPhysBody("dynamic")
	local j = nil
	a:onTouched(function(e)
		if e.phase == "began" then
			j = physics.mouseJoint(e.target, mouse.x, mouse.y)
		elseif e.phase == "ended" then
			j:destroy()
		end
	end)
end
