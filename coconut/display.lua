-- Copyright (c) 2026 IliaKakos2000. Licensed under the MIT License.
local m = {}
m.bgColor = { 0, 0, 0 }

m.setBackgroundColor = function(...)
	local t = { ... }
	if #t == 1 then
		m.bgColor = t[1]
	end
	if #t >= 3 then
		m.bgColor = { t[1] / 255, t[2] / 255, t[3] / 255 }
	end
	if #t == 1 and type(t[1]) == "string" then
		t[1] = t[1]:gsub("#", "")

		local r = tonumber(t[1]:sub(1, 2), 16) / 255
		local g = tonumber(t[1]:sub(3, 4), 16) / 255
		local b = tonumber(t[1]:sub(5, 6), 16) / 255

		local alpha = 1
		if #t[1] >= 8 then
			alpha = tonumber(t[1]:sub(7, string.len(t[1])), 16) / 255
		end

		m.bgColor = { r, g, b, alpha or 1 }
	end
end

m.debugColliders = false

local OBJECT = {}
local illegal = { x = true, y = true }
OBJECT.__index = OBJECT

OBJECT.__newindex = function(t, k, v)
	if illegal[k] then
		print("please use :setX, :setY")
	else
		rawset(t, k, v)
	end
end

function OBJECT:addToStack(self)
	sceneManager.currentScene.data[getTableSize(sceneManager.currentScene.data) + 1] = self
	local id = getTableSize(sceneManager.currentScene.data)
	self.id = id

	return self
end

----------------------------------------------------------------
-- GENERAL
----------------------------------------------------------------

function OBJECT:remove()
	if self.press then
		self.press.remove()
		self.released.remove()
		self.moved:remove()
	end
	if self.fixture then
		self.fixture:destroy()
	end
	if self.physBody then
		self.physBody:destroy()
	end

	if self.children then
		for i = #self.children, 1, -1 do
			self.children[i]:remove()
		end
	end

	local sourceTable
	if self.parent then
		sourceTable = self.parent.children
	else
		sourceTable = sceneManager.currentScene.data
	end

	if sourceTable then
		for i = #sourceTable, 1, -1 do
			if sourceTable[i] == self then
				local s = sourceTable[i]
				if s.physBody and not s.physBody:isDestroyed() then
					s.physBody:destroy()
					s.fixture:destroy()
				end
				if s.press then
					s.press.remove()
					s.released.remove()
					s.moved:remove()
				end
				table.remove(sourceTable, i)
				break
			end
		end
	end
end

function OBJECT:update()
	if self and self.physBody then
		self._proxy.x = self.physBody:getX() or 0
		self._proxy.y = -self.physBody:getY() or 0
		self._proxy.angle = math.deg(self.physBody:getAngle()) or 0
	end
end

function OBJECT:insert(obj)
	if self.type == 'node' then
	for i = #sceneManager.currentScene.data, 1, -1 do
		if sceneManager.currentScene.data[i] == obj then
			table.remove(sceneManager.currentScene.data, i)
			break
		end
	end

	obj.parent = self

	table.insert(self.children, obj)

	return obj
else
	return false
end
end

----------------------------------------------------------------
-- PHYSICS
----------------------------------------------------------------

function OBJECT:addFixture()
	if self.type == "rect" or self.type == "image" or self.type == "imageSheet" then
		self.physShape = love.physics.newRectangleShape(self._proxy.width, self._proxy.height)
	elseif self.type == "circle" then
		self.physShape = love.physics.newCircleShape(self._proxy.radius)
	end

	if self.type == 'node' and #self.children >= 1 then
		local totalWidth,totalHeight = 0,0
		local largestObject = self.children[1]
		for k,v in pairs(self.children) do
			if v:getWidth() >= largestObject:getWidth() then
				largestObject = v
			end

			if v:getHeight() >= largestObject:getHeight() then
				largestObject = v
			end

		end
		if #self.children >= 1 then
		self.physShape = love.physics.newRectangleShape(largestObject:getWidth(),largestObject:getHeight())
		end

	elseif #self.children <=1 and self.type == 'node' then
		self.physShape = love.physics.newFixture(self.physBody,love.physics.newRectangleShape(1,1))
	end
	self.fixture = love.physics.newFixture(self.physBody, self.physShape)
	self.fixture:setUserData(self)
