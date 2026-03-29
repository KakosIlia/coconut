-- Copyright (c) 2026 IliaKakos2000. Licensed under the MIT License.
canStart = false
window = {}
window.w, window.h = love.graphics.getWidth(), love.graphics.getHeight()
window.width, window.height = love.graphics.getWidth(), love.graphics.getHeight()
window.cx, window.cy = window.w / 2, window.h / 2
window.maxX = window.w / 2
window.zeroX = -window.w / 2
window.maxY = window.height / 2
window.zeroY = -window.height / 2

currentDelta = 0
totalTime = 0

mouse = { x = 0, y = 0 }

function clamp(val, min, max)
	return math.max(min, math.min(max, val))
end
----------------------------------------------------------------
-- INIT
----------------------------------------------------------------

function getTableSize(table)
	local size = 0
	for k, v in pairs(table) do
		size = size + 1
	end
	return size
end

function love.load()
	canStart = true
end

local function addToStack(fun, type, args)
	local stack = sceneManager.currentScene.stack
	local entry = {
		fun = fun,
		type = type,
		args = args or {},
	}
	table.insert(stack, entry)

	return {
		remove = function()
			for i = #stack, 1, -1 do
				if stack[i] == entry then
					table.remove(stack, i)
					break
				end
			end
		end,
	}
end

----------------------------------------------------------------
-- FUNCTIONS
----------------------------------------------------------------
function loop(fun)
	local self = addToStack(fun, "loop")
	return self
end

function love.update(dt)
	if canStart then
		local stack = sceneManager.currentScene.stack
		for i = #stack, 1, -1 do
			local v = stack[i]
			if v and v.type == "loop" then
				v.fun(dt)
			end
		end
		sceneManager.currentScene.physWorld:update(dt)

		for key, value in pairs(sceneManager.currentScene.data) do
			value:update()
		end

		mouse.x, mouse.y = -(window.w / 2 - love.mouse.getX()), window.h / 2 - love.mouse.getY()
		timer.update(dt)
		transition.update(dt)
		currentDelta = dt
		totalTime = totalTime + dt
	end
end

----------------------------------------------------------------
-- KEYS
----------------------------------------------------------------
function onKeyPressed(fun)
	local self = addToStack(fun, "keyboard")
	return self
end

function onKeyReleased(fun)
	local self = addToStack(fun, "keyboardR")
	return self
end

function love.keypressed(key, scancode, isRepeat)
	for k, v in pairs(sceneManager.currentScene.stack) do
		if v and v.type == "keyboard" and canStart then
			v.fun(key, scancode, isRepeat)
		end
	end
end

function love.keyreleased(key, scan)
	for k, v in pairs(sceneManager.currentScene.stack) do
		if v and v.type == "keyboardR" then
			v.fun(key, scan)
		end
	end
end

----------------------------------------------------------------
-- MOUSE
----------------------------------------------------------------
function getMousePos()
	return love.mouse.getX() - window.w / 2, -(love.mouse.getY() - window.h / 2)
end

function onMousePressed(fun)
	local self = addToStack(fun, "mouse")
	return self
end

function onMouseReleased(fun)
	local self = addToStack(fun, "mouseR")
	return self
end

function onMouseMoved(fun)
	local self = addToStack(fun, "mouseM")
	return self
end

function onWheelMoved(fun)
	local self = addToStack(fun, "mouseWM")
	return self
end

function love.mousepressed(x, y, button)
	for k, v in pairs(sceneManager.currentScene.stack) do
		if v and v.type == "mouse" then
			v.fun(x, y, button)
		end
	end
end

function love.mousereleased(x, y, button)
	for k, v in pairs(sceneManager.currentScene.stack) do
		if v and v.type == "mouseR" then
			v.fun(x, y, button)
		end
	end
end

function love.mousemoved(x, y, dx, dy, istouch)
	for k, v in pairs(sceneManager.currentScene.stack) do
		if v and v.type == "mouseM" then
			v.fun(x, y, dx, dy, istouch)
		end
	end
end

function love.wheelmoved(x, y)
	for k, v in pairs(sceneManager.currentScene.stack) do
		if v and v.type == "mouseWM" then
			v.fun(x, y)
		end
	end
end
----------------------------------------------------------------
-- OBJECT FUNCTIONS
----------------------------------------------------------------
