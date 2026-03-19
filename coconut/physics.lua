-- Copyright (c) 2026 IliaKakos2000. Licensed under the MIT License.
local m = {}

m.init = function()
	sceneManager.currentScene.coll = {}
	sceneManager.currentScene.coll.beginContact = function(a, b, coll) end
	sceneManager.currentScene.coll.endContact = function(a, b, coll) end
	sceneManager.currentScene.physWorld:setCallbacks(beginContact, endContact, preSolve, postSolve)
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

return m
