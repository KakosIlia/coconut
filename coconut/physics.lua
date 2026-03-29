-- Copyright (c) 2026 IliaKakos2000. Licensed under the MIT License.
local m = {}

m.init = function()
	sceneManager.currentScene.coll = {}
	local beginContact = function(a, b, coll)
		local obj1 = a:getUserData()
		local obj2 = b:getUserData()
		for k, v in pairs(sceneManager.currentScene.data) do
			if v == obj1 or v == obj2 then
				local other = obj1
				if v == obj1 then
					other = obj2
				end
				if v.beginContact and v.physBody then
					v.beginContact(other,coll)
				end
			end
		end
	end
	local endContact = function(a, b, coll)
		local obj1 = a:getUserData()
		local obj2 = b:getUserData()
		for k, v in pairs(sceneManager.currentScene.data) do
			if v == obj1 or v == obj2 then
				if v.endContact and v.physBody then
					local other = obj1
					if v == obj1 then
						other = obj2
					end
					v.endContact(other, coll)
				end
			end
		end
	end
	sceneManager.currentScene.physWorld:setCallbacks(beginContact, endContact)
end

m.setPhysicsMeter = function(meter)
	love.physics.setMeter(meter)
end

m.setWorldGravity = function(gx, gy)
	sceneManager.currentScene.physWorld:setGravity(gx or 0, gy or 0)
end

m.getWorld = function()
	return sceneManager.currentScene.physWorld
end

-- joints in development
m.distanceJoint = function(body1, body2, x1, y1, x2, y2, canCollide)
	return love.physics.newDistanceJoint(body1.physBody, body2.physBody, x1, y1, x2, y2, canCollide)
end

m.mouseJoint = function(body,x,y)
	local joint = love.physics.newMouseJoint(body.physBody,x,-y)
	loop(function()
		if not joint:isDestroyed() then
			joint:setTarget(mouse.x,-mouse.y)
		end
	end)

	return joint
end

return m
