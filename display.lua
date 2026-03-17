-- Copyright (c) 2024 IliaKakos2000. Licensed under the MIT License.
local m = {}
m.bgColor = { 0, 0, 0 }

local OBJECT = {}
local illegal = { x = true , y = true}
OBJECT.__index = OBJECT

OBJECT.__newindex = function(t, k, v)
	if illegal[k] then
		print("ILLEGAL")
	else
		rawset(t, k, v)
	end
end

function OBJECT:addToStack(self)
	sceneManager.currentScene.data[#sceneManager.currentScene.data + 1] = self
	local id = #sceneManager.currentScene.data
	self.id = id

	return sceneManager.currentScene.data[#sceneManager.currentScene.data]
end

----------------------------------------------------------------
-- GENERAL
----------------------------------------------------------------

function OBJECT:remove()
	if self.press then
		self.press.remove()
		self.released.remove()
	end
	sceneManager.currentScene.data[self.id] = nil
end

function OBJECT:addFixture()
		if self.type == "rect" or self.type == "image" then
		self.physShape = love.physics.newRectangleShape(self._proxy.width, self._proxy.height)
	elseif self.type == 'circle' then
		self.physShape = love.physics.newCircleShape(self._proxy.radius)
	end
	self.fixture = love.physics.newFixture(self.physBody, self.physShape)
end

function OBJECT:setPhysBody(type)
	self.physBody = love.physics.newBody(sceneManager.currentScene.physWorld, self._proxy.x, -self._proxy.y, type)
	self:addFixture()
	self.physBody:setAngle(math.rad(self._proxy.angle or 0))
end

----------------------------------------------------------------
-- POSITIONS
----------------------------------------------------------------

function OBJECT:setPosition(x, y)
	self._proxy.x, self._proxy.y = x, y
	if self.physBody then
		self.physBody:setPosition(x, y)
	end
end

function OBJECT:setX(x)
	self._proxy.x = x
	if self.physBody then
		self.physBody:setX(x)
	end
end

function OBJECT:setY(y)
	self._proxy.y = y
	if self.physBody then
		self.physBody:setY(y)
	end
end

function OBJECT:setSize(w, h)
	self._proxy.width = w
	self._proxy.height = h
	if self.physBody then
		self.fixture:destroy()
		self:addFixture()
	end
end

function OBJECT:setWidth(w)
	self._proxy.width = w
	if self.physBody then 
		self.fixture:destroy()
		self:addFixture()
	end
end

function OBJECT:setHeight(h)
	self._proxy.height = h
	if self.physBody then
		self.fixture:destroy()
		self:addFixture()
	end
end

function OBJECT:setAngle(angle)
	self._proxy.angle = angle
	if self.physBody then
		self.physBody:setAngle(math.rad(angle))
	end
end

function OBJECT:getPosition()
	return self._proxy.x, self._proxy.y
end

function OBJECT:getX()
	return self._proxy.x
end

function OBJECT:getY()
	return self._proxy.y
end

function OBJECT:getSize()
	return self._proxy.width, self._proxy.height
end

function OBJECT:getWidth()
	return self._proxy.width
end

function OBJECT:getHeight()
	return self._proxy.height
end

function OBJECT:getAngle()
	return self._proxy.angle
end

----------------------------------------------------------------
-- GRAPHICS
----------------------------------------------------------------

function OBJECT:setStroke(width, color)
	self.strokeWidth = width
	self.strokeColor = color
end

function OBJECT:setColor(...)
	local t = {...}
	if #t == 1 then
		self.color = t[1]
	end
	if #t >= 3 then
		self.color = {t[1]/255,t[2]/255,t[3]/255}
	end
	if #t == 1 and type(t[1]) == 'string' then
		t[1] = t[1]:gsub("#", "")

		local r = tonumber(t[1]:sub(1, 2), 16) / 255
		local g = tonumber(t[1]:sub(3, 4), 16) / 255
		local b = tonumber(t[1]:sub(5, 6), 16) / 255
		
		local alpha = 1
		if #t[1] >= 8 then
			alpha = tonumber(t[1]:sub(7, string.len(t[1])), 16) / 255
		end
		
		self.color = {r,g,b,alpha or 1}
	end
end

----------------------------------------------------------------
-- MOUSE
----------------------------------------------------------------

function OBJECT:inMouse()
	local mx = love.mouse.getX() - window.cx
	local my = -love.mouse.getY() + window.cy

	local dx = mx - self._proxy.x
	local dy = my - self._proxy.y

	local angle = math.rad(self._proxy.angle or 0)
	local cosA = math.cos(-angle)
	local sinA = math.sin(-angle)

	local localX = dx * cosA - dy * sinA
	local localY = dx * sinA + dy * cosA

	return math.abs(localX) < self._proxy.width / 2 and math.abs(localY) < self._proxy.height / 2
end

function OBJECT:onTouched(fun)
	local rt = {
		x = 0,
		y = 0,
		phase = "",
	}
	self.press = onMousePressed(function(x, y, b)
		if self:inMouse() then
			rt.phase = "began"
			rt.x = x
			rt.y = y
			rt.button = b
			rt.self = self
			fun(rt)
		end
	end)

	self.moved = onMouseMoved(function(x, y, dx, dy, ist)
		if self:inMouse() then
			rt.phase = "moved"
			rt.x = x
			rt.y = y
			rt.dx = dx
			rt.dy = dy
			rt.self = self
			fun(rt)
		end
	end)
	self.released = onMouseReleased(function(x, y, b)
		if self:inMouse() or self.focused then
			rt.phase = "ended"
			rt.x = x
			rt.y = y
			rt.button = b
			rt.self = self
			fun(rt)
		end
	end)
end

function OBJECT:update()
	self._proxy.x = self.physBody:getX()
	self._proxy.y = -self.physBody:getY()
	self._proxy.angle = math.deg(self.physBody:getAngle())
end

local newObj = function(t)
	local rt = {}
	for key, value in pairs(t) do
		if not rt[key] then
			rt[key] = value
		end
	end
	----------------------------------------------------------------
	--STANDARTS
	----------------------------------------------------------------
	local st = {
		color = { 1, 1, 1, 1 },
		visible = true,
		anchorX = 0,
		anchorY = 0,
		_proxy = {
			angle = 0,
		},
	}

	for k, v in pairs(st) do
		if not rt[k] then
			rt[k] = v
		end
	end

	return setmetatable(rt, OBJECT)
end

----------------------------------------------------------------
-- API модуля
----------------------------------------------------------------

m.rect = function(x, y, w, h)
	local self = {
		_proxy = {
			x = x,
			y = y,
			width = w,
			height = h,
		},
		type = "rect",
		strokeWidth = 0,
		strokeColor = { 0, 0, 0 },
	}
	self = newObj(self)
	return OBJECT:addToStack(self)
end

m.circle = function(x, y, r)
	local self = {
		_proxy = {
			x = x,
			y = y,
			radius = r,
		},
		type = "circle",
		strokeWidth = 0,
		strokeColor = { 0, 0, 0 },
	}
	self = newObj(self)
	return OBJECT:addToStack(self)
end

m.image = function(image, x, y, w, h)
	local self = {
		_proxy = {
			x = x,
			y = y,
			width = w,
			height = h,
		},
		image = love.graphics.newImage(image),
		type = "image",
	}
	self = newObj(self)
	return OBJECT:addToStack(self)
end

m.text = function(text, x, y, font, size)
	local self = {
		_proxy = {
			x = x,
			y = y,
		},
		text = text,
		type = "text",
		size = size,
	}
	if font then
		self.font = love.graphics.newFont(font, size)
	else
		self.font = love.graphics.newFont("default.ttf", 20)
	end
	self = newObj(self)
	return OBJECT:addToStack(self)
end

return m
