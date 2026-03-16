-- Copyright (c) 2024 IliaKakos2000. Licensed under the MIT License.
local canStart = false
window = {}
window.w, window.h = love.graphics.getWidth(), love.graphics.getHeight()
window.width, window.height = love.graphics.getWidth(), love.graphics.getHeight()
window.cx, window.cy = window.w / 2, window.h / 2
----------------------------------------------------------------
-- INIT
----------------------------------------------------------------
function love.load()
	canStart = true
end

local function addToStack(fun, type, args)
	sceneManager.currentScene.stack[#sceneManager.currentScene.stack + 1] = {
		fun = fun,
		type = type,
		args = args or {},
	}
	local self = {
		id = #sceneManager.currentScene.stack,
	}
	self.remove = function()
		sceneManager.currentScene.stack[self.id] = nil
	end
	return self
end

----------------------------------------------------------------
-- FUNCTIONS
----------------------------------------------------------------
function loop(fun)
	local self = addToStack(fun, "loop")
	return self
end

function love.update(dt)
	for k, v in pairs(sceneManager.currentScene.stack) do
		if v and v.type == "loop" and canStart then
			v.fun(dt)
		end
	end
	sceneManager.currentScene.physWorld:update(dt)

	for key, value in pairs(sceneManager.currentScene.data) do
		if value.physBody then
			value:update()
		end
	end
end

----------------------------------------------------------------
-- KEYS
----------------------------------------------------------------
function onKeyPressed(fun)
	local self
	addToStack(fun, "keyboard")
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
----------------------------------------------------------------
-- OBJECT FUNCTIONS
----------------------------------------------------------------
