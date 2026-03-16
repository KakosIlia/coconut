-- Copyright (c) 2024 IliaKakos2000. Licensed under the MIT License.
local m = {}

m.setPhysicsMeter = function(meter)
	love.physics.setMeter(meter)
end

m.distanceJoint = function(body1, body2, x1, y1, x2, y2, canCollide)
	return love.physics.newDistanceJoint(body1.physBody, body2.physBody, x1, y1, x2, y2, canCollide)
end

return m