end

function OBJECT:setPhysBody(type)
	self.physBody = love.physics.newBody(sceneManager.currentScene.physWorld, self._proxy.x, -self._proxy.y, type)
	self:addFixture()
	self.physBody:setAngle(math.rad(self._proxy.angle or 0))
end

function OBJECT:setMass(mass)
	if self.physBody then
		self.physBody:setMass(mass)
	end
end

function OBJECT:setRestitution(rest)
	if self.physBody then
		self.fixture:setRestitution(rest)
	end
end

function OBJECT:setFixedRotation(isFixed)
	if self.physBody then
		self.physBody:setFixedRotation(isFixed)
	end
end

function OBJECT:setSensor(isSensor)
	if self.fixture then
		self.fixture:setSensor(isSensor)
	end
end

function OBJECT:setLinearVelocity(vx, vy)
	if self.physBody then
		self.physBody:setLinearVelocity(vx, vy)
	end
end

----------------------------------------------------------------
-- POSITIONS
----------------------------------------------------------------

--setter

function OBJECT:setPosition(x, y)
	self._proxy.x, self._proxy.y = x, y
	if self.physBody then
		self.physBody:setPosition(x, -y)
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
		self.physBody:setY(-y)
	end
end

function OBJECT:setSize(w, h)
	if self.type ~= 'node' then
	self._proxy.width = w
	self._proxy.height = h
	if self.physBody then
		self.fixture:destroy()
		self:addFixture()
	end
else
	for k,v in pairs(self.children) do
		v._proxy.width = w
		v._proxy.height = h
	end
end
end

function OBJECT:setWidth(w)
	self._proxy.width = w
	if self.physBody then
		self.fixture:destroy()
		self:addFixture()
	end


	if self.type == 'node' then
		for k,v in pairs(self.children) do
			v._proxy.width = w
		end
	end
end

function OBJECT:setHeight(h)
	self._proxy.height = h
	if self.physBody then
		self.fixture:destroy()
		self:addFixture()
	end

	if self.type == 'node' then
		for k,v in pairs(self.children) do
			v._proxy.height = h
		end
	end
end

function OBJECT:setAngle(angle)
	self._proxy.angle = angle
	if self.physBody then
		self.physBody:setAngle(math.rad(angle))
	end
end

--getter

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

function OBJECT:lookAt(targetX, targetY)
	local x, y = self:getPosition()

	local dx = targetX - x
	local dy = targetY - y

	local angleRad = math.atan2(-dy, dx)

	local angleDeg = math.deg(angleRad)

	self:setAngle(angleDeg)
end

----------------------------------------------------------------
-- GRAPHICS
----------------------------------------------------------------

function OBJECT:setStroke(width, color)
	self.strokeWidth = width
	self.strokeColor = color
end

function OBJECT:setRenderRect(x, y, width, height)
	self._proxy.scissors = { x = x, y = y, width = width, height = height }
end

function OBJECT:setColor(...)
	local t = { ... }
	if #t == 1 then
		self.color = t[1]
	end
	if #t >= 3 then
		self.color = { t[1] / 255, t[2] / 255, t[3] / 255 }
	end
	if #t == 1 and type(t[1]) == "string" then
		t[1] = t[1]:gsub("#", "")

		local r = tonumber(t[1]:sub(1, 2), 16) / 255
		local g = tonumber(t[1]:sub(3, 4), 16) / 255
		local b = tonumber(t[1]:sub(5, 6), 16) / 255

		local alpha = 1
		if #t[1] >= 8 then
			alpha = tonumber(t[1]:sub(7, string.len(t[1])), 16) / 255
		end

		self.color = { r, g, b, alpha or 1 }
	end
end

function OBJECT:setFont(font, size)
	if not assets.get(font) then
		self.font = love.graphics.newFont(font, size)
		assets.add(self.font, "font", font)
	else
		self.font = assets.get(font)
	end
