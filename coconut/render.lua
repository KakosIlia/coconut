-- Copyright (c) 2026 IliaKakos2000. Licensed under the MIT License.
local m = {}

local function drawObject(v)
	if not v or not v.visible then return end

	love.graphics.push()
	
	local localWidth, localHeight = 0, 0
	if v.type == "text" then
		localWidth = v.font:getWidth(v.text)
		localHeight = v.font:getHeight(v.text)
	elseif v.type == "textF" then
		localWidth = v.font:getWidth(v.getText())
		localHeight = v.font:getHeight(v.getText())
	elseif v.type == "circle" then
		localWidth = v._proxy.radius * 2
		localHeight = v._proxy.radius * 2
	else
		localWidth, localHeight = v._proxy.width or 0, v._proxy.height or 0
	end

	if v.type ~= "circle" and v.type ~= "line" then
		love.graphics.translate(
			v._proxy.x + localWidth / 2 * v.anchorX,
			-v._proxy.y + localHeight / 2 * v.anchorY
		)
	elseif v.type == "circle" then
		love.graphics.translate(v._proxy.x, -v._proxy.y)
	end
	
	love.graphics.rotate(math.rad(v._proxy.angle or 0))

	if v._proxy.shader then
		for name, shKey in pairs(v._proxy.shaderData) do
			if v._proxy.shader:hasUniform(name) then
				v._proxy.shader:send(name, shKey)
			end
		end
		love.graphics.setShader(v._proxy.shader)
	end

	love.graphics.setColor(unpack(v.color or { 1, 1, 1, 1 }))
	if v._proxy.scissors then
	love.graphics.setScissor(window.cx + v._proxy.scissors.x - v._proxy.scissors.width/2 ,window.cy - v._proxy.scissors.y-v._proxy.scissors.height/2,v._proxy.scissors.width,v._proxy.scissors.height)
	end
	local localX = -localWidth / 2
	local localY = -localHeight / 2

	if v.type == "rect" then
		love.graphics.rectangle("fill", localX, localY, v._proxy.width, v._proxy.height)
		if v.strokeWidth and v.strokeColor and v.strokeWidth ~= 0 then
			love.graphics.setLineWidth(v.strokeWidth)
			love.graphics.setColor(unpack(v.strokeColor))
			love.graphics.rectangle("line", localX, localY, v._proxy.width, v._proxy.height)
		end
	elseif v.type == "text" then
		love.graphics.setFont(v.font or love.graphics.getFont())
		love.graphics.print(v.text, localX, localY)
	elseif v.type == "textF" then
		love.graphics.setFont(v.font or love.graphics.getFont())
		love.graphics.printf(v.text, localX, localY,v.limit or window.width,v.align or 'left')
	elseif v.type == "image" then
		love.graphics.draw(v.image, localX, localY, 0, v._proxy.width / v.image:getWidth(), v._proxy.height / v.image:getHeight())
	elseif v.type == "imageSheet" then
		local _, _, qw, qh = v.quad:getViewport()
		love.graphics.draw(v.image, v.quad, localX, localY, 0, v._proxy.width / qw, v._proxy.height / qh)
	elseif v.type == "circle" then
		love.graphics.circle("fill", 0, 0, v._proxy.radius)
		if v.strokeWidth and v.strokeColor and v.strokeWidth ~= 0 then
			love.graphics.setLineWidth(v.strokeWidth)
			love.graphics.setColor(unpack(v.strokeColor))
			love.graphics.circle("line", 0, 0, v._proxy.radius)
		end
	elseif v.type == "line" then
		love.graphics.setLineWidth(v.lineSize)
		love.graphics.line(v.points)
	end

	if v.children and #v.children > 0 then
		local sortedChildren = {}
		for _, child in ipairs(v.children) do table.insert(sortedChildren, child) end
		table.sort(sortedChildren, function(a, b) return (a.layer or 0) < (b.layer or 0) end)
		
		for _, child in ipairs(sortedChildren) do
			drawObject(child)
		end
	end

	if v._proxy.shader then love.graphics.setShader() end
	love.graphics.setScissor()
	love.graphics.pop()
end

function love.draw()
	if display and display.bgColor then
		love.graphics.setBackgroundColor(unpack(display.bgColor))
	end
	
	love.graphics.push()
	love.graphics.translate(window.cx, window.cy)

	local sortedData = {}
	for k, v in pairs(sceneManager.currentScene.data) do
		if v and v.visible then table.insert(sortedData, v) end
	end
	table.sort(sortedData, function(a, b) return (a.layer or 0) < (b.layer or 0) end)
	
	for _, v in ipairs(sortedData) do
		drawObject(v)
	end
	
	love.graphics.pop()
end

return m