-- Copyright (c) 2024 IliaKakos2000. Licensed under the MIT License.
local m = {}

function love.draw()
	if display and display.bgColor then
		love.graphics.setBackgroundColor(unpack(display.bgColor))
	end
	love.graphics.push()
	love.graphics.translate(window.cx, window.cy)

	for k, v in pairs(sceneManager.currentScene.data) do
		if v and v.visible then
			love.graphics.push()
			local localWidth, localHeight = 0, 0
			if v.type == "text" then
				localWidth = v.font:getWidth(v.text)
				localHeight = v.font:getHeight(v.text)
			elseif v.type == "circle" then
				localWidth = v._proxy.radius * 2
				localHeight = v._proxy.radius * 2
			elseif v.type == 'polygon' then 

			else
				localWidth, localHeight = v._proxy.width, v._proxy.height
			end
			if v.type ~= "circle" and v.type ~= 'polygon' then
				love.graphics.translate(
					v._proxy.x + localWidth / 2 * v.anchorX,
					-v._proxy.y + localHeight / 2 * v.anchorY
				)
			elseif v.type == "circle" then
				love.graphics.translate(v._proxy.x, -v._proxy.y)
			end
			love.graphics.rotate(math.rad(v._proxy.angle or 0))
			love.graphics.setColor(unpack(v.color or { 1, 1, 1, 1 }))
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
				if v.font then
					love.graphics.setFont(v.font, v.size)
				else
					love.graphics.setFont("default.ttf", 20)
				end
				love.graphics.print(v.text, localX, localY)
			elseif v.type == "image" then
				love.graphics.draw(
					v.image,
					localX,
					localY,
					0,
					v._proxy.width / v.image:getWidth(),
					v._proxy.height / v.image:getHeight()
				)
			elseif v.type == "circle" then
				love.graphics.circle("fill", 0, 0, v._proxy.radius)

				if v.strokeWidth and v.strokeColor and v.strokeWidth ~= 0 then
					love.graphics.setLineWidth(v.strokeWidth)
					love.graphics.setColor(unpack(v.strokeColor))
					love.graphics.circle("line",0,0, v._proxy.radius)
				end
			elseif v.type == 'polygon' then
				love.graphics.polygon('fill',v.points)
			end
			love.graphics.pop()
		end
	end
	love.graphics.pop()
end

return m