end

function OBJECT:setShader(code, tOfSends)
	self._proxy.shader = love.graphics.newShader(code)
	self._proxy.shaderData = tOfSends or {}
end

function OBJECT:sendToShader(data)
	if self and self._proxy.shader then
		self._proxy.shaderData = data
	end
end

function OBJECT:hitTest(screenX, screenY)
	local mx = screenX - (window.cx or 0)
	local my = -(screenY - (window.cy or 0))

	local dx = mx - (self._proxy.x or 0)
	local dy = my - (self._proxy.y or 0)

	local angle = math.rad(self._proxy.angle or 0)
	local cosA, sinA = math.cos(-angle), math.sin(-angle)

	local lx = dx * cosA - dy * sinA
	local ly = dx * sinA + dy * cosA

	local w, h = 0, 0
	if self.type == "circle" then
		local r = self._proxy.radius or 0
		w, h = r * 2, r * 2
		local finalX = lx - (w / 2 * (self.anchorX or 0))
		local finalY = ly - (h / 2 * (self.anchorY or 0))
		return (finalX * finalX + finalY * finalY) <= (r * r), finalX, finalY
	elseif self.type == "text" then
		w, h = self.font:getWidth(self.text), self.font:getHeight(self.text)
	else
		w, h = self._proxy.width or 0, self._proxy.height or 0
	end

	local finalX = lx - (w / 2 * (self.anchorX or 0))
	local finalY = ly - (h / 2 * (self.anchorY or 0))
	local isHit = math.abs(finalX) < (w / 2) and math.abs(finalY) < (h / 2)

	return isHit, finalX, finalY
end

function OBJECT:onTouched(fun)
	local rt = { phase = "", x = 0, y = 0, lx = 0, ly = 0, target = self }
	self._activeInputs = {}

	local function processEvent(id, phase, x, y, dx, dy, button)
		local isHit, lx, ly = self:hitTest(x, y)

		if phase == "began" and isHit then
			self._activeInputs[id] = true
		end

		if self._activeInputs[id] then
			rt.phase = phase
			rt.x, rt.y = x, y
			rt.lx, rt.ly = lx, ly
			rt.dx, rt.dy = dx or 0, dy or 0
			rt.id = id
			rt.button = button
			fun(rt)

			if phase == "ended" then
				self._activeInputs[id] = nil
			end
		end
	end

	self.tp = onTouchpressed(function(id, x, y)
		processEvent(id, "began", x, y)
	end)
	self.tm = onTouchmoved(function(id, x, y, dx, dy)
		processEvent(id, "moved", x, y, dx, dy)
	end)
	self.tr = onTouchreleased(function(id, x, y)
		processEvent(id, "ended", x, y)
	end)

	if onMousePressed then
		self.mp = onMousePressed(function(x, y, b)
			processEvent("mouse", "began", x, y, 0, 0, b)
		end)
		self.mm = onMouseMoved(function(x, y, dx, dy)
			processEvent("mouse", "moved", x, y, dx, dy)
		end)
		self.mr = onMouseReleased(function(x, y, b)
			processEvent("mouse", "ended", x, y, 0, 0, b)
		end)
	end
end
----------------------------------------------------------------
-- NEW_OBJ
----------------------------------------------------------------

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
		mirroredX = false,
		mirroredY = false,
		angleAnchor = 0,
		layer = 1,
		_proxy = {
			angle = 0,
		},
		children = {},
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
			angle = 0,
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
			angle = 0,
		},
		type = "circle",
		strokeWidth = 0,
		strokeColor = { 0, 0, 0 },
	}
	self = newObj(self)
	return OBJECT:addToStack(self)
end

m.image = function(image, x, y, w, h, type)
	local self = {
		_proxy = {
			x = x,
			y = y,
			width = w,
			height = h,
			angle = 0,
		},
		type = "image",
	}
	if assets.get(image) then
		self.image = assets.get(image)
	else
		self.image = love.graphics.newImage(image)
		self.image:setFilter(type or "linear", type or "linear")
		assets.add(self.image, "image", image)
	end
	self = newObj(self)
	return OBJECT:addToStack(self)
