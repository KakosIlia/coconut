-- Copyright (c) 2026 IliaKakos2000. Licensed under the MIT License.
local m = {}

m.loadScene = function(name)
	package.loaded["scenes." .. name] = nil
	m.currentScene = {
		name = name,
		data = {},
		stack = {},
		physWorld = love.physics.newWorld(0, 9.81 * 40, true),
	}
	require("scenes." .. name)
	physics.init()
end

return m