end

m.imageSheet = function(image, tabPos, x, y, w, h, type)
	local self = {
		_proxy = {
			x = x,
			y = y,
			width = w,
			height = h,
			angle = 0,
		},
		type = "imageSheet",
	}
	if assets.get(image) then
		self.image = assets.get(image)
	else
		self.image = love.graphics.newImage(image)
		assets.add(self.image, "image", image)
	end
	self.image:setFilter(type or "linear", type or "linear")
	self.tabPos = tabPos
	self.quad = love.graphics.newQuad(tabPos.x, tabPos.y, tabPos.width, tabPos.height, self.image:getDimensions())
	function self:retakeSprite(tabPos)
		self.quad = love.graphics.newQuad(tabPos.x, tabPos.y, tabPos.width, tabPos.height, self.image:getDimensions())
	end
	self = newObj(self)
	return OBJECT:addToStack(self)
end

m.identSheet = function(xml)
	local file = io.open(xml,"r")
	if file then
		local data = file:read("a*")
		file:close()
		local xml = require 'coconut.xml'
		local imagesHandler = xml.parseString(data)
		return imagesHandler.sprites
	end
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
		angle = 0,
	}
	if not assets.get(font) then
		if font then
			self.font = love.graphics.newFont(font, size)
		else
			self.font = love.graphics.newFont("default.ttf", 20)
		end
		assets.add(self.font, "font", font)
	else
		self.font = assets.get(font)
	end
	self = newObj(self)
	return OBJECT:addToStack(self)
end

m.formattedText = function(textF, x, y, font, size)
	local self = {
		_proxy = {
			x = x,
			y = y,
		},
		text = textF,
		type = "textF",
		size = size,
		angle = 0,
	}
	if not assets.get(font) then
		if font then
			self.font = love.graphics.newFont(font, size)
		else
			self.font = love.graphics.newFont("default.ttf", 20)
		end
		assets.add(self.font, "font", font)
	else
		self.font = assets.get(font)
	end

	self.getText = function()
		local result = ""
		if type(self.text) == "table" then
			for k, v in pairs(self.text) do
				if type(v) == "string" then
					result = result .. v
				end
			end
		else
			result = self.text
		end
		return result
	end
	self = newObj(self)
	return OBJECT:addToStack(self)
end

m.line = function(...)
	local self = {
		points = { ... },
		type = "line",
		lineSize = 2,
		_proxy = {
			angle = 0,
		},
	}
	self = newObj(self)

	self.retakePoints = function()
		for i = 1, #self.points do
			if i % 2 == 0 then
				self.points[i] = -self.points[i]
			end
		end
	end
	self.retakePoints()
	return OBJECT:addToStack(self)
end

m.node = function(...)
	local self = {
		type = "node",
		_proxy = {
			angle = 0,
			width = 0,
			height = 0,
			x = 0,
			y = 0,
			xScale = 1,
			yScale = 1
		},
	}
	self = newObj(self)
	return OBJECT:addToStack(self)
end

--[[importNode = function(path)
	local file = io.open(path,'r')
	local resultNode = m.node()
	if file then
		local data = file:read("a*")
		local t = json.decode(data)

		for k,v in pairs(t) do
			local self = m.rect(v.x,v.y,v.width,v.height)
			resultNode[k] = self
			resultNode:insert(self)
		end
	end
	return resultNode
end]]

m.objModel = function(path)
	local self = {
		_proxy = {
			x = 0,
			y = 0,
			width = 0,
			height = 0
		},
		x = 0,
		y = 0,
		z = 0,
		type = 'objModel'
	}
	local file = io.open(path,'r')
	if file then
		local data = file:read("a*")
		local parsedData = objParser.parse(data)
		self.parsedData = parsedData
	end
	self = newObj(self)
	return OBJECT:addToStack(self)
end


m.clearAll = function()
	for k, v in pairs(sceneManager.currentScene.data) do
		v:remove()
	end
end

return m
